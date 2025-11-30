// SPDX-License-Identifier: MIT
// Code for teaching purposes only. 
// See University of Basel cryptolectures.io

pragma solidity ^0.8.9;

contract MultiStore {
    // Each address can store one number
    mapping(address => uint256) public numbers;

    // Store a number for the sender's address
    function store(uint256 _value) public {
        numbers[msg.sender] = _value;
    }

    // Retrieve the number stored by a specific address
    function retrieve(address _user) public view returns (uint256) {
        return numbers[_user];
    }
}
