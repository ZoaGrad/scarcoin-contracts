// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {ScarCoin} from "../src/ScarCoin.sol";

contract ScarCoinTest is Test {
    ScarCoin token;
    address owner = address(this);
    address user = address(0xBEEF);

    function setUp() public {
        token = new ScarCoin();
    }

    function testInitialSupplyIsZero() public {
        assertEq(token.totalSupply(), 0);
    }

    function testOwnerCanMint() public {
        token.mint(user, 1e18);
        assertEq(token.balanceOf(user), 1e18);
    }
}
