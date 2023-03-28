import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BigNumberish, BytesLike } from "ethers";
import { arrayify, solidityKeccak256 } from "ethers/lib/utils";

export type KaistBitcoinTx = {
  from: string;
  to: string;
  amount: BigNumberish;
  fee: BigNumberish;
  signature: BytesLike;
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
