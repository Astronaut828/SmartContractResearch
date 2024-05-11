// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "dn404/src/DN404.sol";
import "dn404/src/DN404Mirror.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {LibString} from "solady/src/utils/LibString.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";

contract Shadowladys is DN404, Ownable {
    string private _name;
    string private _symbol;
    string private _baseURI;

    constructor() {
        _initializeOwner(msg.sender);

        _name = "Shadowladys DN404";
        _symbol = "SHADOW";
        _baseURI = "https://shadowladys.xyz/api/token/";

        address mirror = address(new DN404Mirror(msg.sender));
        _initializeDN404(10_000 * 10 ** 18, msg.sender, mirror);
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function _tokenURI(uint256 tokenId) internal view override returns (string memory result) {
        if (bytes(_baseURI).length != 0) {
            result = string(abi.encodePacked(_baseURI, LibString.toString(tokenId)));
        }
    }

    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }

    function withdraw() public onlyOwner {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }
}
