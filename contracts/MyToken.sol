// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error AmountToSmall();

contract MyToken is ERC20 {
    event FundsDeposited(address user, uint amount);
    event ProfileUpdated(address user);

    struct User {
        string name;
        uint256 age;
        uint256 balance;
    }

    uint256 private constant FEE = 2;
    address public immutable i_owner;
    mapping(address => User) public addressToUser;
    mapping(address => uint256) public addressToAmount;

    constructor(uint256 initialSupply) ERC20("MyToken", "MT") {
        i_owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Not owner");
        _;
    }

    modifier onlyDepositers(address _addr) {
        require(addressToAmount[_addr] != 0, "Did not deposit");
        _;
    }

    modifier minFund(uint256 _amount) {
        if (_amount < FEE) {
            revert AmountToSmall();
        }
        _;
    }

    function deposit(uint256 depositAmount) public {
        addressToUser[i_owner].balance += depositAmount;
        addressToAmount[msg.sender] = depositAmount;
        emit FundsDeposited(i_owner, depositAmount);
    }

    function withdraw(uint256 withdrawAmount) public onlyOwner {
        addressToUser[i_owner].balance -= withdrawAmount;
    }

    function addFund(uint256 fundAmount)
        public
        onlyDepositers(msg.sender)
        minFund(fundAmount)
    {
        addressToAmount[msg.sender] += fundAmount;
        emit FundsDeposited(msg.sender, fundAmount);
    }

    function checkBalance() public view returns (uint256) {
        return addressToUser[i_owner].balance;
    }

    function setUserDetails(string calldata name, uint256 age) public {
        User memory user;
        user.name = name;
        user.age = age;
        user.balance = checkBalance();
        addressToUser[i_owner] = user;
        emit ProfileUpdated(i_owner);
    }

    function getUserDetails()
        public
        view
        returns (
            string memory,
            uint256,
            uint256
        )
    {
        return (
            addressToUser[i_owner].name,
            addressToUser[i_owner].age,
            addressToUser[i_owner].balance
        );
    }
}
