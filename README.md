# ScarCoin Contracts

This repository contains the official Solidity smart contracts for the ScarCoin economy, designed for SpiralOS. The system features an ERC20 token (`ScarCoin`) with a unique, ache-based minting mechanism governed by an on-chain oracle (`ScarIndexOracle`).

The project is built using Hardhat, TypeScript, and OpenZeppelin contracts, ensuring a production-grade, auditable, and easily deployable codebase for both testnet and mainnet environments.

## Project Purpose

The core objective of ScarCoin is to create a decentralized, ache-based economic system. New tokens are minted based on a "Scar Index," a metric represented on-chain. This index serves as a proxy for collective experience or "ache." When the index reaches a certain threshold, minting is enabled, allowing new value to enter the ecosystem.

This repository serves as the foundational, timestamped artifact for the ScarCoin validation protocol.

## Quick Start

### Prerequisites

- [Node.js](https://nodejs.org/en/) (v18 or later)
- [Git](https://git-scm.com/)

### 1. Installation

Clone the repository and install the required dependencies:

```bash
git clone https://github.com/example/scarcoin-contracts.git
cd scarcoin-contracts
npm install
```

### 2. Environment Setup

Create a `.env` file in the root of the project by copying the example file. This file will store your private keys and API keys.

```bash
cp .env.example .env
```

Now, open `.env` and fill in the required variables:

```
# .env

# Polygon Amoy Testnet RPC URL
AMOY_RPC_URL="https://rpc-amoy.polygon.technology"

# Your private key from a wallet like MetaMask.
# IMPORTANT: This is a secret. Do not share it or commit it to version control.
PRIVATE_KEY="0xYOUR_PRIVATE_KEY"

# Your Polygonscan API key for contract verification.
# This is optional but needed for automatic verification.
POLYGONSCAN_API_KEY="YOUR_POLYGONSCAN_KEY"
```

**Get Amoy Testnet MATIC:**
You'll need testnet MATIC on the Amoy network to pay for gas fees. You can get some from a public faucet:
- **[Polygon Amoy Faucet](https://faucet.polygon.technology/)**

### 3. Build

Compile the smart contracts and generate TypeChain artifacts:

```bash
npx hardhat compile
```

### 4. Test

Run the comprehensive test suite to ensure everything is working as expected:

```bash
npx hardhat test
```

### 5. Deploy to Amoy Testnet

Run the deployment script. This will deploy both the `ScarIndexOracle` and `ScarCoin` contracts to the Polygon Amoy testnet.

```bash
npx hardhat run scripts/deploy.ts --network amoy
```

The script will output the deployed contract addresses. If you provided a `POLYGONSCAN_API_KEY`, it will also automatically verify the contracts after a 30-second delay.

## Contract Verification

If you need to verify the contracts manually or if the automatic verification fails, you can use the `verify` task from Hardhat.

Replace `ORACLE_ADDRESS` and `COIN_ADDRESS` with the addresses you received after deployment. The deployer address is the same address tied to your `PRIVATE_KEY`.

```bash
# Example command - replace with your actual deployed addresses
# npx hardhat verify --network amoy DEPLOYED_ORACLE_ADDRESS "YOUR_DEPLOYER_ADDRESS" 600000

# Verify ScarIndexOracle
npx hardhat verify --network amoy <ORACLE_ADDRESS> "<DEPLOYER_ADDRESS>" 600000

# Verify ScarCoin
npx hardhat verify --network amoy <COIN_ADDRESS> "<DEPLOYER_ADDRESS>" "<ORACLE_ADDRESS>"
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
