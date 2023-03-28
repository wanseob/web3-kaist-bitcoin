/* eslint-disable no-unused-expressions */
/* eslint-disable node/no-unsupported-features/es-syntax */
/* eslint-disable camelcase */
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { KaistBitcoin, KaistBitcoin__factory } from "../typechain";
import { parseEther } from "ethers/lib/utils";
import { buildTx, mineBlock } from "../src/utils";
import { randomBytes } from "crypto";

describe("Test Kaist Bitcoin Contract", function () {
  let kaistBitcoin: KaistBitcoin;
  let deployer: SignerWithAddress;
  let alice: SignerWithAddress;
  let bob: SignerWithAddress;
  let miner: SignerWithAddress;
  this.beforeEach(async () => {
    [deployer, alice, bob, miner] = await ethers.getSigners();
    const initialDifficulty = 0;
    kaistBitcoin = await new KaistBitcoin__factory(deployer).deploy(
      initialDifficulty
    );
  });
  it("validate tx", async function () {
    const tx = await buildTx({
      signer: alice,
      to: bob.address,
      amount: parseEther("1"),
      fee: parseEther("0.01"),
    });
    const result = await kaistBitcoin.validateTx(tx);
    expect(result).to.be.true;
  });
  it("validate header", async function () {
    const prevHeader = await kaistBitcoin.lastBlock();
    const difficulty = await kaistBitcoin.difficulty();
    const txRoot = randomBytes(32);
    const header = await mineBlock({
      address: kaistBitcoin.address,
      difficulty: difficulty.toNumber(),
      txRoot,
      miner: miner.address,
      prevHeader,
    });
    const result = await kaistBitcoin.validateBlockHeader(header);
    expect(result).to.be.true;
  });
});
