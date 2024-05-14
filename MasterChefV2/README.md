# DN404 Research Project

## Research on the Potential to Templatize the DN404

### Description

This research focuses on the DN404 token standard, an advancement over the ERC404, referred to as the "Divisible NFT Standard." This innovative approach bridges the functionalities of ERC-20 and ERC-721 tokens, enabling seamless exchanges and fractional ownership.

### Table of Contents

-   [Description](#description)
-   [Background](#background)
-   [How DN404 Works](#how-dn404-works)
-   [Key Features](#key-features)
-   [Research Questions](#research-questions)
-   [Researched Projects](#researched-projects)
-   [Test Contract](#test-contract)
-   [Implementation considerations](#implementation-considerations)
-   [Conclusion](#conclusion)

### Background

DN-404 and ERC-404 are transforming NFT transactions by integrating the functionalities of ERC-20 and ERC-721 tokens. DN-404 employs a dual-contract approach, enhancing efficiency and reducing transaction costs, while ensuring compatibility and security. This research explores the potential to templating the DN404 token standard, examining its features, benefits, and challenges.

### How DN404 Works

-   **Fractional Ownership**: If a wallet holds a full token, a corresponding NFT is minted. Additionally, the wallet can hold a fraction of the ERC-721 token, represented by ownership of a fraction of the ERC-20 token, allowing partial ownership.
-   **Dynamic Minting and Burning**: When transferring fractional tokens that result in holding less than one full token, the corresponding NFT is automatically burned, unless the entire token is transferred. This behavior includes an optional functionality to skip burn/remint actions to reduce transaction costs. Once a full token accumulates in a wallet, the contract automatically mints a new NFT.

### Key Features

-   **Fractional Ownership**: Enables ownership of partial tokens (ERC721) in form of ERC20 tokens. Allows users to own a fraction of an NFT, enhancing liquidity and accessibility. This feature is facilitated through the token balance mechanism, where ERC-20 token balances are used to represent fractional ownership of an NFT.

    [Link to INTERNAL MINT FUNCTIONS](https://github.com/Astronaut828/DN404Research/blob/76ed90e11312da04de08c90513a6b1e313c2efc0/DN404/DN404.sol#L412-L564)

-   **Pathing Mechanism**: This mechanism optimizes how data is stored and transferred by combining the information about token amounts and their unique identifiers (IDs) into a single data structure. Essentially, instead of storing and managing these pieces of information in separate places, they are integrated into one compact form. This is primarily implemented through the struct AddressData and its usage within the contract.

    ````solidity
    /// DN404.sol - line 120-132
    /// @dev Struct containing an address's token data and settings.
    struct AddressData {
        // Auxiliary data.
        uint88 aux;
        // Flags for `initialized` and `skipNFT`.
        uint8 flags;
        // The alias for the address. Zero means absence of an alias.
        uint32 addressAlias;
        // The number of NFT tokens.
        uint32 ownedLength;
        // The token balance in wei.
        uint96 balance;
    }


    /// DN404.sol - line 189
    /// Part of ```struct DN404Storage``` (Key component of the DN404 contract)
    mapping(address => AddressData) addressData;

    /// @dev Struct containing the base token contract storage.
    struct DN404Storage {
        // Current number of address aliases assigned.
        uint32 numAliases;
        // Next NFT ID to assign for a mint.
        uint32 nextTokenId;
        // The head of the burned pool.
        uint32 burnedPoolHead;
        // The tail of the burned pool.
        uint32 burnedPoolTail;
        // Total number of NFTs in existence.
        uint32 totalNFTSupply;
        // Total supply of tokens.
        uint96 totalSupply;
        // Address of the NFT mirror contract.
        address mirrorERC721;
        // Mapping of a user alias number to their address.
        mapping(uint32 => address) aliasToAddress;
        // Mapping of user operator approvals for NFTs.
        AddressPairToUint256RefMap operatorApprovals;
        // Mapping of NFT approvals to approved operators.
        mapping(uint256 => address) nftApprovals;
        // Bitmap of whether an non-zero NFT approval may exist.
        Bitmap mayHaveNFTApproval;
        // Bitmap of whether a NFT ID exists. Ignored if `_useExistsLookup()` returns false.
        Bitmap exists;
        // Mapping of user allowances for ERC20 spenders.
        AddressPairToUint256RefMap allowance;
        // Mapping of NFT IDs owned by an address.
        mapping(address => Uint32Map) owned;
        // The pool of burned NFT IDs.
        Uint32Map burnedPool;
        // Even indices: owner aliases. Odd indices: owned indices.
        Uint32Map oo;
        // Mapping of user account AddressData.
        mapping(address => AddressData) addressData;
    }
    ````

-   **Integration with Existing Protocols**: Ensures compatibility with ERC-20 and ERC-721 standards.

    [Link to INTERNAL TRANSFER FUNCTIONS](https://github.com/Astronaut828/DN404Research/blob/76ed90e11312da04de08c90513a6b1e313c2efc0/DN404/DN404.sol#L632-L878)

### Research Questions

-   **Can the DN404 be templatized?**: Exploring the potential for commercialization and the creation of a DN404-based Template.
    **Side Quests**:
-   **Value Increase**: How does the token gain in value, influenced by factors like rarity and potential overflow issues?
-   **System Integrity**: Addressing potential sibyl attacks and the implications of a cap on token distribution.

### Researched Projects

**ERC404**:

-   Pandora
    -   [Website](https://www.pandora.build)
    -   [GitHub](https://github.com/Pandora-Labs-Org)

**DN404**:

-   404aliens
    -   [Website](https://www.404aliens.com)
    -   [Deployed Contract](https://etherscan.io/address/0xD0d19F52Ad8705E60Ff31dF75a7ACa8F1399a69e#code)
-   DeezNuts
    -   [Website](https://www.deeznuts.gg)
    -   [Deployed Contract](https://etherscan.io/address/0xc7937b44532bf4c0a1f0de3a46c79dddb6dd169d#code)
-   Shadowladys
    -   [Website](https://www.shadowladys.xyz)
    -   [Deployed Contract](https://etherscan.io/token/0x46305B2eBcd92809d5fcEf577C20C28A185Af03c#code)
-   Asterix

    -   [Website](https://hub.xyz/asterix)

    **Deployed Contracts**:

    -   [Asterix](https://etherscan.io/token/0x0000000000ca73A6df4C58b84C5B4b847FE8Ff39?a=0xdae8f99814cc3aa541909ce07e59d0c208fedbb7#code)
    -   [AsterixMirror](https://etherscan.io/token/0x0000000000c26FAbFe894D13233d5ec73F61cc72#code)

See also: [Local copy of project contracts](https://github.com/Astronaut828/DN404Research/tree/main/examples)<br>
See also: [Local copy of DN404 contracts](https://github.com/Astronaut828/DN404Research/tree/main/DN404)

### Test Contract

**Deployed on Sepolia to explore the DN404 functionality**

-   **Deployed Contract**: View the functionality of the DN404 in action at [Sepolia Etherscan](https://sepolia.etherscan.io/address/0x5b749188351df7CEcBCC3b69a530eE6Be0DfC774#code).
-   **GitHub Repository**: Access the source code at [DN404Research](https://github.com/Astronaut828/DN404Research/blob/main/src/Test404.sol).

### Implementation considerations

-   **Implementing DN404 into a MetalDN404**

    -   Deployment of a DN404 as well as a DN404 Mirror to allow the template to interact with the DN404 contract
    -   Extensive Documentation
    -   User-friendly interface for users to interact with the DN404 interface contract (Template)
    -   Extensive testing to ensure the template is secure and interacts correctly with the DN404 contracts

-   **Metal frontend considerations to have a good UX**

    -   The MetalDN404 frontend should offer a user-friendly interface. This includes instructions on how to set up the NFT collection. Potentially a feature to upload the NFT collection to IPFS or other DB and provide the CID/URI to the contract. The frontend should also provide clear information on the user's DN404 token data like initial supply, current supply, and the current price of the DN404 token since finding this information on the many platforms involved in the DN404 token can be difficult. (DexTools (ERC20), Opensea (ERC721), Etherscan (Contract), etc.)
    -   Documentation: The implementation process should be well-documented to ensure that users can easily understand and utilize the MetalDN404.
        This includes providing clear instructions on how to set up a NFT collection to provide the necessary base URI/metadata for the ERC721 part of the DN404 token. As well as documentation for users to buy/sell/trade their ERC20 tokens as well as sell their ERC721 tokens and an explanation of the burn/mint process of the DN404 token.
    -   Overall administrative tools and controls for managing the contract post-deployment.

-   **Implementation time considerations**
    -   The implementation of DN404 into a MetalDN404 would require a significant amount of time to ensure that the contract is secure, interacts correctly with the DN404 and that the frontend is user-friendly. This includes testing the contract for vulnerabilities and ensuring that the contract is secure against potential attacks, like sibyl attacks. The implementation that is used by the Asterix project shows that the DN404 can be complex and require a significant amount of time to implement safe and correctly. The synchronous transactions between DN404 and its Mirror contract can be a challenge to implement correctly when used in a MetalDN404.

### Conclusion

The introduction of DN-404 and ERC-404 tokens showcases the evolving capabilities of Smart Contracts and their impact on NFT fractionalization. However, the potential to templatize the DN404 requires users to have foundational knowledge of an NFT collection, meaning they must possess a collection of NFTs to utilize the DN404 functionality effectively. This could be a barrier to entry for some users, who need to create and host art in a way that allows the DN404 token to be minted correctly. Understanding the fractionalization of NFTs and the minting of the DN404 token can also a barrier for some. The burning and reminting of ERC-721 tokens, as well as fractional ownership through owning ERC-20 tokens, is a complex process that requires an understanding of ERC Tokens, including transfer, burning, and minting processes. All this being said, to deploy a DN404 and developing a project out of it has multiple facets that I am not discussing here, like setting up a community hub for the project's NFT holders and marketing the project. The DN404 token is a powerful tool for NFT fractionalization, but it requires a significant amount of time and effort to implement correctly.
