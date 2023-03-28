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

    function validateBlock(
        KaistBitcoinBlock memory _block
    ) public view returns (bool) {
        bytes32 blockHash = _blockHash(_block.header);
        require(_block.header.prevHeader == lastBlock, "prev block is incorrect");
        bytes32 txRoot = _txRoot(_block.txs);
        require(_block.header.txRoot == txRoot, "Tx root is incorrect");
        validatePoW(blockHash, _block.header.nonce);
        uint256 n = _block.txs.length;
        for (uint256 i = 0; i < n; i += 1) {
            validateTx(_block.txs[i]);
        }
        return true;
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


    function _txRoot(
        KaistBitcoinTx[] memory txs
    ) internal pure returns (bytes32) {
        bytes32[] memory leaves = new bytes32[](txs.length);
        uint256 n = txs.length;
        for (uint256 i = 0; i < n; i += 1) {
            leaves[i] = _txHash(txs[i]);
        }
        return _root(leaves);
    }

    function _root(bytes32[] memory leaves) internal pure returns (bytes32) {
        if (leaves.length == 0) return bytes32(0);
        uint256 n = leaves.length;
        bytes32[] memory hashes = new bytes32[](n << 1);
        uint256 cursor = 0;
        uint256 offset = 0;
        for (uint256 i = 0; i < leaves.length; i += 1) {
            hashes[cursor] = leaves[i];
            cursor += 1;
        }

        while (n > 0) {
            for (uint256 i = 0; i < n - 1; i += 2) {
                hashes[cursor] = keccak256(
                    abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
                );
                cursor += 1;
            }
            offset += n;
            n = n / 2;
        }
        return hashes[cursor - 1];
    }
}
