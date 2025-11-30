// SPDX-License-Identifier: MIT
// Code for teaching purposes only. 
// See University of Basel cryptolectures.io

pragma solidity ^0.8.9;

contract MultiStoreWithList {
    // Each address can store one number
    mapping(address => uint256) public numbers;

    // List of addresses that have stored a number
    address[] public users;

    // Store a number for the sender's address
    function store(uint256 _value) public {
        // If this is the first time the sender stores a number, add to the list
        if (numbers[msg.sender] == 0 && _value != 0) {
            users.push(msg.sender);
        }
        numbers[msg.sender] = _value;
    }

    // Retrieve the number stored by a specific address
    function retrieve(address _user) public view returns (uint256) {
        return numbers[_user];
    }

    // Get all addresses that have stored a number
    function getUsers() public view returns (address[] memory) {
        return users;
    }
}
