// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

interface IYieldRelayer {
    /// @notice Emitted when yield is updated by the keeper
    event YieldUpdated(uint256 yieldPerShare);

    /// @notice Update yield accrued for the stTBY contract
    function updateYield(uint256 yieldPerShares) external;

    /// @notice Updates the address of the keeper
    function setKeeper(address keeper) external;

    /// @notice Get the address of the keeper
    function getKeeper() external view returns (address);

    /// @notice Get the address of the stTBY contract
    function getStTBY() external view returns (address);
}
