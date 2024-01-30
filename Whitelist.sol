// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Whitelist is Ownable2Step {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _whitelist;

    event AddedToWhitelist(address indexed addr);
    event RemovedFromWhitelist(address indexed addr);

    function isWhitelisted(address addr) public view returns (bool) {
        return _whitelist.contains(addr);
    }

    function addToWhitelist(address addr) external onlyOwner {
        require(addr != address(0), "Whitelist: error");
        require(!_whitelist.contains(addr), "Whitelist: error");

        _whitelist.add(addr);

        emit AddedToWhitelist(addr);
    }

    function removeFromWhitelist(address addr) external onlyOwner {
        require(addr != address(0), "Whitelist: error");
        require(_whitelist.contains(addr), "Whitelist: error");

        _whitelist.remove(addr);

        emit RemovedFromWhitelist(addr);
    }
}
