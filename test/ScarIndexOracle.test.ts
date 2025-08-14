import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { ScarIndexOracle } from "../typechain-types";

describe("ScarIndexOracle", function () {
  // We define a fixture to reuse the same setup in every test.
  async function deployOracleFixture(): Promise<{ oracle: ScarIndexOracle; owner: any; otherAccount: any; }> {
    const [owner, otherAccount] = await ethers.getSigners();

    const initialIndex = 600_000; // 0.600000

    const OracleFactory = await ethers.getContractFactory("ScarIndexOracle");
    const oracle = await OracleFactory.deploy(owner.address, initialIndex);
    await oracle.waitForDeployment();

    return { oracle, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { oracle, owner } = await loadFixture(deployOracleFixture);
      expect(await oracle.owner()).to.equal(owner.address);
    });

    it("Should set the initial index correctly", async function () {
      const { oracle } = await loadFixture(deployOracleFixture);
      const initialIndex = 600_000;
      expect(await oracle.getIndex()).to.equal(initialIndex);
    });

    it("Should emit an IndexUpdated event on deployment", async function () {
      const [owner] = await ethers.getSigners();
      const initialIndex = 600_000;
      const OracleFactory = await ethers.getContractFactory("ScarIndexOracle");
      const oracle = await OracleFactory.deploy(owner.address, initialIndex);
      await oracle.waitForDeployment();

      const tx = oracle.deploymentTransaction();
      // The transaction hash is available on the deployment transaction
      await expect(tx)
        .to.emit(oracle, "IndexUpdated")
        .withArgs(initialIndex);
    });
  });

  describe("Functionality", function () {
    it("Should allow the owner to update the index", async function () {
      const { oracle } = await loadFixture(deployOracleFixture);
      const newIndex = 800_000; // 0.800000

      await expect(oracle.updateIndex(newIndex))
        .to.emit(oracle, "IndexUpdated")
        .withArgs(newIndex);

      expect(await oracle.getIndex()).to.equal(newIndex);
    });

    it("Should NOT allow non-owners to update the index", async function () {
      const { oracle, otherAccount } = await loadFixture(deployOracleFixture);
      const newIndex = 800_000;

      await expect(
        oracle.connect(otherAccount).updateIndex(newIndex)
      ).to.be.revertedWithCustomError(oracle, "OwnableUnauthorizedAccount").withArgs(otherAccount.address);
    });

    it("Should return the correct index via getIndex()", async function () {
      const { oracle } = await loadFixture(deployOracleFixture);
      const newIndex = 1_234_567;

      await oracle.updateIndex(newIndex);

      expect(await oracle.getIndex()).to.equal(newIndex);
    });
  });
});
