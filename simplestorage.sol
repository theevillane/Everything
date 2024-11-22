// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract LandRegistry is AccessControl {
    struct Land {
        string title;                // Title of the land
        address currentOwner;        // Current owner of the land
        address[] ownershipHistory;  // List of previous owners
        bool exists;                 // Check if the land exists
        bool active;                 // Status of land (active/inactive)
    }

    struct Transaction {
        address from;        // Seller's address
        address to;          // Buyer's address
        uint256 price;       // Transaction price
        uint256 timestamp;   // Transaction time
    }

    // Role definitions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant LAND_OWNER_ROLE = keccak256("LAND_OWNER_ROLE");

    // Land and transaction data
    mapping(uint256 => Land) public lands;                  // Mapping of land ID to Land struct
    mapping(uint256 => Transaction[]) public transactionHistory; // Transaction history per land ID

    // Escrow-related variables
    mapping(uint256 => uint256) public escrowBalances; // Escrow balance per land ID
    mapping(uint256 => address) public escrowBuyers;   // Buyer addresses in escrow

    // Dispute-related variables
    enum DisputeStatus { None, Raised, Resolved }
    mapping(uint256 => DisputeStatus) public landDisputes;

    uint256 public landCount; // Counter for registered lands

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender); // Contract deployer is super admin
        _setupRole(ADMIN_ROLE, msg.sender);         // Assign admin role to deployer
    }

    // Events
    event LandRegistered(uint256 indexed landId, string title, address indexed owner);
    event LandTransferred(uint256 indexed landId, address indexed from, address indexed to, uint256 price);
    event TitleChanged(uint256 indexed landId, string newTitle);
    event LandActivated(uint256 indexed landId);
    event LandDeactivated(uint256 indexed landId);
    event EscrowInitiated(uint256 indexed landId, address indexed buyer, uint256 price);
    event EscrowReleased(uint256 indexed landId, address indexed buyer, address indexed seller, uint256 price);
    event DisputeRaised(uint256 indexed landId, address indexed by);
    event DisputeResolved(uint256 indexed landId, address indexed by);


    // Modifiers
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Only admin can perform this action");
        _;
    }

    modifier onlyOwner(uint256 _landId) {
        require(lands[_landId].currentOwner == msg.sender, "Only the land owner can perform this action");
        _;
    }

    modifier landExists(uint256 _landId) {
        require(lands[_landId].exists, "Land does not exist");
        _;
    }

    modifier landIsActive(uint256 _landId) {
        require(lands[_landId].active, "Land is not active");
        _;
    }

    // Register a new land
    function registerLand(string memory _title, address _owner) public onlyAdmin {
        landCount++;
        uint256 landId = landCount;

        require(!lands[landId].exists, "Land already registered");

        lands[landId] = Land({
            title: _title,
            currentOwner: _owner,
            ownershipHistory: new address          exists: true,
            active: true
        });

        lands[landId].ownershipHistory.push(_owner);

        // Grant land owner role
        _grantRole(LAND_OWNER_ROLE, _owner);

        emit LandRegistered(landId, _title, _owner);
    }

    // Transfer land ownership
    function transferOwnership(uint256 _landId, address _newOwner, uint256 _price) 
        public 
        onlyOwner(_landId) 
        landExists(_landId) 
        landIsActive(_landId) 
    {
        address previousOwner = lands[_landId].currentOwner;

        // Update ownership
        lands[_landId].currentOwner = _newOwner;
        lands[_landId].ownershipHistory.push(_newOwner);

        // Record transaction
        transactionHistory[_landId].push(Transaction({
            from: previousOwner,
            to: _newOwner,
            price: _price,
            timestamp: block.timestamp
        }));

        // Update roles
        _revokeRole(LAND_OWNER_ROLE, previousOwner);
        _grantRole(LAND_OWNER_ROLE, _newOwner);

        emit LandTransferred(_landId, previousOwner, _newOwner, _price);
    }

    // Initiate escrow for land transfer
    function initiateEscrow(uint256 _landId) public payable landExists(_landId) landIsActive(_landId) {
        require(msg.sender != lands[_landId].currentOwner, "Owner cannot be the buyer");
        require(escrowBalances[_landId] == 0, "Escrow already exists for this land");

        escrowBalances[_landId] = msg.value;
        escrowBuyers[_landId] = msg.sender;

        emit EscrowInitiated(_landId, msg.sender, msg.value);
    }

    // Release escrow and confirm ownership
    function releaseEscrow(uint256 _landId) public onlyOwner(_landId) landExists(_landId) landIsActive(_landId) {
        require(escrowBalances[_landId] > 0, "No escrow to release");

        address buyer = escrowBuyers[_landId];
        uint256 amount = escrowBalances[_landId];
        address seller = lands[_landId].currentOwner;

        // Clear escrow
        escrowBalances[_landId] = 0;
        escrowBuyers[_landId] = address(0);

        // Transfer funds
        payable(seller).transfer(amount);

        emit EscrowReleased(_landId, buyer, seller, amount);
    }

    // Raise dispute
    function raiseDispute(uint256 _landId) public landExists(_landId) {
        require(msg.sender == lands[_landId].currentOwner || msg.sender == escrowBuyers[_landId], "Unauthorized");
        require(landDisputes[_landId] == DisputeStatus.None, "Dispute already raised");

        landDisputes[_landId] = DisputeStatus.Raised;
        emit DisputeRaised(_landId, msg.sender);
    }

    // Resolve dispute
    function resolveDispute(uint256 _landId, bool approveTransfer) public onlyAdmin landExists(_landId) {
        require(landDisputes[_landId] == DisputeStatus.Raised, "No dispute to resolve");

        if (approveTransfer) {
            releaseEscrow(_landId); // Resolve in favor of buyer
        } else {
            // Refund buyer
            address buyer = escrowBuyers[_landId];
            uint256 amount = escrowBalances[_landId];

            payable(buyer).transfer(amount);
            escrowBalances[_landId] = 0;
            escrowBuyers[_landId] = address(0);
        }

        landDisputes[_landId] = DisputeStatus.Resolved;
        emit DisputeResolved(_landId, msg.sender);
    }
}
