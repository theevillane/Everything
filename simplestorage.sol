// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LandRegistry {
    struct Land {
        string title;         // Title of the land
        address owner;        // Current owner of the land
        bool exists;          // Check if the land exists
    }

    mapping(uint256 => Land) public lands; // Mapping of land ID to Land struct
    uint256 public landCount;                // Count of registered lands

    // Event emitted when a land is registered
    event LandRegistered(uint256 indexed landId, string title, address indexed owner);

    // Event emitted when a land is transferred
    event LandTransferred(uint256 indexed landId, address indexed from, address indexed to);

    // Function to register land
    function registerLand(string memory _title) public {
        landCount++;  // Increment land count
        lands[landCount] = Land(_title, msg.sender, true); // Create new land record
        emit LandRegistered(landCount, _title, msg.sender); // Emit event
    }

    // Function to transfer ownership of land
    function transferLand(uint256 _landId, address _newOwner) public {
        require(lands[_landId].exists, "Land does not exist"); // Check if land exists
        require(lands[_landId].owner == msg.sender, "You are not the owner"); // Ensure sender is the owner

        // Transfer ownership
        address previousOwner = lands[_landId].owner;
        lands[_landId].owner = _newOwner; // Update owner
        emit LandTransferred(_landId, previousOwner, _newOwner); // Emit event
    }

    // Function to get land details
    function getLand(uint256 _landId) public view returns (string memory title, address owner) {
        require(lands[_landId].exists, "Land does not exist"); // Check if land exists
        return (lands[_landId].title, lands[_landId].owner); // Return land title and owner
    }
}
