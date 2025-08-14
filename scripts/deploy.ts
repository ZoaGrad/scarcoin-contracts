import { ethers, run } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // --- Deploy ScarIndexOracle ---
  const initialIndex = 600_000; // 0.600000
  console.log(`Deploying ScarIndexOracle with initial index: ${initialIndex}`);

  const oracleFactory = await ethers.getContractFactory("ScarIndexOracle");
  const oracle = await oracleFactory.deploy(deployer.address, initialIndex);
  await oracle.waitForDeployment();
  const oracleAddress = await oracle.getAddress();
  console.log(`ScarIndexOracle deployed to: ${oracleAddress}`);

  // --- Deploy ScarCoin ---
  console.log(`Deploying ScarCoin and linking it with oracle at ${oracleAddress}`);
  const coinFactory = await ethers.getContractFactory("ScarCoin");
  const coin = await coinFactory.deploy(deployer.address, oracleAddress);
  await coin.waitForDeployment();
  const coinAddress = await coin.getAddress();
  console.log(`ScarCoin deployed to: ${coinAddress}`);

  // --- Auto-verification ---
  if (process.env.POLYGONSCAN_API_KEY) {
    console.log("POLYGONSCAN_API_KEY found, waiting 30 seconds before attempting verification...");
    await new Promise(resolve => setTimeout(resolve, 30000)); // Wait 30s for block propagation

    try {
      console.log("Verifying ScarIndexOracle...");
      await run("verify:verify", {
        address: oracleAddress,
        constructorArguments: [deployer.address, initialIndex],
      });
      console.log("ScarIndexOracle verified successfully.");
    } catch (error) {
      console.error("Verification for ScarIndexOracle failed:", error);
    }

    try {
      console.log("Verifying ScarCoin...");
      await run("verify:verify", {
        address: coinAddress,
        constructorArguments: [deployer.address, oracleAddress],
      });
      console.log("ScarCoin verified successfully.");
    } catch (error) {
      console.error("Verification for ScarCoin failed:", error);
    }
  } else {
    console.log("Skipping verification: POLYGONSCAN_API_KEY not found in .env");
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
