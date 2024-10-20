# stUsdc

##

Overview

Staked USDC is an rebasing auto-compounding LST for Circle's USDC and Bloom
TBYs. The interface below is only available for the Arbitrum deployment of the
protocol.

##

Contract API

###

`depositTby`

Copy

    
    
    function depositTby(uint256 id, uint256 amount) external returns (uint256 amountMinted);

Deposit a specified `amount` of `TBY`s to mint `stUsdc`.

###

`depositAsset`

Copy

    
    
    function depositAsset(uint256 amount) external returns (uint256 amountMinted);

Deposit a specified `amount` of `underlyingToken` to mint `stUsdc`.

###

`redeemStUsdc`

Copy

    
    
    function redeemStUsdc(uint256 amount) external returns (uint256 underlyingAmount);

Redeem `stUsdc` in exchange for `underlyingTokens`

###

`poke`

Copy

    
    
    function poke(LzSettings calldata settings) external;

Invokes the auto stake feature as well as updates the value accrual.

###

`wstUsdc`

Copy

    
    
    function wstUsdc() external view returns (IWstUsdc);

Returns the `wstUsdc` contract instance.

###

`asset`

Copy

    
    
    function asset() external view returns (IERC20);

Returns the `underlyingToken` contract instance.

###

`stakeUpStaking`

Copy

    
    
    function stakeUpStaking() external view returns (IStakeUpStaking);

Returns the `StakeUpStaking` contract instance.

###

`performanceBps`

Copy

    
    
    function performanceBps() external view returns (uint256);

Returns the performance Bps variable.

###

`lastRedeemedTbyId`

Copy

    
    
    function lastRedeemedTbyId() external view returns (uint256);

Returns the last redeemed `tbyId`.

###

`globalShares`

Copy

    
    
    function globalShares() external view returns (uint256);

The total shares of `stUSDC` tokens in circulation on all chains.

[PreviousTokens](/technical-docs/smart-
contracts/tokens)[NextstUsdcLite](/technical-docs/smart-
contracts/tokens/stusdc/stusdclite)

Last updated 10 days ago



# LayerZero OFT

###

`send`

Copy

    
    
    /**
    * @dev Executes the send operation.
    * @param _sendParam The parameters for the send operation.
    * @param _fee The calculated fee for the send() operation.
    *      - nativeFee: The native fee.
    *      - lzTokenFee: The lzToken fee.
    * @param _refundAddress The address to receive any excess funds.
    * @return msgReceipt The receipt for the send operation.
    * @return oftReceipt The OFT receipt information.
    *
    * @dev MessagingReceipt: LayerZero msg receipt
    *  - guid: The unique identifier for the sent message.
    *  - nonce: The nonce of the sent message.
    *  - fee: The LayerZero fee incurred for the message.
    */
    function send(
       SendParam calldata _sendParam,
       MessagingFee calldata _fee,
       address _refundAddress
    ) external payable virtual returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt);

When bridging any OFT compatible token in the StakeUp ecosystem, `stUsdc` or
`SUP`, the `send` function accomplishes this without the need of extra third
party bridges.

[PreviouswstUsdcLite](/technical-docs/smart-
contracts/tokens/wstusdc/wstusdclite)[NextStakeUpStaking](/technical-
docs/smart-contracts/stakeupstaking)

Last updated 10 days ago



# Privacy Policy

[PreviousTERMS OF SERVICE](/legal/terms-of-service)[NextFAQs](/faqs)



# wstUsdcLite

##

Overview

`wstUsdcLite` is a minimal implementation of `wstUsdc` that will be deployed
on all blockchains except for Arbitrum. If users on another chain need to
deposit and redeem they must either bridge back to Arbitrum or interact with
one of our partnered chain abstraction providers. (More details on this to
come).

##

Contract API

###

`wrap`

Copy

    
    
    function wrap(uint256 stUsdcAmount) external returns (uint256 wstUsdcAmount);

Wraps `stUsdc` into `wstUsdc`.

###

`unwrap`

Copy

    
    
    function unwrap(uint256 wstUsdcAmount) external returns (uint256 stUsdcAmount);

Unwraps `wstUsdc` and returns `stUsdc` to the user.

###

`wstUsdcByStUsdc`

Copy

    
    
    function wstUsdcByStUsdc(uint256 stUsdcAmount) external view returns (uint256);

Return the amount of `wstUsdc` for a given `stUsdcAmount`.

###

`stUsdcByWstUsdc`

Copy

    
    
    function stUsdcByWstUsdc(uint256 wstUsdcAmount) external view returns (uint256);

Return the amount of `stUsdc` for a given `wstUsdcAmount`.

###

`stUsdcPerToken`

Copy

    
    
    function stUsdcPerToken() external view returns (uint256);

Returns the amount of `stUsdc` per `wstUsdc`.

###

`tokensPerStUsdc`

Copy

    
    
    function tokensPerStUsdc() external view returns (uint256);

Returns the amount of `wstUsdc` for one `stUsdc`.

###

`stUsdc`

Copy

    
    
    function stUsdc() external view returns (IStUsdc);

Returns the `stUsdc` token instance.

[PreviouswstUsdc](/technical-docs/smart-
contracts/tokens/wstusdc)[NextLayerZero OFT](/technical-docs/smart-
contracts/tokens/layerzero-oft)

Last updated 10 days ago



# Underlying Backing

[PreviousOur Solution](/protocol/our-solution)[NextEcosystem
Mechanics](/protocol/ecosystem-mechanics)

Last updated 2 months ago



# wstUsdcBridge

##

Overview

The canonical bridge for `wstUsdc` that will be deployed on all networks.

##

Contract API

###

`bridgeWstUsdc`

Copy

    
    
    function bridgeWstUsdc(
        uint32 dstEid,
        bytes32 destinationAddress,
        uint256 wstUsdcAmount,
        LzSettings calldata settings
    ) external payable returns (LzBridgeReceipt memory bridgingReceipt)

Bridges `wstUsdc` to the destination chain, designated by its `dstEid`.

###

`getStUsdc`

Copy

    
    
    function stUsdc() external view returns (address)

Returns the address of `stUsdc` .

###

`getWstUsdc`

Copy

    
    
    function wstUsdc() external view returns (address)

Returns the address for `wstUsdc`.

###

`getBridgeByEid`

Copy

    
    
    function bridgeByEid(uint32 eid) external view returns (address)

Returns the address of the `wstUsdc` bridge contract for the given endpoint
Id, `eid`.

[PreviousSupVesting](/technical-docs/smart-
contracts/stakeupstaking/supvesting)[NextStakeUpErrors](/technical-docs/smart-
contracts/stakeuperrors)

Last updated 10 days ago



# Ecosystem Mechanics

[PreviousUnderlying Backing](/protocol/underlying-backing)[NextMint &
Redeem](/protocol/ecosystem-mechanics/mint-and-redeem)

Last updated 2 months ago



# TERMS OF SERVICE

[PreviousAudits](/technical-docs/audits)[NextPrivacy Policy](/legal/privacy-
policy)



# Staking

[PreviousstUSDC](/protocol/ecosystem-
mechanics/stusdc)[NextSUP](/protocol/ecosystem-mechanics/staking/sup)

Last updated 2 months ago



# Deployment Addresses

Coming soon...

###

Mainnets

Arbitrum

`stUsdc`

`wstUsdc`

`StakeUpToken` (SUP)

`StakeUpStaking`

`wstUsdcBridge`

[PreviousSDK](/technical-docs/sdk)[NextAudits](/technical-docs/audits)

Last updated 2 months ago



# StakeUpStaking

##

Overview

`StakeUpStaking` is a smart contract that allows users to stake `SUP` tokens
in order to receive fees generated from `stUsdc`.

##

Contract API

###

`stake`

Copy

    
    
    function stake(uint256 stakeupAmount) external;

Stake `SUP` tokens in the staking contract to earn `stUsdc` rewards.

###

`unstake`

Copy

    
    
    function unstake(uint256 stakeupAmount, bool harvestRewards) external;

Unstake `SUP` tokens from the staking contract.

###

`harvest`

Copy

    
    
    function harvest() external;

Claim all `stUsdc` rewards accrued by the `msg.sender`

###

`getStakeUpToken`

Copy

    
    
    function stakupToken() external view returns (IStakeUpToken);

Returns the SUP token instance.

###

`getStUsdc`

Copy

    
    
    function stUsdc() external view returns (IStUsdc);

Returns the `stUsdc` token instance.

###

`claimableRewards`

Copy

    
    
    function claimableRewards(address account) external view returns (uint256);

Returns the amount of claimable rewards available for an `account` in terms of
`stUsdc`.

###

`totalStakeUpStaked`

Copy

    
    
    function totalStakeUpStaked() external view returns (uint256);

Returns the total amount of `SUP` staked within the staking contract.

###

`getRewardData`

Copy

    
    
    function rewardData() external view returns (RewardData memory);

Returns the global `RewardData` struct for the staking contract.

Copy

    
    
    /**
    * @notice Data structure containing information pertaining to a reward period
    * @dev All rewards are denominated in stTBY shares due to the token's rebasing nature
    * @param index The last index that the rewards were updated
    * @param lastShares The last shares balance of rewards available in the contract
    */
    struct RewardData {
       uint128 index;
       uint128 lastShares;
    }

###

`getUserStakingData`

Copy

    
    
    function userStakingData(address account) external view returns (StakingData memory);

Returns `StakingData` for a specific `account`.

Copy

    
    
    /**
    * @notice Data structure containing information pertaining to a user's stake
    * @dev All rewards are denominated in stTBY shares due to the token's rebasing nature
    * @param amountStaked The amount of STAKEUP tokens currently staked
    * @param index The last index that the users rewards were updated
    * @param rewardsAccrued The amount of stTBY rewards that have accrued to the stake
    */
    struct StakingData {
       uint256 amountStaked;
       uint128 index;
       uint128 rewardsAccrued;
    }

###

`getLastRewardBlock`

Copy

    
    
    function lastRewardBlock() external view returns (uint256);

Returns the last block of the global reward data.

[PreviousLayerZero OFT](/technical-docs/smart-contracts/tokens/layerzero-
oft)[NextSupVesting](/technical-docs/smart-
contracts/stakeupstaking/supvesting)

Last updated 10 days ago



# Tokens

There are three major token contracts that exist within the StakeUp ecosystem.
Each token contains a full feature instance deployed on Arbitrum and a "Lite"
instance deployed on all other networks.

SUP is not included within the technical docs due to the absence of unique
logic for users outside of normal ERC20 and LayerZero OFT standards.

[PreviousSmart Contracts](/technical-docs/smart-
contracts)[NextstUsdc](/technical-docs/smart-contracts/tokens/stusdc)

Last updated 2 months ago



# SUP

[PreviousStaking](/protocol/ecosystem-mechanics/staking)[NextOmni-chain
Functionality](/protocol/ecosystem-mechanics/omni-chain-functionality)

Last updated 10 days ago



# Our Solution

A cross-border solution for DeFi and TradFi markets.

[PreviousCurrent Problem](/protocol/current-problem)[NextUnderlying
Backing](/protocol/underlying-backing)

Last updated 2 months ago



# Mint & Redeem

##

Mint

Anyone who holds `TBY`s or `USDC` can mint `stUSDC` at a ratio of 1:1 of the
value of the deposit token.

`USDC` lending deposits will automatically be lent in the underlying
`Bloom-v2` system

`TBY` receipts will be held within the `stUSDC` contract and automatically re-
lent into following loans.

##

Redeem

Redemptions allow users to redeem their `stUSDC` for `USDC` 1:1. If there is
not enough `USDC` liquidity within the contract the user must wait for the
next batch of `TBY`s to mature and convert into available `USDC`.

If your redemption cannot be processed and you want to access `USDC`
Immediately you can visit a supported DEX or CEX.

[PreviousEcosystem Mechanics](/protocol/ecosystem-
mechanics)[NextstUSDC](/protocol/ecosystem-mechanics/stusdc)

Last updated 2 months ago



# Audits

Coming soon...

[PreviousDeployment Addresses](/technical-docs/deployment-addresses)[NextTERMS
OF SERVICE](/legal/terms-of-service)

Last updated 2 months ago



# Omni-chain Functionality

[PreviousSUP](/protocol/ecosystem-mechanics/staking/sup)[NextSmart
Contracts](/technical-docs/smart-contracts)

Last updated 10 days ago



# wstUsdc

##

Overview

The Wrapped non-rebasing version of `stUsdc`. The interface below is only
available for the Arbitrum deployment of the protocol.

##

Contract API

###

`depositAsset`

Copy

    
    
    function depositAsset(uint256 amount) external returns (uint256 amountMinted);

Mint `wstUsdc` directly by depositing `underlyingAssets` .

###

`depositTby`

Copy

    
    
    function depositTby(uint256 id, uint256 amount) external returns (uint256 amountMinted);

Mint `wstUsdc` directly by depositing a specific `TBY` `id` .

###

`redeemWstUsdc`

Copy

    
    
    function redeemWstUsdc(uint256 wstTBYAmount) external returns (uint256 assetsRedeemed);

Redeem `wstUsdc` for `underlyingAssets`.

[PreviousstUsdcLite](/technical-docs/smart-
contracts/tokens/stusdc/stusdclite)[NextwstUsdcLite](/technical-docs/smart-
contracts/tokens/wstusdc/wstusdclite)

Last updated 10 days ago



# API

Coming soon...

[PreviousStakeUpErrors](/technical-docs/smart-
contracts/stakeuperrors)[NextSDK](/technical-docs/sdk)

Last updated 2 months ago



# Current Problem

A significant challenge in the DeFi is accessing yield derived from US
Treasury bills in a permissionless manner. Additionally, the majority of
today’s RWAs face obstacles in on-chain integration, requiring thorough KYC
procedures and limiting assets to isolated DeFi products (where you cannot
have pools of non KYC’ed funds integrated with KYC’ed funds), reducing their
utility.

The public good, `Bloom-v2`, addresses the KYC and access issues to on-chain
products deriving from US Treasuries, but still fails at fully being able to
integrate within DeFi due to the production of multiple short date tokens.
This makes having sufficient market depth nearly impossible creating another
bottleneck within the quest to find the perfect on-chain DeFi Rwa T-bill
product.

[PreviousStakeUp](/)[NextOur Solution](/protocol/our-solution)

Last updated 2 months ago



# StakeUp

##

Overview

StakeUp Protocol, developed by the Blueberry Foundation, is a composability
layer built on top of Circle's `USDC` and Bloom Protocol's `Bloom-v2` ,
creating an automated lending vault for `USDC` and `TBY`s. This allows
permissionless lenders(1) to loan `USDC` to permissioned borrowers within the
Bloom system, who can only use these loans to purchase tokenized 'tracker
certificates' replicating the price movements of US Treasury Bills. This
closed-loop system aims to address the challenge of accessing yield from US
Treasury bills.

Additionally, RWAs in DeFi face integration and utility issues due to KYC-
mandated procedures and non-KYC nature across the majority of DeFi protocols.
StakeUp Protocol's product structure offers significant commercial reach,
enabling it to be offered as a stable asset (`stUSDC`), a fixed-income product
or a low-risk savings account in various emerging market regions with currency
instability, providing stable yields and currency hedging in an easy-to-use
product backed up by the most liquid market in tradFi.

(1) Restricted geolocation are unable to participate

[NextCurrent Problem](/protocol/current-problem)

Last updated 2 months ago



# StakeUp

##

Overview

StakeUp Protocol, developed by the Blueberry Foundation, is a composability
layer built on top of Circle's `USDC` and Bloom Protocol's `Bloom-v2` ,
creating an automated lending vault for `USDC` and `TBY`s. This allows
permissionless lenders(1) to loan `USDC` to permissioned borrowers within the
Bloom system, who can only use these loans to purchase tokenized 'tracker
certificates' replicating the price movements of US Treasury Bills. This
closed-loop system aims to address the challenge of accessing yield from US
Treasury bills.

Additionally, RWAs in DeFi face integration and utility issues due to KYC-
mandated procedures and non-KYC nature across the majority of DeFi protocols.
StakeUp Protocol's product structure offers significant commercial reach,
enabling it to be offered as a stable asset (`stUSDC`), a fixed-income product
or a low-risk savings account in various emerging market regions with currency
instability, providing stable yields and currency hedging in an easy-to-use
product backed up by the most liquid market in tradFi.

(1) Restricted geolocation are unable to participate

[NextCurrent Problem](/protocol/current-problem)

Last updated 2 months ago



# Smart Contracts

Coming soon...

[PreviousOmni-chain Functionality](/protocol/ecosystem-mechanics/omni-chain-
functionality)[NextTokens](/technical-docs/smart-contracts/tokens)

Last updated 2 months ago



# stUSDC

Staked USDC is an rebasing auto-compounding LST for Circle's USDC and Bloom
TBYs

##

stUSDC vs wstUSDC

There are two versions of StakeUp stTokens, namely stUSDC and wstUSDC. Both
are fungible tokens but they reflect the accrued yield differently.

##

stUSDC

The token's yield is updated every `24 hours` through the `poke` function and
rebases constantly as the previous day's yield is dripped to users. A user is
able to redeem their `stUSDC` at a rate 1:1 to `USDC`

For users not familiar with rebasing tokens:

  * Token balances will change according to the amount of yield accumulated within the system.

##

wstUSDC

Provides an alternative to the rebasing version of `stUSDC`. It has a static
balance by representing the share that a user has in the system. At any given
time, anyone holding wstUSDC can convert any amount of it to stUSDC at a fixed
rate, and vice versa. The rate is the same for everyone at any given moment.
This method allows for enhanced composability across DeFi.

For users not familiar with rebasing tokens:

  * Due to the fact that `wstUSDC` is non-rebasing, the user's balance while holding the token will remain static and value accrual be reflected in the exchange rate of the token.

##

Wrapping

Users can wrap their `stUSDC` token by calling `wstUSDC::wrap` . The
conversion is based on the current exchange rate, which reflects the total
value of `stUSDC` in circulation.

##

Unwrapping

Users can unwrap their `wstUSDC` token by calling `wstUSDC::unwrap` . The
conversion is based on the current exchange rate, which reflects the total
value of `stUSDC` in circulation.

##

Fees

There is a 10% performance fee on yield generated within `stUSDC`. This fee is
paid fully to the stakers of the SUP token within the StakeUp Protocol.

[PreviousMint & Redeem](/protocol/ecosystem-mechanics/mint-and-
redeem)[NextStaking](/protocol/ecosystem-mechanics/staking)

Last updated 10 days ago



# StakeUpErrors

Below are a list of error codes within the Bloom ecosystem.

Copy

    
    
    // =================== Staking ===================
    /// @notice Emitted if the staking is locked due to a user depositing less than 24 hours ago
    error Locked();
    
    // =================== Curve Gauge Distributor ===================
    /// @notice Emitted if the caller tries to seed the gauges to early
    error TooEarlyToSeed();
    
    /// @notice Emitted if the reward allocation is not met
    error RewardAllocationNotMet();
    
    /// @notice Emitted if the contract is not initialized
    error NotInitialized();
    
    // ========================= Staking ===========================
    // @notice Token amount is 0
    error ZeroTokensStaked();
    
    // @notice User has no current stake
    error UserHasNoStake();
    
    // @notice User has no rewards to claim
    error NoRewardsToClaim();
    
    // ========================= Layer Zero ===========================
    /// @notice If the LZ Compose call fails
    error LZComposeFailed();
    
    /// @notice If the originating OApp of the LZCompose call is invalid
    error InvalidOApp();
    
    /// @notice Invalid Peer ID
    error InvalidPeerID();
    
    /// @notice Error emmitted if the nonce of an incoming message is not what its suppose to be
    error InvalidNonce();
    
    /// @notice Error emmitted if the msg.value is less than the fee
    error InvalidMsgValue();
    
    // ========================= SUP Token ===========================
    /// @notice Amount being minted is greater than the supply cap
    error ExceedsMaxSupply();
    
    /// @notice Invalid recipient, must be non-zero address
    error InvalidRecipient();
    
    // ========================= StUsdc Token ===========================
    /// @notice Error emitted if the asset does not match the BloomPool's asset
    error InvalidAsset();
    
    /// @notice Insufficient balance
    error InsufficientBalance();
    
    /// @notice TBY redeemable
    error RedeemableTbyNotAllowed();
    
    /// @notice Keepers are not allowed for this deployment of stUsdc
    error KeepersNotAllowed();
    
    /// @notice Rate update too often
    error RateUpdateTooOften();
    
    // ========================= General ===========================
    /// @notice Zero amount
    error ZeroAmount();
    
    // @notice The address is 0
    error ZeroAddress();
    
    /// @dev Error emitted when caller is not allowed to execute a function
    error UnauthorizedCaller();
    
    /// @notice Contract has already been initialized
    error AlreadyInitialized();

[PreviouswstUsdcBridge](/technical-docs/smart-
contracts/wstusdcbridge)[NextAPI](/technical-docs/api)

Last updated 10 days ago



# SDK

A development SDK for wallet providers, front-end providers, and TradFi
institutions created to ease the efforts of integrating stUSDC and StakeUp.

Coming Soon...

[PreviousAPI](/technical-docs/api)[NextDeployment Addresses](/technical-
docs/deployment-addresses)

Last updated 2 months ago



# stUsdcLite

##

Overview

`stUsdcLite` is a minimal implementation of `stUsdc` that will be deployed on
all blockchains except for Arbitrum. It will still accrue the same yield and
rebase just like the full instance on Arbitrum. The only difference is that
liquidity is not stored within this instance and to deposit and redeem users
must either bridge back to Arbitrum or interact with one of our partnered
chain abstraction providers. (More details on this to come).

##

Contract API

###

`transferShares`

Copy

    
    
    function transferShares(address recipient, uint256 sharesAmount) external returns (uint256);

Transfers `sharesAmount` of `stUsdc` from `msg.sender` to the `recipient`.

###

`transferSharesFrom`

Copy

    
    
    function transferSharesFrom(address sender, address recipient, uint256 sharesAmount) external returns (uint256);

Transfers `sharesAmount` of `stUsdc` from `sender` to the `recipient`.

###

`totalUsd`

Copy

    
    
    function totalUsd() external view returns (uint256);

Returns the total usd value allocated for the given deployment instance of
`stUsdc`.

###

`totalShares`

Copy

    
    
    function totalShares() external view returns (uint256);

Returns the total number of shares for the instance of `stUsdc`.

###

`sharesOf`

Copy

    
    
    function sharesOf(address account) external view returns (uint256);

Returns the amount of shares owned by an `account`.

###

`sharesByUsd`

Copy

    
    
    function sharesByUsd(uint256 usdAmount) external view returns (uint256);

Returns the number of shares corresponding with a given `usdAmount`.

###

`usdByShares`

Copy

    
    
    function usdByShares(uint256 sharesAmount) external view returns (uint256);

Returns the amount of USD that corresponds with a given `sharesAmount`.

###

`rewardPerSecond`

Copy

    
    
    function rewardPerSecond() external view returns (uint256);

Returns the `rewardPerSecond` of yield that is being distributed to token
holders over the `24 hour` duration following rate updates.

###

`lastRateUpdate`

Copy

    
    
    function lastRateUpdate() external view returns (uint256);

Returns the last time that the rate was updated

###

`lastUsdPerShare`

Copy

    
    
    function lastUsdPerShare() external view returns (uint256);

Returns the `usdPerShare` value at the time of the last rate update

###

`totalUsdFloor`

Copy

    
    
    function totalUsdFloor() external view returns (uint256);

Returns the total USD value of the protocol, not including any yield that is
set to drip out with `rewardPerSecond`.

###

`keeper`

Copy

    
    
    function keeper() external view returns (StakeUpKeeper);

Returns the instance of the `StakeUpKeeper` contract, which is a LayerZero
OApp that relays rate updates from the liquidity hub chain to all other
blockchain instances.

[PreviousstUsdc](/technical-docs/smart-
contracts/tokens/stusdc)[NextwstUsdc](/technical-docs/smart-
contracts/tokens/wstusdc)

Last updated 10 days ago



# FAQs

##

What is stUSDC?

stUSDC is a stablecoin within the Bloom Protocol, backed by TBY (fixed-income
debt tokens). stUSDC generates yield from these TBY tokens and adjusts its
supply periodically (rebasing) to reflect the accrued interest, maintaining a
stable value pegged to its underline.

##

What is wstUSDC?

wstUSDC is the wrapped version of stUSDC. Unlike stUSDC wstUSDC has a fixed
supply, making it easier to use in various DeFi applications and across
multiple blockchain networks without the complications of rebasing.

##

What is SUP?

SUP is StakeUp Protocol’s yield bearing Utility token, which allows
stakeholders to earn a share of StakeUp protocols fees. Fees are paid out to
stakeholders according to thier side of SUP, fees are paid in stUSDC

##

How does stUSDC generate yield?

stUSDC generates yield through the underlying TBY tokens, which are 6-month
fixed-income debt tokens. These tokens pay a set interest rate, and the yield
is distributed to stUSDC holders through the rebasing protocol logic.

##

How do I wrap stUSDC into wstUSDC?

To wrap stUSDC into wstUSDC, you interact with the wstUSDC contract. The
conversion is based on the current exchange rate between stUSDC and wstUSDC,
reflecting the total value of stUSDC. Users will be able to do this on StakeUp
and other supported DeFi protocols.

##

How do I unwrap wstUSDC back into stUSDC?

To unwrap wstUSDC back into stUSDC you use the wstUSDC contract. The
conversion back to stUSDC is based on the current exchange rate at the time of
unwrapping.

##

What are the benefits of holding stUSDC?

Holding stUSDC allows you to earn yield generated by the underlying TBY
tokens. The rebasing mechanism ensures your holdings reflect the accrued
interest, maintaining a stable value pegged to the underline asset.

##

What are the benefits of holding wstUSDC?

Holding wstUSDC provides a stable and predictable token balance, making it
easier to use in multi-chain environments and various DeFi applications.
wstUSDC does not undergo rebasing, which simplifies liquidity provision and
integration with other protocols.

##

Why should I wrap stUSDCinto wstUSDC?

Wrapping stUSDCinto wstUSDC is beneficial for using the asset in DeFi
applications and multi-chain integrations where a fixed supply token is more
supported and rebasing token are not. It avoids the complexities of rebasing,
providing a stable and consistent token balance. In some regions non-rebasing
tokens are easier to report on taxes.

##

what are the fees?

StakeUp protocol only takes a 10% perfomance fee, there are no other fees.

[PreviousPrivacy Policy](/legal/privacy-policy)

Last updated 2 months ago



# SupVesting

##

Overview

Within `StakeUpStaking` contributor and investor token allocations are held
allowing users to have their `SUP` tokens staked and generating rewards while
they are in the middle of vesting.

##

Contract API

###

`getAvailableTokens`

Copy

    
    
    function availableTokens(address account) external view returns (uint256);

Return the amount of tokens currently available to withdraw from the vesting
contract.

###

`claimAvailableTokens`

Copy

    
    
    function claimAvailableTokens() external returns (uint256);

Claim and withdraw all tokens that have completed vesting.

###

`getCurrentBalance`

Copy

    
    
    function currentBalance(address account) external view returns (uint256);

Returns the amount of `SUP` that are within the vesting portion of
`StakeUpStaking` for a given `account`, vested and locked.

[PreviousStakeUpStaking](/technical-docs/smart-
contracts/stakeupstaking)[NextwstUsdcBridge](/technical-docs/smart-
contracts/wstusdcbridge)

Last updated 10 days ago



