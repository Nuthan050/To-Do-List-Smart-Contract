// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TodoList Smart Contract
 * @dev A decentralized to-do list application where each Ethereum address has its own task list.
 *      Users can create, update, delete, and retrieve their tasks.
 *      Deleted tasks are marked with a 'deleted' flag and skipped in retrieval.
 */
contract TodoList {
    /* ===== STRUCTS ===== */
    struct Task {
        uint id;
        string description;
        bool completed;
        bool deleted;
        uint createdAt;
        address owner;
    }

    /* ===== STATE VARIABLES ===== */
    // Mapping from address to array of tasks for that user
    mapping(address => Task[]) private userTasks;
    // To keep track of the next task ID for each user
    mapping(address => uint) private nextTaskId;

    /* ===== EVENTS ===== */
    event TaskCreated(
        address indexed user,
        uint taskId,
        string description
    );

    event TaskStatusUpdated(
        address indexed user,
        uint taskId,
        bool completed
    );

    event TaskDeleted(
        address indexed user,
        uint taskId
    );

    /* ===== ERRORS ===== */
    error EmptyDescription();
    error TaskDoesNotExist();
    error NotTaskOwner();
    error TaskNotCompleted();
    error InvalidTaskId();

    /* ===== MODIFIERS ===== */
    modifier onlyTaskOwner(address _user, uint _taskId) {
        require(
            _taskId < userTasks[_user].length,
            "TaskDoesNotExist"
        );
        require(
            userTasks[_user][_taskId].owner == msg.sender,
            "NotTaskOwner"
        );
        _;
    }

    /* ===== CORE FUNCTIONS ===== */
    /**
     * @dev Creates a new task for the caller.
     * @param _description Description of the task (must not be empty).
     */
    function addTask(string memory _description) external {
        require(bytes(_description).length > 0, "EmptyDescription");

        uint taskId = nextTaskId[msg.sender]++;

        Task memory newTask = Task({
            id: taskId,
            description: _description,
            completed: false,
            deleted: false,
            createdAt: block.timestamp,
            owner: msg.sender
        });

        userTasks[msg.sender].push(newTask);

        emit TaskCreated(msg.sender, taskId, _description);
    }

    /**
     * @dev Toggles the completion status of a task.
     * @param _taskId The ID of the task to toggle.
     */
    function toggleTaskStatus(uint _taskId) external
        onlyTaskOwner(msg.sender, _taskId)
    {
        require(!userTasks[msg.sender][_taskId].deleted, "TaskNotFound");

        userTasks[msg.sender][_taskId].completed = !userTasks[msg.sender][_taskId].completed;

        emit TaskStatusUpdated(
            msg.sender,
            _taskId,
            userTasks[msg.sender][_taskId].completed
        );
    }

    /**
     * @dev Deletes a completed task.
     * @param _taskId The ID of the task to delete (must be completed and not already deleted).
     */
    function deleteTask(uint _taskId) external
        onlyTaskOwner(msg.sender, _taskId)
    {
        require(
            !userTasks[msg.sender][_taskId].deleted,
            "TaskDoesNotExist"
        );
        require(
            userTasks[msg.sender][_taskId].completed,
            "TaskNotCompleted"
        );

        userTasks[msg.sender][_taskId].deleted = true;
        emit TaskDeleted(msg.sender, _taskId);
    }

    /* ===== VIEW FUNCTIONS ===== */
    /**
     * @dev Gets all tasks of the caller (excluding deleted ones).
     * @return taskIds Array of task IDs for the caller's non-deleted tasks.
     * @return tasks Array of task structs for the caller's non-deleted tasks.
     */
    function getTasks() external view returns (uint[] memory, Task[] memory) {
        uint count = 0;
        // First, count non-deleted tasks
        for (uint i = 0; i < userTasks[msg.sender].length; i++) {
            if (!userTasks[msg.sender][i].deleted) {
                count++;
            }
        }

        uint[] memory taskIds = new uint[](count);
        Task[] memory tasks = new Task[](count);
        uint index = 0;
        for (uint i = 0; i < userTasks[msg.sender].length; i++) {
            if (!userTasks[msg.sender][i].deleted) {
                taskIds[index] = userTasks[msg.sender][i].id;
                tasks[index] = userTasks[msg.sender][i];
                index++;
            }
        }

        return (taskIds, tasks);
    }

    /**
     * @dev Gets a task by ID for the caller.
     * @param _taskId The ID of the task to retrieve.
     * @return task The task struct (returns empty task if not found or deleted).
     */
    function getTask(uint _taskId) external view returns (Task memory) {
        require(_taskId < userTasks[msg.sender].length, "InvalidTaskId");
        if (userTasks[msg.sender][_taskId].deleted) {
            // Return an empty task (default constructed)
            return Task(0, "", false, 0, address(0));
        }
        return userTasks[msg.sender][_taskId];
    }

    /**
     * @dev Gets the total number of non-deleted tasks for the caller.
     * @return count The number of non-deleted tasks.
     */
    function getTaskCount() external view returns (uint) {
        uint count = 0;
        for (uint i = 0; i < userTasks[msg.sender].length; i++) {
            if (!userTasks[msg.sender][i].deleted) {
                count++;
            }
        }
        return count;
    }
}