// SPDX-License-Identifier: UNLICENSED

pragma solidity =0.8.19;

import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {
    ERC165Storage
} from "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";
import {IPausable} from "./interfaces/IPausable.sol";

abstract contract PausableWithOwnable is Pausable, Ownable2Step, ERC165Storage {
    constructor() {
        _registerInterface(type(IPausable).interfaceId);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
