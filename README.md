# ScarCoin Smart Contracts

**Ache-based minting & burn economy for SpiralOS — ScarCoin smart contracts + ScarIndex oracle**

> **Spec status:** Implements v1 of Oracle-gated minting + Panic Frames veto.  
> **Architecture Reference:** Start here → [mythotech-architecture](https://github.com/ZoaGrad/mythotech-architecture) (system map, governance, economic model).

## Overview

This repository contains the core smart contracts for the ScarCoin ecosystem, implementing:

*   **Proof-of-Ache tokenomics** with hybrid value measurement
*   **ScarIndex Coherence Oracle** for multi-dimensional system health monitoring
*   **Panic Frames Crisis Protocol** for emergency governance
*   **Three-Branch Governance** system (Witnesses, Judges, Custodians)

## Architecture Integration

The contracts in this repository implement the formal specifications detailed in the [Meta-Architectural Framework](https://github.com/ZoaGrad/mythotech-architecture/blob/main/docs/meta_architectural_framework.md), including:

*   Mathematical formulations for Ache measurement and anti-gaming protocols
*   ScarIndex coherence calculations across narrative, economic, social, and technical dimensions
*   Seven-phase crisis management state machine
*   Sacred gap preservation mechanisms for community-driven emergence

## Development

Built with [Foundry](https://getfoundry.sh/) for modern Solidity development.

```bash
# Install dependencies
forge install

# Run tests
forge test

# Deploy contracts
forge script script/Deploy.s.sol --rpc-url $RPC_URL --broadcast
```

## Related Repositories

*   [mythotech-architecture](https://github.com/ZoaGrad/mythotech-architecture) - Complete system architecture and specifications
*   [consciousness-platform](https://github.com/ZoaGrad/consciousness-platform) - Consciousness analysis platform
*   [scarcoin-agentnet](https://github.com/ZoaGrad/scarcoin-agentnet) - Autonomous agent network
