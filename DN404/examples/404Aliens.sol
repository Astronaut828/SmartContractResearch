// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {DN404} from "dn404/src/DN404.sol";
import {DN404Mirror} from "dn404/src/DN404Mirror.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {LibString} from "solady/utils/LibString.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {ReentrancyGuard} from "solady/utils/ReentrancyGuard.sol";
import {Pausable} from "../openzeppelin/Pausable.sol";

contract Aliens404 is DN404, Ownable, ReentrancyGuard, Pausable {
    string private _name;
    string private _symbol;
    string private _baseURI;

    address public claimTokenAddress;

    constructor(
        string memory name_,
        string memory symbol_,
        uint96 initialTokenSupply,
        address initialSupplyOwner,
        address _claimTokenAddress
    ) {
        _initializeOwner(msg.sender);

        _name = name_;
        _symbol = symbol_;
        claimTokenAddress = _claimTokenAddress;

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
            result = string(abi.encodePacked(_baseURI, LibString.toString(tokenId), ".json"));
        }
    }

    // This allows the owner of the contract to mint more tokens.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function setBaseURI(string calldata baseURI_) public onlyOwner {
        _baseURI = baseURI_;
    }

    function withdraw() public onlyOwner {
        SafeTransferLib.safeTransferAllETH(msg.sender);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unPause() public onlyOwner {
        _unpause();
    }

    function setClaimTokenAddress(address newClaimTokenAddress) external onlyOwner {
        claimTokenAddress = newClaimTokenAddress;
    }

    function exchangeTokens(uint256 amount) external nonReentrant whenNotPaused {
        require(amount > 0, "Amount must be greater than 0");

        IERC20 claimToken = IERC20(claimTokenAddress);

        // Transfer external tokens from the caller to the contract
        require(claimToken.transferFrom(msg.sender, address(this), amount), "Failed to transfer tokens for burning");

        // Transfer the equivalent amount of 404Aliens tokens to the caller
        _transfer(address(this), msg.sender, amount);
    }

    function withdraw404Tokens(uint256 amount) public onlyOwner {
        _transfer(address(this), msg.sender, amount);
    }

    function setSkipNFTAddress(address a, bool state) public onlyOwner {
        _setSkipNFT(a, state);
    }
}
