# To-Do List Smart Contract

## Project Overview

A decentralized to-do list application built on the Ethereum blockchain using Solidity. Each Ethereum address has its own isolated task list, ensuring privacy and ownership of personal tasks. Users can create, update, delete, and retrieve their tasks securely.

## Features

- **Task Creation**: Users can add new tasks with a description (non-empty).
- **Task Status Update**: Toggle task completion status (completed ↔ pending).
- **Task Deletion**: Remove completed tasks (only completed tasks can be deleted).
- **Task Retrieval**: 
  - Get all tasks for the caller
  - Get a specific task by ID
  - Get total task count
- **Event Logging**: 
  - `TaskCreated`: When a new task is added
  - `TaskStatusUpdated`: When a task's completion status changes
  - `TaskDeleted`: When a task is deleted
- **Security**:
  - Only task owners can modify or delete their tasks
  - Validation for empty descriptions, invalid task IDs, and unauthorized access
  - Uses Solidity ^0.8.0 for built-in overflow protection

## Technologies Used

- **Solidity** ^0.8.0
- **Ethereum Virtual Machine (EVM)**
- **Remix IDE** (for development, testing, and deployment)
- **MetaMask** (optional, for testing on live testnets)

## Smart Contract Architecture

### Data Structures
- `Task` struct:
  - `id`: Unique identifier for the task
  - `description`: Task description (string)
  - `completed`: Boolean indicating completion status
  - `createdAt`: Timestamp when the task was created
  - `owner`: Ethereum address of the task owner
  - *Note: Deleted tasks are marked by setting the description to an empty string.*

### Storage
- `userTasks`: `mapping(address => Task[])` - Maps each user's address to an array of their tasks.
- *Note: We maintain task IDs as array indices for simplicity, but mark deleted tasks with empty descriptions to preserve ID stability.*

### Events
- `TaskCreated(address indexed user, uint taskId, string description)`
- `TaskStatusUpdated(address indexed user, uint taskId, bool completed)`
- `TaskDeleted(address indexed user, uint taskId)`

### Functions
#### Core Functions
- `addTask(string memory _description)`: Create a new task
- `toggleTaskStatus(uint _taskId)`: Toggle completion status of a task
- `deleteTask(uint _taskId)`: Delete a completed task (marks as deleted by clearing description)

#### View Functions
- `getTasks()`: Returns arrays of task IDs and task structs for non-deleted tasks
- `getTask(uint _taskId)`: Returns a specific task (returns empty task if not found or deleted)
- `getTaskCount()`: Returns the count of non-deleted tasks

## Contract Address
Once deployed, the contract address will be provided by Remix IDE.

## Deployment Instructions

### Using Remix IDE
1. Go to [Remix IDE](https://remix.ethereum.org).
2. Create a new file in the `contracts` directory (e.g., `TodoList.sol`).
3. Copy and paste the Solidity code from `contracts/TodoList.sol` into this file.
4. Compile the contract:
   - Go to the "Solidity Compiler" tab.
   - Ensure the compiler version is set to `0.8.0` or higher (compatible with `^0.8.0`).
   - Click "Compile TodoList.sol".
5. Deploy the contract:
   - Go to the "Deploy & Run Transactions" tab.
   - Select the `TodoList` contract from the dropdown.
   - Choose the environment: "JavaScript VM" (for testing) or "Injected Web3" (for MetaMask/testnet).
   - Click "Deploy".

## Testing Guide (Using Remix IDE's JavaScript VM)

### Test Accounts
Remix's JavaScript VM provides several test accounts with 100 ETH each by default:
- Account 0: `0x5B38Da6a701c568545dCfcB03FcB875f56beddC4`
- Account 1: `0xAb8483F64d9C6d1EcF9b849Ae677dD3315835Cb2`
- Account 2: `0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db`
- ... and more.

### Test Cases

#### Test Case 1: Add Task
1. **Account**: Use Account 0.
2. **Function**: `addTask`.
3. **Parameter**: `_description`: "Learn Solidity".
4. **Expected**:
   - Transaction succeeds.
   - `TaskCreated` event logged with user address, taskId 0, and description.
   - Calling `getTaskCount()` for Account 0 returns 1.

#### Test Case 2: Add Multiple Tasks
1. **Account**: Account 0.
2. **Function**: `addTask` twice.
3. **Parameters**: 
   - First: "Buy groceries"
   - Second: "Walk the dog"
4. **Expected**:
   - Both transactions succeed.
   - Two `TaskCreated` events with taskIds 0 and 1.
   - `getTaskCount()` returns 2.

#### Test Case 3: Toggle Task Status
1. **Setup**: Ensure Account 0 has at least one task (from Test Case 1).
2. **Account**: Account 0.
3. **Function**: `toggleTaskStatus`.
4. **Parameter**: `_taskId`: 0.
5. **Expected**:
   - Transaction succeeds.
   - `TaskStatusUpdated` event logged with user, taskId 0, and completed = true.
   - Calling `getTask(0)` shows completed = true.

#### Test Case 4: Delete Completed Task
1. **Setup**: Ensure Account 0 has a completed task (from Test Case 3).
2. **Account**: Account 0.
3. **Function**: `deleteTask`.
4. **Parameter**: `_taskId`: 0 (the completed task).
5. **Expected**:
   - Transaction succeeds.
   - `TaskDeleted` event logged with user and taskId 0.
   - `getTaskCount()` returns 0 (if only one task existed).
   - `getTask(0)` returns an empty task (default constructed).

#### Test Case 5: Attempt to Add Empty Task
1. **Account**: Account 0.
2. **Function**: `addTask`.
3. **Parameter**: `_description`: "" (empty string).
4. **Expected**:
   - Transaction reverts with error: "EmptyDescription".

#### Test Case 6: Attempt to Toggle Non-Existent Task
1. **Account**: Account 0.
2. **Function**: `toggleTaskStatus`.
3. **Parameter**: `_taskId`: 999 (assuming no task with this ID).
4. **Expected**:
   - Transaction reverts with error: "InvalidTaskId".

#### Test Case 7: Attempt to Delete Non-Completed Task
1. **Setup**: Ensure Account 0 has an incomplete task.
2. **Account**: Account 0.
3. **Function**: `deleteTask`.
4. **Parameter**: `_taskId`: ID of an incomplete task.
5. **Expected**:
   - Transaction reverts with error: "TaskNotCompleted".

#### Test Case 8: Attempt to Access Another User's Task
1. **Setup**: Account 0 has a task with ID 0.
2. **Account**: Account 1.
3. **Function**: `getTask(0)`.
4. **Expected**:
   - Returns an empty task (since Account 1 has no tasks).

#### Test Case 9: Verify Event Emission
- After each state-changing operation (addTask, toggleTaskStatus, deleteTask), check the "Transactions" section in Remix IDE to see the emitted events.

#### Test Case 10: Verify Independent Task Storage
1. **Account 0**: Add a task "Task A".
2. **Account 1**: Add a task "Task B".
3. **Verify**:
   - Account 0's `getTaskCount()` returns 1.
   - Account 1's `getTaskCount()` returns 1.
   - Account 0's `getTask(0)` returns "Task A".
   - Account 1's `getTask(0)` returns "Task B".

## Expected Outcome

A fully functional Solidity smart contract that:
- Allows users to create, update, delete, and retrieve their personal to-do tasks.
- Maintains separate task lists for each Ethereum address.
- Prevents unauthorized access and invalid operations.
- Emits transparent events for tracking on the blockchain.
- Provides view functions for reading task data without gas costs.
- Is fully testable in Remix IDE with multiple accounts to verify isolation.

## Files in This Repository

- `contracts/TodoList.sol`: The main Solidity smart contract.
- `README.md`: This file, providing an overview, features, deployment instructions, and testing guide.
- `LICENSE`: MIT License.
- `.gitignore`: Files and directories to ignore in version control.
- `screenshots/`: Directory for screenshots (see `screenshots/README.md` for details).

## Future Improvements

- Add task editing functionality (modify description).
- Implement due dates and reminders for tasks.
- Add task categorization or tagging.
- Allow sharing tasks with other addresses (with permissions).
- Implement a fee mechanism for certain operations (optional).
- Add administrative functions for contract maintenance (if needed).
- Enhance the user interface with a decentralized application (dApp) frontend.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
**Note**: This contract is intended for educational purposes and has not been audited for production use. Always conduct thorough testing and consider professional audits before deploying contracts that handle value or sensitive data.
