# MasterChefV2 Research Project

## Research on the staking contract MasterChefV2

### Description✅

This research focuses on the MasterChefV2 staking contract, exploring its functionalities, benefits, and potential for templatization. MasterChefV2 is a staking contract that allows users to stake LP tokens to earn rewards. This research aims to understand how MasterChefV2 works, its key features, and how it can be templatized to create a staking contract template.

### Table of Contents

-   [Description](#description)✅
-   [Background](#background)✅
-   [How MasterChefV2 Works](#how-MasterChefV2-works)✅
-   [Key Features](#key-features)
-   [Research Questions](#research-questions)✅
-   [Researched Projects](#researched-projects-/-contracts)✅
-   [Test Contract](#test-contract)
-   [Implementation considerations](#implementation-considerations)
-   [Conclusion](#conclusion)

### Background✅

MasterChefV2 is a staking contract derived from the original MasterChef contract by SushiSwap, which was a fork of Uniswap. This contract manages the staking of liquidity provider (LP) tokens and distributes SUSHI rewards to stakers. Users receive LP tokens when providing liquidity to a decentralized exchange (DEX) and can stake these tokens in the MasterChefV2 contract to earn SUSHI rewards. MasterChefV2 also interacts with the original MasterChef contract (MCV1) to handle reward distribution. The staking mechanism in MasterChefV2, as well as its interaction with the MasterChef contract, are the focus of this research.

### How MasterChefV2 Works
**Staking Calculation and Reward Distribution**

The rewards mechanism involves the following steps:

1. **Setting up the pool:**

    The owner adds a pool with allocation points, an LP token, and a rewarder. Allocation points determine reward distribution among pools.

2. **Staking LP tokens:**

    Users deposit their LP tokens into a pool. The contract tracks each user’s deposited amount and updates reward variables.

3. **Reward Calculation:**

    The contract calculates SUSHI rewards for each user based on their staked amount and the pool’s allocation points. Rewards are distributed proportionally to the staked amount.


    **High-level overview of the rewards calculation:**

    The user's reward is calculated by dividing the user's staked amount (user.amount) by the total amount staked in the pool (lpSupply), and then multiplying this result by the reward rate per block (sushiPerBlock) and the number of blocks representing the amount of time (blocks). The user's pending reward is then updated based on the difference between the user's reward and the user's reward debt (user.rewardDebt).

4. **Updating Pools:**

    Pools are periodically updated to recalculate the accumulated SUSHI per share and the last reward block.
    
5. **Harvesting Rewards:**

    Users can harvest their pending SUSHI rewards.

<br>

### Key Features

-   **Staking Calculation and Reward Distribution**: 
    
    `updatePool` Function:
    - Updates reward variables for a specific pool.
    - Calculates the SUSHI reward for the pool and updates accSushiPerShare.

    ````solidity
    /// @notice Update reward variables of the given pool.
    /// @param pid The index of the pool. See `poolInfo`.
    /// @return pool Returns the pool that was updated.
    function updatePool(uint256 pid) public returns (PoolInfo memory pool) {
        pool = poolInfo[pid];
        if (block.number > pool.lastRewardBlock) {
            uint256 lpSupply = lpToken[pid].balanceOf(address(this));
            if (lpSupply > 0) {

            //subtracts the last reward block from the current block number
                uint256 blocks = block.number.sub(pool.lastRewardBlock);

            // calculates the SUSHI reward for the pool and divides it by the total allocation points
                uint256 sushiReward = blocks.mul(sushiPerBlock()).mul(pool.allocPoint) / totalAllocPoint;

            // adds the SUSHI reward per share to the accumulated SUSHI per share
                pool.accSushiPerShare = pool.accSushiPerShare.add((sushiReward.mul(ACC_SUSHI_PRECISION) / lpSupply).to128());
            }
            // updates the last reward block and the pool in the poolInfo mapping
            pool.lastRewardBlock = block.number.to64();

            poolInfo[pid] = pool;
            emit LogUpdatePool(pid, pool.lastRewardBlock, lpSupply, pool.accSushiPerShare);
        }
    }
    ````

-   **Migration of Liquidity**:
    The "Vampire Attack" is a term used to describe the migration of liquidity from one project to another. MasterChefV2 uses a migrator contract to facilitate the migration of LP tokens from the original MasterChef contract (MCV1) to the new MasterChefV2 contract. This allows users to migrate their LP tokens and continue earning rewards in the new contract. The migrator contract is a key feature of MasterChefV2 that enables the migration of liquidity and ensures a smooth transition for users.

    The migration is handled by the following functions in the MasterChefV2 contract:

    ```solidity
        /// @notice Set the `migrator` contract. Can only be called by the owner.
        /// @param _migrator The contract address to set.
        function setMigrator(IMigratorChef _migrator) public onlyOwner {
            migrator = _migrator;
        }

        /// @notice Migrate LP token to another LP contract through the `migrator` contract.
        /// @param _pid The index of the pool. See `poolInfo`.
        function migrate(uint256 _pid) public {
            require(address(migrator) != address(0), "MasterChefV2: no migrator set");
            IERC20 _lpToken = lpToken[_pid];
            uint256 bal = _lpToken.balanceOf(address(this));
            _lpToken.approve(address(migrator), bal);
            IERC20 newLpToken = migrator.migrate(_lpToken);
            require(bal == newLpToken.balanceOf(address(this)), "MasterChefV2: migrated balance must match");
            lpToken[_pid] = newLpToken;
        }
    ```
    

### Research Questions✅

-   **Can the MasterChefV2 functionality be templatized?** <br>
     Exploring the potential to templatize the MasterChefV2 functionality.

**Side Quests**:
-   **Value Increase**: How does the reward mechanism of MasterChefV2 work?
-   **Inventions**: taking a closer look at the migrator function and how the MasterChefV2 uses it to migrate LP tokens to a new contract.

### Researched Projects / Contracts:✅

**MasterChefV2**:

- Deployed Contract: [MasterChefV2 Contract](https://etherscan.io/address/0xef0881ec094552b2e128cf945ef17a6752b4ec5d#code)
- Deployed Contract: [MasterChef Contract](https://etherscan.io/address/0xc2edad668740f1aa35e4d8f227fb8e17dca888cd#code)

See also: [Local copy of project contracts](./examples)<br>

**SushiSwap Project**:
- Deployed Contract: [SushiMaker Contract](https://etherscan.io/address/0xe11fc0b43ab98eb91e9836129d1ee7c3bc95df50#code)
- Deployed Contract: [SushiXSwap Contract](https://etherscan.io/address/0x011e52e4e40cf9498c79273329e8827b21e2e581#code)
- Deployed Contract: [SushiToken Contract](https://etherscan.io/token/0x6b3595068778dd592e39a122f4f5a5cf09c90fe2#code)
- Deployed Contract: [BentoBoxV1 Contract](https://etherscan.io/address/0xf5bce5077908a1b7370b9ae04adc565ebd643966#code)


### Test Contract

**Deployed on Sepolia to explore the DN404 functionality**

-   **Deployed Contract**: 
-   **GitHub Repository**: 

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
