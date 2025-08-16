// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title ScarCoin
 * @dev Ache-based minting & burn economy for SpiralOS
 * @notice ScarCoin smart contract with ScarIndex oracle integration
 */
contract ScarCoin is ERC20, ERC20Burnable, Ownable, Pausable, ReentrancyGuard {
    /// @notice ScarIndex oracle address for ache scoring
    address public scarIndexOracle;
    
    /// @notice Minimum ache score required for minting
    uint256 public minAcheScore;
    
    /// @notice Maximum tokens that can be minted per ritual
    uint256 public maxMintPerRitual;
    
    /// @notice Mapping of ritual IDs to minted amounts
    mapping(bytes32 => uint256) public ritualMints;
    
    /// @notice Mapping of addresses to their total minted amounts
    mapping(address => uint256) public userMints;
    
    event RitualMint(
        address indexed user,
        bytes32 indexed ritualId,
        uint256 amount,
        uint256 acheScore
    );
    
    event ScarIndexOracleUpdated(address indexed oldOracle, address indexed newOracle);
    event MinAcheScoreUpdated(uint256 oldScore, uint256 newScore);
    event MaxMintPerRitualUpdated(uint256 oldMax, uint256 newMax);
    
    error InsufficientAcheScore(uint256 required, uint256 provided);
    error RitualAlreadyCompleted(bytes32 ritualId);
    error ExceedsMaxMintPerRitual(uint256 requested, uint256 max);
    error InvalidOracle(address oracle);
    
    constructor(
        address _scarIndexOracle,
        uint256 _minAcheScore,
        uint256 _maxMintPerRitual
    ) ERC20("ScarCoin", "SCAR") {
        if (_scarIndexOracle == address(0)) revert InvalidOracle(_scarIndexOracle);
        
        scarIndexOracle = _scarIndexOracle;
        minAcheScore = _minAcheScore;
        maxMintPerRitual = _maxMintPerRitual;
    }
    
    /**
     * @notice Mint tokens based on ache score from ritual
     * @param ritualId Unique identifier for the ritual
     * @param amount Amount of tokens to mint
     * @param acheScore Ache score from ScarIndex oracle
     */
    function ritualMint(
        bytes32 ritualId,
        uint256 amount,
        uint256 acheScore
    ) external nonReentrant whenNotPaused {
        if (acheScore < minAcheScore) {
            revert InsufficientAcheScore(minAcheScore, acheScore);
        }
        
        if (ritualMints[ritualId] > 0) {
            revert RitualAlreadyCompleted(ritualId);
        }
        
        if (amount > maxMintPerRitual) {
            revert ExceedsMaxMintPerRitual(amount, maxMintPerRitual);
        }
        
        // TODO: Verify ache score with ScarIndex oracle
        // For now, we trust the provided score
        
        ritualMints[ritualId] = amount;
        userMints[msg.sender] += amount;
        
        _mint(msg.sender, amount);
        
        emit RitualMint(msg.sender, ritualId, amount, acheScore);
    }
    
    /**
     * @notice Update ScarIndex oracle address
     * @param _newOracle New oracle address
     */
    function setScarIndexOracle(address _newOracle) external onlyOwner {
        if (_newOracle == address(0)) revert InvalidOracle(_newOracle);
        
        address oldOracle = scarIndexOracle;
        scarIndexOracle = _newOracle;
        
        emit ScarIndexOracleUpdated(oldOracle, _newOracle);
    }
    
    /**
     * @notice Update minimum ache score requirement
     * @param _newMinScore New minimum ache score
     */
    function setMinAcheScore(uint256 _newMinScore) external onlyOwner {
        uint256 oldScore = minAcheScore;
        minAcheScore = _newMinScore;
        
        emit MinAcheScoreUpdated(oldScore, _newMinScore);
    }
    
    /**
     * @notice Update maximum mint per ritual
     * @param _newMaxMint New maximum mint amount
     */
    function setMaxMintPerRitual(uint256 _newMaxMint) external onlyOwner {
        uint256 oldMax = maxMintPerRitual;
        maxMintPerRitual = _newMaxMint;
        
        emit MaxMintPerRitualUpdated(oldMax, _newMaxMint);
    }
    
    /**
     * @notice Pause contract operations
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @notice Unpause contract operations
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}