import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { randomBytes } from "crypto";
import { BigNumber, BigNumberish, BytesLike } from "ethers";
import { arrayify, hexZeroPad, solidityKeccak256 } from "ethers/lib/utils";

export type KaistBitcoinTx = {
  from: string;
  to: string;
  amount: BigNumberish;
  fee: BigNumberish;
  signature: BytesLike;
};

export type KaistBitcoinBlockHeader = {
  miner: string;
  prevHeader: BytesLike;
  nonce: BigNumberish;
  txRoot: BytesLike;
};

export const buildTx = async ({
  signer,
  to,
  amount,
  fee,
}: {
  signer: SignerWithAddress;
  to: string;
  amount: BigNumberish;
  fee: BigNumberish;
}) => {
  const tx = {
    from: signer.address,
    to,
    amount,
    fee,
  };
  const txHash = solidityKeccak256(
    ["address", "address", "uint256", "uint256"],
    [tx.from, tx.to, tx.amount, tx.fee]
  );
  const txWithSig: KaistBitcoinTx = {
    // eslint-disable-next-line node/no-unsupported-features/es-syntax
    ...tx,
    signature: await signer.signMessage(arrayify(txHash)),
  };
  return txWithSig;
};

export const mineBlock = async ({
  address,
  miner,
  difficulty,
  prevHeader,
  txs,
}: {
  address: string;
  miner: string;
  difficulty: number;
  prevHeader: BytesLike;
  txs: KaistBitcoinTx[];
}): Promise<KaistBitcoinBlockHeader> => {
  let mined: boolean = false;
  let nonce: BigNumberish = randomBytes(32);
  const txRoot = getTxRoot(txs);
  console.time("mine");
  while (!mined) {
    nonce = randomBytes(32);
    const headerHash = solidityKeccak256(
      ["address", "bytes32", "uint256", "bytes32"],
      [miner, prevHeader, nonce, txRoot]
    );
    const pow = solidityKeccak256(
      ["address", "bytes32", "uint256"],
      [address, headerHash, nonce]
    );
    if (
      BigNumber.from(pow).lt(
        BigNumber.from(
          "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
        ).shr(difficulty)
      )
    ) {
      mined = true;
      break;
    }
  }
  console.timeEnd("mine");
  return {
    miner,
    prevHeader,
    txRoot,
    nonce,
  };
};

export const getTxRoot = (txs: KaistBitcoinTx[]): BytesLike => {
  const txHashes = txs.map((tx) => {
    return solidityKeccak256(
      ["address", "address", "uint256", "uint256"],
      [tx.from, tx.to, tx.amount, tx.fee]
    );
  });
  return getMerkleRoot(txHashes);
};

export const getMerkleRoot = (leaves: BytesLike[]): BytesLike => {
  if (leaves.length === 0) return hexZeroPad("0x", 32);
  let n = leaves.length;
  const hashes = [];
  let offset = 0;
  for (let i = 0; i < leaves.length; i += 1) {
    hashes.push(leaves[i]);
  }

  while (n > 0) {
    for (let i = 0; i < n - 1; i += 2) {
      hashes.push(
        solidityKeccak256(
          ["bytes32", "bytes32"],
          [hashes[offset + i], hashes[offset + i + 1]]
        )
      );
    }
    offset += n;
    n = n / 2;
  }
  return hashes[hashes.length - 1];
};
