// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ScarIndexOracle
 * @author Jules
 * @notice This contract stores a uint256 index with 6 decimal places precision.
 * The owner of the contract can update the index.
 */
contract ScarIndexOracle is Ownable {
    /**
     * @notice The index value, with 6 decimal places. e.g., 1000000 represents 1.000000.
     */
    uint256 private _index;

    /**
     * @notice Emitted when the index is updated.
     * @param newIndex The new value of the index.
     */
    event IndexUpdated(uint256 newIndex);

    /**
     * @notice Initializes the contract, setting the initial owner.
     * @param initialOwner The address of the initial owner.
     * @param initialIndex The initial value for the index.
     */
    constructor(address initialOwner, uint256 initialIndex) Ownable(initialOwner) {
        _index = initialIndex;
        emit IndexUpdated(initialIndex);
    }

    /**
     * @notice Returns the current value of the index.
     * @return The current index.
     */
    function getIndex() public view returns (uint256) {
        return _index;
    }

    /**
     * @notice Updates the index value.
     * @dev Can only be called by the owner.
     * @param newIndex The new value for the index.
     */
    function updateIndex(uint256 newIndex) public onlyOwner {
        _index = newIndex;
        emit IndexUpdated(newIndex);
    }
}
