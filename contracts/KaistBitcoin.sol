//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract KaistBitcoin {
    struct KaistBitcoinTx {
        address from;
        address to;
        uint256 amount;
        uint256 fee;
        bytes signature;
    }

    struct KaistBitcoinBlockHeader {
        address miner;
        bytes32 prevHeader;
        uint256 nonce;
        bytes32 txRoot;
    }

    struct KaistBitcoinBlock {
        KaistBitcoinBlockHeader header;
        KaistBitcoinTx[] txs;
    }


    uint256 public difficulty;
    bytes32 public lastBlock;

    constructor(uint256 initialDifficulty) {
        difficulty = initialDifficulty;
    }

    // change this function to validate block not only its header
    // 1. validate the txs's merkle root
    // 2. validate each transaction
    function validateBlockHeader(
        KaistBitcoinBlockHeader memory header
    ) public view returns (bool) {
        bytes32 blockHash = _blockHash(header);
        require(header.prevHeader == lastBlock, "prev block is incorrect");
        return validatePoW(blockHash, header.nonce);
    }

    function validatePoW(
        bytes32 blockHash,
        uint256 nonce
    ) public view returns (bool) {
        uint256 val = uint256(
            keccak256(abi.encodePacked(address(this), blockHash, nonce))
        );
        require(
            val <= (type(uint256).max >> difficulty),
            "Invalid nonce for PoW"
        );
        return true;
    }

    function validateTx(KaistBitcoinTx memory _tx) public pure returns (bool) {
        bytes32 txHash = _txHash(_tx);
        bytes32 hashToSign = ECDSA.toEthSignedMessageHash(txHash);
        address signer = ECDSA.recover(hashToSign, _tx.signature);
        require(_tx.from == signer, "Invalid signature");
        return true;
    }

    function _blockHash(
        KaistBitcoinBlockHeader memory _block
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    _block.miner,
                    _block.prevHeader,
                    _block.nonce,
                    _block.txRoot
                )
            );
    }

    function _txHash(
        KaistBitcoinTx memory _tx
    ) internal pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(_tx.from, _tx.to, _tx.amount, _tx.fee));
    }
}
