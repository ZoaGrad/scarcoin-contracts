// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ScarIndexOracle.sol";

/**
 * @title ScarCoin
 * @author Jules
 * @notice An ERC20 token with a conditional minting mechanism based on an external oracle's value.
 */
contract ScarCoin is ERC20, Ownable {
    // --- State Variables ---

    /**
     * @notice The oracle contract that provides the index for minting conditions.
     */
    ScarIndexOracle public oracle;

    /**
     * @notice The minimum index value required for minting to be enabled.
     * The value has 6 decimal places, e.g., 500_000 represents 0.500000.
     */
    uint256 public mintThreshold;

    // --- Events ---

    /**
     * @notice Emitted when the oracle address is updated.
     * @param newOracle The address of the new oracle contract.
     */
    event OracleUpdated(address newOracle);

    /**
     * @notice Emitted when the mint threshold is updated.
     * @param newThreshold The new mint threshold value.
     */
    event ThresholdUpdated(uint256 newThreshold);

    // --- Errors ---

    /**
     * @notice Error thrown when trying to mint while the oracle index is below the threshold.
     * @param currentIndex The current index from the oracle.
     * @param requiredThreshold The required mint threshold.
     */
    error MintingNotAllowed(uint256 currentIndex, uint256 requiredThreshold);

    /**
     * @notice Error thrown when providing a zero address for the oracle.
     */
    error OracleAddressCannotBeZero();

    // --- Constructor ---

    /**
     * @notice Initializes the ScarCoin contract.
     * @param initialOwner The address of the initial owner.
     * @param _oracleAddress The address of the ScarIndexOracle contract.
     */
    constructor(
        address initialOwner,
        address _oracleAddress
    ) ERC20("ScarCoin", "SCAR") Ownable(initialOwner) {
        if (_oracleAddress == address(0)) {
            revert OracleAddressCannotBeZero();
        }
        oracle = ScarIndexOracle(_oracleAddress);
        mintThreshold = 500_000; // Default threshold: 0.500000
    }

    // --- Public Functions ---

    /**
     * @notice Mints a specified amount of tokens to the caller's address.
     * @dev Minting is only allowed if the oracle's current index is greater than or equal to the `mintThreshold`.
     * @param amount The amount of tokens to mint (in wei, 18 decimals).
     */
    function mint(uint256 amount) public {
        uint256 currentIndex = oracle.getIndex();
        if (currentIndex < mintThreshold) {
            revert MintingNotAllowed(currentIndex, mintThreshold);
        }
        _mint(msg.sender, amount);
    }

    /**
     * @notice Burns a specified amount of tokens from the caller's balance.
     * @param amount The amount of tokens to burn (in wei, 18 decimals).
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // --- Owner Functions ---

    /**
     * @notice Updates the address of the oracle contract.
     * @dev Can only be called by the owner.
     * @param _newOracleAddress The address of the new oracle contract.
     */
    function setOracle(address _newOracleAddress) public onlyOwner {
        if (_newOracleAddress == address(0)) {
            revert OracleAddressCannotBeZero();
        }
        oracle = ScarIndexOracle(_newOracleAddress);
        emit OracleUpdated(_newOracleAddress);
    }

    /**
     * @notice Updates the minting threshold.
     * @dev Can only be called by the owner.
     * @param _newThreshold The new value for the mint threshold.
     */
    function setMintThreshold(uint256 _newThreshold) public onlyOwner {
        mintThreshold = _newThreshold;
        emit ThresholdUpdated(_newThreshold);
    }
}
