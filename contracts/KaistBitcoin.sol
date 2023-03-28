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

    function validateBlockHeader(
        KaistBitcoinBlockHeader memory header
    ) public view returns (bool) {
        bytes32 blockHash = _blockHash(header);
        // check prev header equals to the last submitted block;
        return validatePoW(blockHash, header.nonce);
    }

    function validatePoW(
        bytes32 blockHash,
        uint256 nonce
    ) public view returns (bool) {
        // implement PoW
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
        // return block hash
    }

    function _txHash(
        KaistBitcoinTx memory _tx
    ) internal pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(_tx.from, _tx.to, _tx.amount, _tx.fee));
    }
}
