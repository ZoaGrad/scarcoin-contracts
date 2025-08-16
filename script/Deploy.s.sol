// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/ScarCoin.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address scarIndexOracle = vm.envAddress("SCAR_INDEX_ORACLE");
        uint256 minAcheScore = vm.envOr("MIN_ACHE_SCORE", uint256(100));
        uint256 maxMintPerRitual = vm.envOr("MAX_MINT_PER_RITUAL", uint256(1000 * 1e18));
        
        vm.startBroadcast(deployerPrivateKey);
        
        ScarCoin scarCoin = new ScarCoin(
            scarIndexOracle,
            minAcheScore,
            maxMintPerRitual
        );
        
        vm.stopBroadcast();
        
        console.log("ScarCoin deployed to:", address(scarCoin));
        console.log("ScarIndex Oracle:", scarIndexOracle);
        console.log("Min Ache Score:", minAcheScore);
        console.log("Max Mint Per Ritual:", maxMintPerRitual);
    }
}