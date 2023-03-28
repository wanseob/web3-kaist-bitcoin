/* eslint-disable no-unused-expressions */
/* eslint-disable node/no-unsupported-features/es-syntax */
/* eslint-disable camelcase */
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { KaistBitcoin, KaistBitcoin__factory } from "../typechain";
import { parseEther } from "ethers/lib/utils";
import { buildTx } from "../src/utils";

describe("Test Kaist Bitcoin Contract", function () {
  let kaistBitcoin: KaistBitcoin;
  let deployer: SignerWithAddress;
  let alice: SignerWithAddress;
  let bob: SignerWithAddress;
  this.beforeEach(async () => {
    [deployer, alice, bob] = await ethers.getSigners();
    kaistBitcoin = await new KaistBitcoin__factory(deployer).deploy();
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
});
