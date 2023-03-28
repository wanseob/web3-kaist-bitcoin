/* eslint-disable no-unused-expressions */
/* eslint-disable node/no-unsupported-features/es-syntax */
/* eslint-disable camelcase */
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { KaistBitcoin, KaistBitcoin__factory } from "../typechain";

describe("Test Kaist Bitcoin Contract", function () {
  let kaistBitcoin: KaistBitcoin;
  let deployer: SignerWithAddress;
  this.beforeEach(async () => {
    [deployer] = await ethers.getSigners();
    kaistBitcoin = await new KaistBitcoin__factory(deployer).deploy();
  });
  it("should deploy a contract", async function () {
    expect(kaistBitcoin.address).to.be.a.string
  });
});
