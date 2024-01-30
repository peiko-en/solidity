// SPDX-License-Identifier: UNLICENSED

pragma solidity =0.8.19;

import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {
    ERC20Capped
} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {
    ERC20Burnable
} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {
    AccessControlDefaultAdminRules
} from "@openzeppelin/contracts/access/AccessControlDefaultAdminRules.sol";

contract Token is
    ERC20,
    ERC20Capped,
    ERC20Burnable,
    AccessControlDefaultAdminRules
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct Config {
        uint128 burnFeePercentage;
        uint128 adminFeePercentage;
    }

    Config private _config;

    mapping(address user => address admin) private _referrals;

    event UpdatedConfig(address indexed updater, Config config);

    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return
            interfaceId == type(IERC20).interfaceId ||
            interfaceId == type(ERC20Burnable).interfaceId ||
            interfaceId == type(ERC20Capped).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // Token functions
    function mint(
        address account,
        uint256 amount
    ) external onlyRole(MINTER_ROLE) {
        _mint(account, amount);
    }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        super.transfer(to, amount);
        _feesLogic(msg.sender, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        super.transferFrom(from, to, amount);
        _feesLogic(from, amount);

        return true;
    }

    function transferInit(
        address to,
        uint256 amount,
        address admin,
        string memory memo
    ) external returns (bool) {
        registerNewUser(admin, memo);
        transfer(to, amount);

        return true;
    }

    function _mint(
        address account,
        uint256 amount
    ) internal override(ERC20, ERC20Capped) {
        super._mint(account, amount);
    }

    function _feesLogic(address from, uint256 amount) private {
        (, uint256 adminFeeAmount, uint256 sumFeeAmount) = feesCalculator(
            amount
        );

        super.burn(sumFeeAmount);

        if (isRegisteredUser(from)) {
            _mint(_referrals[from], adminFeeAmount);
            emit TransferAdminFee(_referrals[from], from, adminFeeAmount);
        }
    }

    // Configuration functions
    function getConfig() external view returns (Config memory) {
        return _config;
    }

    function getConfigBurnFeePercentage() external view returns (uint128) {
        return _config.burnFeePercentage;
    }

    function getConfigAdminFeePercentage() external view returns (uint128) {
        return _config.adminFeePercentage;
    }

    function setConfig(
        Config memory config
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setConfigBurnFeePercentage(config.burnFeePercentage);
        _setConfigAdminFeePercentage(config.adminFeePercentage);

        emit UpdatedConfig(msg.sender, _config);
    }

    function setConfigBurnFeePercentage(
        uint128 burnFeePercentage
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setConfigBurnFeePercentage(burnFeePercentage);

        emit UpdatedConfig(msg.sender, _config);
    }

    function setConfigAdminFeePercentage(
        uint128 adminFeePercentage
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setConfigAdminFeePercentage(adminFeePercentage);

        emit UpdatedConfig(msg.sender, _config);
    }

    function _setConfigBurnFeePercentage(uint128 burnFeePercentage) private {
        require(
            burnFeePercentage <= maxFeePercentageDecimals(),
            "Token: error"
        );
        _config.burnFeePercentage = burnFeePercentage;
    }

    function _setConfigAdminFeePercentage(
        uint128 adminFeePercentage
    ) private {
        require(
            adminFeePercentage <= maxFeePercentageDecimals(),
            "Token: error"
        );
        _config.adminFeePercentage = adminFeePercentage;
    }
}
