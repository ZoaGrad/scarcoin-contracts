import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "dotenv/config";

// Process environment variables
const amoyRpcUrl = process.env.AMOY_RPC_URL || "https://rpc-amoy.polygon.technology";
const privateKey = process.env.PRIVATE_KEY || "";
const polygonscanApiKey = process.env.POLYGONSCAN_API_KEY || "";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    hardhat: {
      // For local testing
    },
    amoy: {
      url: amoyRpcUrl,
      accounts: privateKey ? [privateKey] : [],
      chainId: 80002,
    },
  },
  etherscan: {
    apiKey: {
      polygonAmoy: polygonscanApiKey,
    },
    customChains: [
      {
        network: "polygonAmoy",
        chainId: 80002,
        urls: {
          apiURL: "https://api-amoy.polygonscan.com/api",
          browserURL: "https://amoy.polygonscan.com"
        }
      }
    ]
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 40000
  }
};

export default config;
