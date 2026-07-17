# Screenshots Directory

This directory is intended to contain screenshots demonstrating the functionality of the To-Do List Smart Contract when tested in Remix IDE.

Expected screenshots (if you choose to capture them):

1. **deploy.png** - Shows the contract deployment in Remix IDE.
2. **add_task.png** - Shows the addTask function being called with a task description.
3. **toggle_task.png** - Shows the toggleTaskStatus function being called to change a task's status.
4. **get_tasks.png** - Shows the getTasks function being called to retrieve all tasks.
5. **delete_task.png** - Shows the deleteTask function being called to remove a completed task.
6. **remix_tests.png** - Shows the overall Remix IDE interface with the contract deployed and tested.

## How to Generate These Screenshots

1. Deploy the contract in Remix IDE using the JavaScript VM environment.
2. Call the addTask function with a test description (e.g., "Learn Solidity").
3. Call the toggleTaskStatus function on a task to change its completion status.
4. Call the getTasks function to retrieve all tasks for the current account.
5. Call the deleteTask function on a completed task to remove it.
6. Attempt invalid operations (like adding an empty task, toggling a non-existent task, deleting an incomplete task) to see the revert messages.
7. Take screenshots of each step to demonstrate the functionality.

## Alternative: Test Networks

For a more realistic demonstration, you can deploy to a public testnet (e.g., Goerli, Sepolia) using MetaMask:
- Get test ETH from a faucet for the testnet.
- Deploy and interact with the contract using real transactions (though on a testnet).