# MasterChefV2 Research Project

## Research on the staking contract MasterChefV2

### Description

This research focuses on the MasterChefV2 staking contract, exploring its functionalities, benefits, and potential for a template creation. MasterChefV2 is a staking contract that allows users to stake LP tokens to earn rewards. This research aims to understand how MasterChefV2 works, its key features, and how it can be templatized to create a staking contract template.

### Table of Contents

-   [Description](#description)
-   [Background](#background)
-   [How MasterChefV2 Works](#how-MasterChefV2-works)
-   [Key Features](#key-features)
-   [Research Questions](#research-questions)
-   [Researched Contracts](#researched-contracts)
-   [Implementation considerations](#implementation-considerations)
-   [Conclusion](#conclusion)

### Background

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

    `deposit` Function:

    -   Allows users to deposit LP tokens into the pool and updates their reward debt.

    ```solidity
    function deposit(uint256 pid, uint256 amount, address to) public {

    // updates the pool and user information
        PoolInfo memory pool = updatePool(pid);
        UserInfo storage user = userInfo[pid][to];

    // updates the user's deposited amount and reward debt (amount of SUSHI per share multiplied by the user's staked amount)
        user.amount = user.amount.add(amount);
        user.rewardDebt = user.rewardDebt.add(int256(amount.mul(pool.accSushiPerShare) / ACC_SUSHI_PRECISION));

    // calls the rewarder interface to handle the reward distribution
        IRewarder _rewarder = rewarder[pid];
        if (address(_rewarder) != address(0)) {
            _rewarder.onSushiReward(pid, to, to, 0, user.amount);
        }

    // transfers the LP tokens from the user to the contract
        lpToken[pid].safeTransferFrom(msg.sender, address(this), amount);

        emit Deposit(msg.sender, pid, amount, to);
    }
    ```

    [StakingRewardsSushi contract for more details on IRewarder](./examples/StakingRewardsSushi.sol)
    <br>
    <br>

    `updatePool` Function:

    -   Updates reward variables for a specific pool.
    -   Calculates the SUSHI reward for the pool and updates accSushiPerShare.

    ```solidity
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
    ```

    `sushiPerBlock` Function:

    -   Calculates the amount of SUSHI distributed per block.

    ```solidity
    function sushiPerBlock() public view returns (uint256 amount) {

    // calculates the SUSHI reward per block by multiplying the reward amount by the pool's allocation points
        amount = uint256(MASTERCHEF_SUSHI_PER_BLOCK)
            .mul(MASTER_CHEF.poolInfo(MASTER_PID).allocPoint) / MASTER_CHEF.totalAllocPoint();
    }
    ```

    `pendingSushi` Function:

    -   Calculates the pending SUSHI rewards for a user in a specific pool.

    ```solidity
    function pendingSushi(uint256 _pid, address _user) external view returns (uint256 pending) {
        PoolInfo memory pool = poolInfo[_pid];

    // retrieves the user's information from the userInfo mapping for the specified pool
        UserInfo storage user = userInfo[_pid][_user];

    // retrieves the accumulated SUSHI per share from the pool
        uint256 accSushiPerShare = pool.accSushiPerShare;

    // retrieves the LP token balance of the pool
        uint256 lpSupply = lpToken[_pid].balanceOf(address(this));

    // checks if the current block number is greater than the last reward block and the LP supply is not zero
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {

    // calculates the blocks since the last reward block by subtracting the last reward block from the current block number
            uint256 blocks = block.number.sub(pool.lastRewardBlock);

    // calculates the SUSHI reward for the pool by multiplying the reward per block by the number of blocks and then dividing by the total allocation points of the pool
            uint256 sushiReward = blocks.mul(sushiPerBlock()).mul(pool.allocPoint) / totalAllocPoint;

    // adds the SUSHI reward per share to the accumulated SUSHI per share
            accSushiPerShare = accSushiPerShare.add(sushiReward.mul(ACC_SUSHI_PRECISION) / lpSupply);
        }

    // calculates the user's pending SUSHI rewards by subtracting the user's reward debt from the user's staked amount multiplied by the accumulated SUSHI per share
    // rewardDebt is the amount of SUSHI the user is entitled to but has not claimed yet (used to track the user's rewards)
        pending = int256(user.amount.mul(accSushiPerShare) / ACC_SUSHI_PRECISION).sub(user.rewardDebt).toUInt256();
    }
    ```

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

### Research Questions

-   **Can the MasterChefV2 functionality be templatized?** <br>
    Exploring the potential to templatize the MasterChefV2 functionality.

**Side Quests**:

-   **Value Increase**: How does the reward mechanism of MasterChefV2 work?
-   **Inventions**: taking a closer look at the migrator function and how the MasterChefV2 uses it to migrate LP tokens to a new contract.

### Researched Contracts:

**MasterChefV2**:

-   Deployed Contract: [MasterChefV2 Contract](https://etherscan.io/address/0xef0881ec094552b2e128cf945ef17a6752b4ec5d#code)
-   Deployed Contract: [MasterChef Contract](https://etherscan.io/address/0xc2edad668740f1aa35e4d8f227fb8e17dca888cd#code)

See also: [Local copy of project contracts](./examples)<br>

**SushiSwap Project**:

-   Deployed Contract: [StakingRewardsSushi Contract](https://etherscan.io/address/0x75ff3dd673ef9fc459a52e1054db5df2a1101212#code)
-   Deployed Contract: [SushiMaker Contract](https://etherscan.io/address/0xe11fc0b43ab98eb91e9836129d1ee7c3bc95df50#code)
-   Deployed Contract: [SushiToken Contract](https://etherscan.io/token/0x6b3595068778dd592e39a122f4f5a5cf09c90fe2#code)

### Implementation considerations

-   **Implementing MasterChefV2 into a MetalStaking 🥩 project**

    -   The staking feature of the MasterChefV2 in combination with our template for liquidity pools could be a powerful template that allows users to create an own staking project. The staking contract could be used to stake LP tokens from the liquidity pool template and earn rewards in the form of a token. This would require the implementation of the staking contract, the liquidity pool template, and the reward distribution mechanism.
    -   The staking contract would need to interact with the liquidity pool template to deposit and withdraw LP tokens, as well as the reward distribution mechanism to calculate and distribute rewards to stakers.
    -   Extensive testing to ensure the template is secure and interacts correctly with the liquidity pool template and the reward distribution mechanism.

-   **Metal frontend considerations to have a good UX**

    -   The frontend for the staking contract would need to display the staking pool, allow users to deposit and withdraw LP tokens, and show the rewards earned by staking.
    -   The frontend would also need to interact with the staking contract to deposit and withdraw LP tokens, as well as claim rewards.
    -   The frontend would need to be user-friendly and provide a seamless experience for users to stake LP tokens and earn rewards, displaying the staking pools, the user's staked amount, and the rewards earned in a clear and intuitive way. (to prevent users from making mistakes and losing their funds and the need excessive user support.)

-   **Implementation time considerations**
    -   The main challenge in implementing the MasterChefV2 functionality into a MetalStaking 🥩 project would be the complexity of the staking contract and the reward distribution mechanism. The math and distribution of rewards is a complex process that requires a deep understanding of the staking contract and the reward distribution mechanism. Testing for edge-cases should be considered the highest priority.

### Conclusion

The MasterChefV2 staking contract is a powerful tool that could significantly enhance the MetalFunFactory token template by allowing users to add staking and reward distribution to their token. While it does not need to be a full DEX, it can provide a template for deploying tokens with additional features. Implementing this contract for a DEX template would require additional research and development, given the interactions with multiple helper contracts and the need for a deep understanding of the SushiSwap ecosystem. Adding the staking contract to the MetalFunFactory ecosystem could be a valuable addition. The gained knowledge from integrating the staking and reward distribution mechanism would be a great asset for future research and development and a good step towards a more complex DEX template.
