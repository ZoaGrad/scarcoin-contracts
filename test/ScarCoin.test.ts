import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ScarCoin, ScarIndexOracle } from "../typechain-types";

describe("ScarCoin", function () {
  const MINT_THRESHOLD = 500_000; // 0.5
  const MINT_AMOUNT = ethers.parseEther("100"); // 100 tokens with 18 decimals

  async function deployContractsFixture(): Promise<{
    oracle: ScarIndexOracle;
    coin: ScarCoin;
    owner: any;
    user: any;
  }> {
    const [owner, user] = await ethers.getSigners();

    // Deploy the oracle first
    const OracleFactory = await ethers.getContractFactory("ScarIndexOracle");
    const oracle = await OracleFactory.deploy(owner.address, MINT_THRESHOLD); // Start with index = threshold
    await oracle.waitForDeployment();
    const oracleAddress = await oracle.getAddress();

    // Deploy the ScarCoin contract
    const CoinFactory = await ethers.getContractFactory("ScarCoin");
    const coin = await CoinFactory.deploy(owner.address, oracleAddress);
    await coin.waitForDeployment();

    return { oracle, coin, owner, user };
  }

  describe("Deployment", function () {
    it("Should set the correct oracle address", async function () {
      const { coin, oracle } = await loadFixture(deployContractsFixture);
      expect(await coin.oracle()).to.equal(await oracle.getAddress());
    });

    it("Should set the correct default mint threshold", async function () {
      const { coin } = await loadFixture(deployContractsFixture);
      expect(await coin.mintThreshold()).to.equal(MINT_THRESHOLD);
    });

    it("Should set the right owner", async function () {
      const { coin, owner } = await loadFixture(deployContractsFixture);
      expect(await coin.owner()).to.equal(owner.address);
    });
  });

  describe("Minting Logic", function () {
    it("Should FAIL to mint when oracle index is BELOW threshold", async function () {
      const { oracle, coin, user } = await loadFixture(deployContractsFixture);

      // Lower the index so it's below the threshold
      const newIndex = MINT_THRESHOLD - 1;
      await oracle.updateIndex(newIndex);

      await expect(coin.connect(user).mint(MINT_AMOUNT))
        .to.be.revertedWithCustomError(coin, "MintingNotAllowed")
        .withArgs(newIndex, MINT_THRESHOLD);
    });

    it("Should SUCCEED to mint when oracle index is EQUAL to threshold", async function () {
      const { coin, user } = await loadFixture(deployContractsFixture); // Index is at threshold by default in fixture

      await expect(coin.connect(user).mint(MINT_AMOUNT)).to.not.be.reverted;

      expect(await coin.balanceOf(user.address)).to.equal(MINT_AMOUNT);
    });

    it("Should SUCCEED to mint when oracle index is ABOVE threshold", async function () {
      const { oracle, coin, user } = await loadFixture(deployContractsFixture);

      // Raise the index
      await oracle.updateIndex(MINT_THRESHOLD + 1);

      await expect(coin.connect(user).mint(MINT_AMOUNT)).to.not.be.reverted;

      expect(await coin.balanceOf(user.address)).to.equal(MINT_AMOUNT);
    });
  });

  describe("Burning Logic", function () {
    it("Should allow a user to burn their own tokens", async function () {
      const { coin, user } = await loadFixture(deployContractsFixture);

      // First, mint some tokens to the user
      await coin.connect(user).mint(MINT_AMOUNT);
      expect(await coin.balanceOf(user.address)).to.equal(MINT_AMOUNT);

      // Now, burn half of them
      const burnAmount = ethers.parseEther("50");
      await coin.connect(user).burn(burnAmount);

      const expectedBalance = MINT_AMOUNT - burnAmount;
      expect(await coin.balanceOf(user.address)).to.equal(expectedBalance);
    });

    it("Should emit a Transfer event to the zero address on burn", async function () {
        const { coin, user } = await loadFixture(deployContractsFixture);
        await coin.connect(user).mint(MINT_AMOUNT);

        await expect(coin.connect(user).burn(MINT_AMOUNT))
            .to.emit(coin, "Transfer")
            .withArgs(user.address, ethers.ZeroAddress, MINT_AMOUNT);
    });

    it("Should fail to burn more tokens than the user has", async function () {
        const { coin, user } = await loadFixture(deployContractsFixture);
        await coin.connect(user).mint(MINT_AMOUNT);

        const overburnAmount = ethers.parseEther("101");
        await expect(coin.connect(user).burn(overburnAmount))
            .to.be.revertedWithCustomError(coin, "ERC20InsufficientBalance");
    });
  });

  describe("Owner Functions", function () {
    it("Should allow owner to update the oracle address", async function () {
      const { coin, owner } = await loadFixture(deployContractsFixture);
      const newOracleAddress = ethers.Wallet.createRandom().address;

      await expect(coin.connect(owner).setOracle(newOracleAddress))
        .to.emit(coin, "OracleUpdated")
        .withArgs(newOracleAddress);

      expect(await coin.oracle()).to.equal(newOracleAddress);
    });

    it("Should NOT allow non-owner to update the oracle address", async function () {
      const { coin, user } = await loadFixture(deployContractsFixture);
      const newOracleAddress = ethers.Wallet.createRandom().address;

      await expect(
        coin.connect(user).setOracle(newOracleAddress)
      ).to.be.revertedWithCustomError(coin, "OwnableUnauthorizedAccount").withArgs(user.address);
    });

    it("Should allow owner to update the mint threshold", async function () {
      const { coin, owner } = await loadFixture(deployContractsFixture);
      const newThreshold = 1_000_000;

      await expect(coin.connect(owner).setMintThreshold(newThreshold))
        .to.emit(coin, "ThresholdUpdated")
        .withArgs(newThreshold);

      expect(await coin.mintThreshold()).to.equal(newThreshold);
    });

    it("Should NOT allow non-owner to update the mint threshold", async function () {
      const { coin, user } = await loadFixture(deployContractsFixture);
      const newThreshold = 1_000_000;

      await expect(
        coin.connect(user).setMintThreshold(newThreshold)
      ).to.be.revertedWithCustomError(coin, "OwnableUnauthorizedAccount").withArgs(user.address);
    });
  });
});
