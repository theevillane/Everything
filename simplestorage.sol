// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LandRegistry {
    struct Land {
        string title;         // Title of the land
        address owner;        // Current owner of the land
        bool exists;          // Check if the land exists
        bool active;         //Indicates if the land is cactive
    }
    struct Transaction{
          address from;
          address to;
          uint256 price;
          uint timestamp;

    mapping(uint256 => Land) public lands; // Mapping of land ID to Land struct
    mapping(uint256 => Transaction[]) public transactionHistory;   //Transaction history per land
    uint256 public landCount;                // Count of registered lands
    address public admin;           //Admin address

    // Event emitted when a land is registered
    event LandRegistered(uint256 indexed landId, string title, address indexed owner);

    // Event emitted when a land is transferred
    event LandTransferred(uint256 indexed landId, address indexed from, address indexed to);

    // Event emitted when a land title is changed
    event TitleChanged(uint256 indexed landId, string newTitle);

    //Event emitted when a land is activated
    event LandActivated(uint256 indexed LAndId);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyOwner(uint256 _landId) {
        require(lands[_landId].owner == msg.sender, "Only land owner can perform this action");
        _;
    }
    // Modifier to check land existence
    modifier landExists(uint256 _landId) {
        require(lands[_landId].exists, "Land does not exist");
        _;
    }
    modifier landIsActive(uint256 _landId) {
        require(lands[_landId].active, "Land is not active");
        _;
    }

    constructor() {
        admin = msg.sender; // Set the contract deployer as admin
    }

    // Function to register land
    function registerLand(string memory _title) public {
        landCount++;  // Increment land count
        require(!lands[landCount].exists, "Land already registered"); // Ensure land doesn't exist
        lands[landCount] = Land(_title, msg.sender, true); // Create new land record
        emit LandRegistered(landCount, _title, msg.sender); // Emit event
    }

    // Function to transfer ownership of land
    function transferLand(uint256 _landId, address _newOwner, uint256 price) 
        public landExists(_landId
        landIsActve(_landId)
        onlyOwner(_landId)
     {
        require(lands[_landId].owner == msg.sender, "You are not the owner"); // Ensure sender is the owner

        // Transfer ownership
        address previousOwner = lands[_landId].owner;
        lands[_landId].owner = _newOwner; // Update owner
         // Record the transaction
        transactionHistory[_landId].push(
            Transaction(previousOwner, _newOwner, _price, block.timestamp)
        );
        emit LandTransferred(_landId, previousOwner, _newOwner); // Emit event
    }

    // Function to change land title
    function changeTitle(uint256 _landId, string memory _newTitle) 
       public 
       landExists(_landId)
       onlyOwner    //Ensure the seller is the owner
     {
        lands[_landId].title = _newTitle; // Update title
        emit TitleChanged(_landId, _newTitle); // Emit event
    }

    // Function to get land details
    function getLand(uint256 _landId) public view landExists(_landId) returns (string memory title, address owner) {
        return (lands[_landId].title, lands[_landId].owner); // Return land title and owner
    }
}
