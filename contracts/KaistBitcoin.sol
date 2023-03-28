//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

import "hardhat/console.sol";

contract KaistBitcoin {
    struct KaistBitcoinTx {
        address from;
        address to;
        uint256 amount;
        uint256 fee;
        bytes signature;
    }

    function validateTx(KaistBitcoinTx memory _tx) public pure returns (bool) {
        // verify signature
    }

    function _txHash(
        KaistBitcoinTx memory _tx
    ) internal pure returns (bytes32) {
        // return the hash of the transaction
    }
}
