// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./DN404/DN404.sol";
import "./DN404/DN404Mirror.sol";
import {Ownable} from "https://github.com/Vectorized/solady/blob/main/src/auth/Ownable.sol";
import {LibString} from "https://github.com/Vectorized/solady/blob/main/src/utils/LibString.sol";
import {SafeTransferLib} from "https://github.com/Vectorized/solady/blob/main/src/utils/SafeTransferLib.sol";

/* Uses deployer contract to deploy DeezNutsToken contract with a salt
// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import "./DeezNutsToken.sol";

contract Deployer is Ownable {
    constructor(uint256 _salt, address owner) {
        bytes32 salt = keccak256(abi.encodePacked(_salt, owner));
        DeezNutsToken _contract = new DeezNutsToken{salt: salt}("Deez Nuts", "DN", 4269 ether, owner);
        _contract.transferOwnership(owner);
    }
}
*/

contract DeezNutsToken is DN404, Ownable {
    string private _name;
    string private _symbol;
    string private _baseURI;

    constructor(string memory name_, string memory symbol_, uint96 initialTokenSupply, address initialSupplyOwner) {
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

    function tokenURI(uint256 tokenId) public view override returns (string memory result) {
        if (bytes(_baseURI).length != 0) {
            result = string(abi.encodePacked(_baseURI, LibString.toString(tokenId)));
        }
    }

    // This allows the owner of the contract to mint more tokens.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }

    /// @dev Sets the caller's skipNFT flag to `skipNFT`
    ///
    /// Emits a {SkipNFTSet} event.
    function setSkipNFT(address account, bool skipNFT) public onlyOwner {
        _setSkipNFT(account, skipNFT);
    }

    function withdraw() public onlyOwner {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }
}
