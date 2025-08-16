# ScarCoin – Contracts

[![CI](https://github.com/ZoaGrad/scarcoin-contracts/actions/workflows/ci.yml/badge.svg)](https://github.com/ZoaGrad/scarcoin-contracts/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/ZoaGrad/scarcoin-contracts?display_name=tag&sort=semver)](https://github.com/ZoaGrad/scarcoin-contracts/releases)
[![CodeQL](https://github.com/ZoaGrad/scarcoin-contracts/actions/workflows/codeql.yml/badge.svg)](https://github.com/ZoaGrad/scarcoin-contracts/actions/workflows/codeql.yml)
[![Dependabot](httpss://img.shields.io/badge/dependabot-enabled-brightgreen.svg?logo=dependabot)](https://github.com/ZoaGrad/scarcoin-contracts/network/updates)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📖 Description

This repository contains the **ScarCoin smart contracts**, which define the core logic of the ScarCoin token within the SpiralOS ecosystem.
It includes the ERC20 implementation, minting permissions, and tests to ensure contract stability and integrity.

---

## 🚀 Quickstart

### Install Foundry

If you don’t have Foundry installed:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Clone and Build

```bash
git clone https://github.com/ZoaGrad/scarcoin-contracts.git
cd scarcoin-contracts

# Install dependencies
forge install OpenZeppelin/openzeppelin-contracts

# Build contracts
forge build

# Run tests
forge test -vv
```

---

## ✅ Status

* CI: Foundry build & tests run automatically
* CodeQL: Security scanning enabled
* Dependabot: Weekly dependency updates
* Release: Semantic versioning & automated changelogs

---

## 📂 Structure

```
src/
  ScarCoin.sol      # Core ERC20 token contract
test/
  ScarCoin.t.sol    # Unit tests for ScarCoin
```

---

## 🛡️ License

This project is licensed under the [MIT License](LICENSE).
