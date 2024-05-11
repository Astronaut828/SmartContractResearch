// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "dn404/src/DN404.sol";
import "dn404/src/DN404Mirror.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {LibString} from "solady/utils/LibString.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

contract Test404 is DN404, Ownable {
    string private _name;
    string private _symbol;
    string private _baseURI;

    constructor(
        string memory name_,
        string memory symbol_,
        uint96 initialTokenSupply,
        address initialSupplyOwner
    ) {
        _initializeOwner(msg.sender);

        _name = name_;
        _symbol = symbol_;

        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(initialTokenSupply, initialSupplyOwner, mirror);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function _tokenURI(
        uint256 tokenId
    ) internal view override returns (string memory result) {
        if (bytes(_baseURI).length != 0) {
            result = string(
                abi.encodePacked(_baseURI, LibString.toString(tokenId))
            );
        }
    }

    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }

    function withdraw() public onlyOwner {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }
}