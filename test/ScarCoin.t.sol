// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/ScarCoin.sol";

contract ScarCoinTest is Test {
    ScarCoin public scarCoin;
    address public owner;
    address public user1;
    address public user2;
    address public mockOracle;
    
    uint256 constant MIN_ACHE_SCORE = 100;
    uint256 constant MAX_MINT_PER_RITUAL = 1000 * 1e18;
    
    event RitualMint(
        address indexed user,
        bytes32 indexed ritualId,
        uint256 amount,
        uint256 acheScore
    );
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        mockOracle = makeAddr("mockOracle");
        
        scarCoin = new ScarCoin(mockOracle, MIN_ACHE_SCORE, MAX_MINT_PER_RITUAL);
    }
    
    function testInitialState() public {
        assertEq(scarCoin.name(), "ScarCoin");
        assertEq(scarCoin.symbol(), "SCAR");
        assertEq(scarCoin.scarIndexOracle(), mockOracle);
        assertEq(scarCoin.minAcheScore(), MIN_ACHE_SCORE);
        assertEq(scarCoin.maxMintPerRitual(), MAX_MINT_PER_RITUAL);
    }
    
    function testRitualMintSuccess() public {
        bytes32 ritualId = keccak256("test_ritual_1");
        uint256 mintAmount = 500 * 1e18;
        uint256 acheScore = 150;
        
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit RitualMint(user1, ritualId, mintAmount, acheScore);
        
        scarCoin.ritualMint(ritualId, mintAmount, acheScore);
        
        assertEq(scarCoin.balanceOf(user1), mintAmount);
        assertEq(scarCoin.ritualMints(ritualId), mintAmount);
        assertEq(scarCoin.userMints(user1), mintAmount);
    }
    
    function testRitualMintInsufficientAcheScore() public {
        bytes32 ritualId = keccak256("test_ritual_2");
        uint256 mintAmount = 500 * 1e18;
        uint256 lowAcheScore = 50; // Below minimum
        
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                ScarCoin.InsufficientAcheScore.selector,
                MIN_ACHE_SCORE,
                lowAcheScore
            )
        );
        
        scarCoin.ritualMint(ritualId, mintAmount, lowAcheScore);
    }
    
    function testRitualMintExceedsMaxAmount() public {
        bytes32 ritualId = keccak256("test_ritual_3");
        uint256 excessiveAmount = MAX_MINT_PER_RITUAL + 1;
        uint256 acheScore = 150;
        
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                ScarCoin.ExceedsMaxMintPerRitual.selector,
                excessiveAmount,
                MAX_MINT_PER_RITUAL
            )
        );
        
        scarCoin.ritualMint(ritualId, excessiveAmount, acheScore);
    }
    
    function testRitualAlreadyCompleted() public {
        bytes32 ritualId = keccak256("test_ritual_4");
        uint256 mintAmount = 500 * 1e18;
        uint256 acheScore = 150;
        
        // First mint should succeed
        vm.prank(user1);
        scarCoin.ritualMint(ritualId, mintAmount, acheScore);
        
        // Second mint with same ritual ID should fail
        vm.prank(user2);
        vm.expectRevert(
            abi.encodeWithSelector(
                ScarCoin.RitualAlreadyCompleted.selector,
                ritualId
            )
        );
        
        scarCoin.ritualMint(ritualId, mintAmount, acheScore);
    }
    
    function testSetScarIndexOracle() public {
        address newOracle = makeAddr("newOracle");
        
        scarCoin.setScarIndexOracle(newOracle);
        assertEq(scarCoin.scarIndexOracle(), newOracle);
    }
    
    function testSetMinAcheScore() public {
        uint256 newMinScore = 200;
        
        scarCoin.setMinAcheScore(newMinScore);
        assertEq(scarCoin.minAcheScore(), newMinScore);
    }
    
    function testBurnTokens() public {
        // First mint some tokens
        bytes32 ritualId = keccak256("burn_test_ritual");
        uint256 mintAmount = 1000 * 1e18;
        uint256 acheScore = 150;
        
        vm.prank(user1);
        scarCoin.ritualMint(ritualId, mintAmount, acheScore);
        
        // Then burn some tokens
        uint256 burnAmount = 300 * 1e18;
        vm.prank(user1);
        scarCoin.burn(burnAmount);
        
        assertEq(scarCoin.balanceOf(user1), mintAmount - burnAmount);
    }
}