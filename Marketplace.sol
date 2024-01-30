// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

// Contracts
import {ERC1155} from "openzeppelin/token/ERC1155/ERC1155.sol";
import {ERC1155URIStorage} from "openzeppelin/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {ERC1155Burnable} from "openzeppelin/token/ERC1155/extensions/ERC1155Burnable.sol";
import {EIP712} from "openzeppelin/utils/cryptography/EIP712.sol";
import {AccessControlDefaultAdminRules} from "openzeppelin/access/extensions/AccessControlDefaultAdminRules.sol";
import {ERC1155Supply} from "./extensions/ERC1155Supply.sol";
import {ERC1155Pausable} from "./extensions/ERC1155Pausable.sol";
import {ERC1155Mintable} from "./extensions/ERC1155Mintable.sol";
import {ERC165Storage} from "./extensions/ERC165Storage.sol";

// Interfaces
import {IAccessControlDefaultAdminRules} from "openzeppelin/access/extensions/IAccessControlDefaultAdminRules.sol";
import {IMarketplace} from "./IMarketplace.sol";
import {IERC1155Supply} from "./interfaces/IERC1155Supply.sol";
import {IERC1155Pausable} from "./interfaces/IERC1155Pausable.sol";
import {IERC1155Mintable} from "./interfaces/IERC1155Mintable.sol";
import {IERC1155Burnable} from "./interfaces/IERC1155Burnable.sol";

// Utils
import {Signatures} from "./utils/Signatures.sol";
import {Messages} from "./utils/Messages.sol";
import {Roles} from "./utils/Roles.sol";

contract Marketplace is
    IMarketplace,
    ERC1155,
    ERC1155Supply,
    ERC1155Mintable,
    ERC1155Burnable,
    ERC1155Pausable,
    ERC1155URIStorage,
    EIP712,
    AccessControlDefaultAdminRules,
    ERC165Storage
{
    using Signatures for Signatures.Signature;
    using Messages for Messages.RedeemMessage;

    function uri(uint256 tokenId) public view override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return ERC1155URIStorage.uri(tokenId);
    }

    function setURI(uint256 tokenId, string memory tokenURI) public onlyRole(Roles.MANAGER_ROLE) {
        ERC1155URIStorage._setURI(tokenId, tokenURI);
    }

    function setBaseURI(string memory baseURI) public onlyRole(Roles.MANAGER_ROLE) {
        ERC1155URIStorage._setBaseURI(baseURI);
    }

    function pause() public override onlyRole(Roles.MANAGER_ROLE) {
        ERC1155Pausable.pause();
    }

    function unpause() public override onlyRole(Roles.MANAGER_ROLE) {
        ERC1155Pausable.unpause();
    }

    function mint(address account, uint256 id, uint256 value, bytes memory data)
        public
        override
        whenNotPaused
        onlyRole(Roles.MINTER_ROLE)
    {
        ERC1155Mintable.mint(account, id, value, data);
    }

    function mintBatch(address account, uint256[] memory ids, uint256[] memory values, bytes memory data)
        public
        override
        whenNotPaused
        onlyRole(Roles.MINTER_ROLE)
    {
        ERC1155Mintable.mintBatch(account, ids, values, data);
    }

    function burn(address account, uint256 id, uint256 value) public override whenNotPaused {
        ERC1155Burnable.burn(account, id, value);
    }

    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) public override whenNotPaused {
        ERC1155Burnable.burnBatch(account, ids, values);
    }
}
