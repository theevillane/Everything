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
    }

    mapping(uint256 => Land) public lands; // Mapping of land ID to Land struct
    mapping(uint256 => Transaction[]) public transactionHistory;   //Transaction history per land
      // Escrow-related variables
    mapping(uint256 => uint256) public escrowBalances; // Escrow balance per land ID
    mapping(uint256 => address) public escrowBuyers;   // Buyer addresses in escrow
    mapping(uint256 => DisputeStatus) public landDisputes;

    uint256 public landCount;                // Count of registered lands
    address public admin;           //Admin address


    // Dispute-related variables
    enum DisputeStatus { None, Raised, Resolved }

   
    // Event emitted when a land is registered
    event LandRegistered(uint256 indexed landId, string title, address indexed owner);

    // Event emitted when a land is transferred
    event LandTransferred(uint256 indexed landId, address indexed from, address indexed to);

    // Event emitted when a land title is changed
    event TitleChanged(uint256 indexed landId, string newTitle);

    //Event emitted when a land is activated
    event LandActivated(uint256 indexed LAndId);

    //Event emitted when land is diactivated
    event LandDeactivated(uint256 indexed landId);

    event EscrowInitiated(uint256 indexed landId, address indexed buyer, uint256 price);
    event EscrowReleased(uint256 indexed landId, address indexed buyer, address indexed seller, uint256 price);
    event DisputeRaised(uint256 indexed landId, address indexed by);
    event DisputeResolved(uint256 indexed landId, address indexed by);


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

    // Function to register land(only admins to register lands)
    function registerLand(string memory _title) public onlyAdmin {
        landCount++;  // Increment land count
        require(!lands[landCount].exists, "Land already registered"); // Ensure land doesn't exist
        lands[landCount] = Land(_title, msg.sender, true); // Create new land record
        emit LandRegistered(landCount, _title, msg.sender); // Emit event
    }

    // Initiate escrow for land transfer
    function initiateEscrow(uint256 _landId) public payable landExists(_landId) landIsActive(_landId) {
        require(msg.sender != lands[_landId].owner, "Owner cannot be the buyer");
        require(escrowBalances[_landId] == 0, "Escrow already exists for this land");

        escrowBalances[_landId] = msg.value;
        escrowBuyers[_landId] = msg.sender;
        emit EscrowInitiated(_landId, msg.sender, msg.value);
    }

    // Confirm ownership and release escrow to the seller
    function releaseEscrow(uint256 _landId) public onlyOwner(_landId) landExists(_landId) landIsActive(_landId) {
        require(escrowBalances[_landId] > 0, "No escrow to release");

        address buyer = escrowBuyers[_landId];
        uint256 amount = escrowBalances[_landId];

   // Transfer ownership
        address previousOwner = lands[_landId].owner;
        lands[_landId].owner = buyer;

        // Record transaction
        transactionHistory[_landId].push(
            Transaction(previousOwner, buyer, amount, block.timestamp)
        );

    // Release funds to seller
        payable(previousOwner).transfer(amount);
        
        // Clear escrow data
        delete escrowBalances[_landId];
        delete escrowBuyers[_landId];

        emit EscrowReleased(_landId, buyer, previousOwner, amount);
        emit LandTransferred(_landId, previousOwner, buyer, amount);
    }

    // Raise a dispute in the land transfer
    function raiseDispute(uint256 _landId) public landExists(_landId) {
        require(msg.sender == lands[_landId].owner || msg.sender == escrowBuyers[_landId], "Only involved parties can raise a dispute");
        require(landDisputes[_landId] == DisputeStatus.None, "Dispute already raised");

        landDisputes[_landId] = DisputeStatus.Raised;
        emit DisputeRaised(_landId, msg.sender);
    }

    // Resolve a dispute (admin only)
    function resolveDispute(uint256 _landId, bool approveTransfer) public onlyAdmin landExists(_landId) {
        require(landDisputes[_landId] == DisputeStatus.Raised, "No dispute to resolve");

        if (approveTransfer) {
            releaseEscrow(_landId); // Resolve in favor of buyer and transfer ownership
        } else {
            // Refund buyer and cancel escrow
            address buyer = escrowBuyers[_landId];
            uint256 amount = escrowBalances[_landId];

            payable(buyer).transfer(amount);
            delete escrowBalances[_landId];
            delete escrowBuyers[_landId];
        }

        landDisputes[_landId] = DisputeStatus.Resolved;
        emit DisputeResolved(_landId, msg.sender);
    // Function to change land title
    function changeTitle(uint256 _landId, string memory _newTitle) public landExists(_landId)
       onlyOwner    //Ensure the seller is the owner
     {
        lands[_landId].title = _newTitle; // Update title
        emit TitleChanged(_landId, _newTitle); // Emit event
    }

    //Function to deactivate a land(only admin or owner can deactivate)
     function deactivateLand(uint256 _landId) public LandExists(_landId){
     require(msg.sender == admin || msg.sender == lands[_landId].owner, "Only admin or owner can deactivate land");
     lands[_landId].active = false;
     emit LandDeactivated(_landId);

    // Get transaction history of a specific land
    function getTransactionHistory(uint256 _landId) public view landExists(_landId) returns (Transaction[] memory) {
        return transactionHistory[_landId];
    }

    // Function to get land details, including active status
    function getLand(uint256 _landId) public view LandExists(_landId) 
      returns (string memory title, address owner, bool active) {
      Land memory land = lands[_landId]  
      return (lands[_landId].title, lands[_landId].owner, land[_landId].active); // Return land title and owner
    }
}
