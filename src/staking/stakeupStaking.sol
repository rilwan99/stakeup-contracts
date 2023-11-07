// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {IStUSD} from "../interfaces/IStUSD.sol";
import {IStakeupToken} from "../interfaces/IStakeupToken.sol";
import {IStakeupStaking} from "../interfaces/IStakeupStaking.sol";

/**
 * @title StakeupStaking
 * @notice Allows users to stake their STAKEUP tokens to earn stUSD rewards.
 *         Tokens can be staked for any amount of time and can be unstaked at any time.
 *         The rewards tracking system is based on the methods used by Convex Finance & 
 *         Aura Finance but have been modified to fit the needs of the StakeUp Protocol.
 * @dev There will be one week reward periods. This is to ensure that the reward rate
 *      is updated frequently enough to keep up with the changing amount of STAKEUP staked.
 */
contract StakeupStaking is IStakeupStaking, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // =================== Storage ===================
    
    // @notice The STAKEUP token
    IStakeupToken public stakeupToken;

    // @notice The stUSD token
    IStUSD public stUSD;

    // @dev Mapping of users to their staking data
    mapping(address => StakingData) public stakingData;

    // @dev Data pertaining to the current reward period
    RewardData public rewardData;

    // @notice Total amount of STAKEUP staked
    uint256 public totalStakeUpStaked;

    // @dev Duration of a reward period
    uint256 rewardDuration = 1 weeks;

    // =================== Structs ====================
    /**
     * @notice Data structure containing information pertaining to a user's stake
     * @param amountStaked The amount of STAKEUP tokens currently staked
     * @param rewardsAccrued The amount of stUSD rewards that have accrued to the stake
     */
    struct StakingData {
        uint128 amountStaked;
        uint128 rewardsPerTokenPaid;
        uint128 rewardsAccrued;
    }

    /**
     * @notice Data structure containing information pertaining to a reward period
     * @param periodFinished The end time of the reward period
     * @param lastUpdate The last time the staking rewards were updated
     * @param rewardRate The amount of stUSD rewards per second for the reward period
     * @param rewardPerTokenStaked The amount of stUSD rewards per STAKEUP staked
     * @param availableRewards The amount of stUSD rewards available for the reward period
     * @param pendingRewards The amount of stUSD rewards that have not been claimed
     */
    struct RewardData {
        uint32 periodFinished;
        uint32 lastUpdate;
        uint96 rewardRate;
        uint96 rewardPerTokenStaked;
        uint128 availableRewards;
        uint128 pendingRewards;
    }

    // =================== Events ====================

    /**
     * @notice Emitted when a user's stakes their Stakeup Token
     * @param user Address of the user who has staked their STAKEUP
     * @param amount Amount of STAKEUP staked
     */
    event StakeupStaked(address indexed user, uint256 amount);

    /**
     * @notice Emitted when a user's stakes their Stakeup Token
     * @param user Address of the user who is unstaking their STAKEUP
     * @param amount Amount of STAKEUP unstaked
     */
    event StakeupUnstaked(address indexed user, uint256 amount);

    constructor(
        address _stakeupToken,
        address _stUSD
    ) {
        stakeupToken = IStakeupToken(_stakeupToken);
        stUSD = IStUSD(_stUSD);

        rewardData = RewardData({
            periodFinished: uint32(rewardDuration),
            lastUpdate: uint32(block.timestamp),
            rewardRate: 0,
            rewardPerTokenStaked: 0,
            availableRewards: 0,
            pendingRewards: 0
        });
    }
    /**
     * @notice Updates the rewards accrued for a user and global reward state
     * @param account Address of the user who is getting their rewards updated
     */
    modifier updateReward(address account) {
        {
            StakingData storage userStakingData = stakingData[account];
            RewardData storage rewards = rewardData;
            
            uint256 newRewardPerTokenStaked = _rewardPerToken();
            rewards.rewardPerTokenStaked = uint96(newRewardPerTokenStaked);
            rewards.lastUpdate = uint32(_lastTimeRewardApplicable(rewards.periodFinished));

            if (account != address(0)) {
                userStakingData.rewardsPerTokenPaid = uint128(newRewardPerTokenStaked);
                userStakingData.rewardsAccrued = uint128(_earned(account));
            }
        }
        _;
    }

    // ================== functions ==================

    /**
     * @notice Stake Stakeup Token's to earn stUSD rewards
     * @param stakeupAmount Amount of STAKEUP to stake
     */
    function stake(uint256 stakeupAmount) external override nonReentrant updateReward(msg.sender) {
        StakingData storage userStakingData = stakingData[msg.sender];

        if (stakeupAmount == 0) revert ZeroTokensStaked();

        userStakingData.amountStaked += uint128(stakeupAmount);
        totalStakeUpStaked += stakeupAmount;

        IERC20(address(stakeupToken)).safeTransferFrom(msg.sender, address(this), stakeupAmount);
        
        emit StakeupStaked(msg.sender, stakeupAmount);
    }

    /**
     * @notice Unstakes the user's STAKEUP and sends it back to them, along with their accumulated stUSD gains
     * @param stakeupAmount Amount of STAKEUP to unstake
     * @param harvestAmount Amount of stUSD to harvest and send to the user
     */
    function unstake(uint256 stakeupAmount, uint256 harvestAmount) external override nonReentrant updateReward(msg.sender) {
        StakingData storage userStakingData = stakingData[msg.sender];

        if (userStakingData.amountStaked == 0) revert UserHasNoStaked();
        
        stakeupAmount = Math.min(stakeupAmount, userStakingData.amountStaked);
        harvestAmount = Math.min(harvestAmount, userStakingData.rewardsAccrued);

        userStakingData.amountStaked -= uint128(stakeupAmount);
        totalStakeUpStaked -= stakeupAmount;
        
        userStakingData.rewardsAccrued -= uint128(harvestAmount);

        IERC20(address(stakeupToken)).safeTransfer(msg.sender, stakeupAmount);
        IERC20(address(stUSD)).safeTransfer(msg.sender, harvestAmount);

        emit StakeupUnstaked(msg.sender, stakeupAmount);
    }

    /**
     * @notice Claim all stUSD rewards accrued by the user
     */
    function harvest() external {
        harvest(type(uint256).max);
    }

    /**
     * @notice Claim a specific amount of stUSD rewards
     * @param amount Amount of rewards to claim
     */
    function harvest(uint256 amount) public nonReentrant updateReward(msg.sender) {
        StakingData storage userStakingData = stakingData[msg.sender];

        if (userStakingData.amountStaked == 0) revert UserHasNoStaked();
        if (userStakingData.rewardsAccrued == 0) revert NoRewardsToClaim();

        amount = Math.min(amount, userStakingData.rewardsAccrued);

        userStakingData.rewardsAccrued -= uint128(amount);

        IERC20(address(stUSD)).safeTransfer(msg.sender, amount);
    }

    /**
     * @notice How much stUSD rewards a user has earned
     * @param account Address of the user to query rewards for
     * @return Amount of stUSD rewards earned
     */
    function claimableRewards(address account) external view returns (uint256) {
        return _earned(account);
    }

    function _lastTimeRewardApplicable(uint32 periodFinished) internal view returns (uint32) {
        return uint32(Math.min(block.timestamp, periodFinished));
    }

    function _rewardPerToken() internal view returns (uint256) {
        if (totalStakeUpStaked == 0) {
            return rewardData.rewardPerTokenStaked;
        }
        uint256 timeElapsed = _lastTimeRewardApplicable(rewardData.periodFinished) - rewardData.lastUpdate;

        return 
            uint256(rewardData.rewardPerTokenStaked).add(
                timeElapsed.mul(1e18).div(totalStakeUpStaked)
            );
    }

    function _earned(address account) internal view returns (uint256) {
        StakingData storage userStakingData = stakingData[account];
        return 
            uint256(userStakingData.amountStaked).mul(
                _rewardPerToken().sub(uint256(userStakingData.rewardsPerTokenPaid))
            ).div(1e18).add(userStakingData.rewardsAccrued);
    }
}
