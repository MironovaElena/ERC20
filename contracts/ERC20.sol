// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

contract ERC20 { //
    uint public totalSupply; // строка общая токенов
    mapping(address => uint) public balanceOf; 
    mapping(address => mapping(address => uint)) public allowance; //позваляет списать с нащего балланса
    string public name = "ELENA MIRONOVA";
    string public symbol = "ELM";
    uint8 public decimals = 18;

    address immutable public owner;
    mapping(address => bool) public blackListed;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier notZero(address user, uint amount) {
        require(user != address(0) && amount > 0);
        _;
    }

    modifier notBlacklisted(address user) {
        require(blackListed[user] == false);
        _;
    }

    constructor (uint amount) {
        owner = msg.sender;
        mint_(amount);
    }

    function transfer(address recipient, uint amount) notZero(recipient, amount) notBlacklisted(msg.sender) public  returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) public  returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) notZero(recipient, amount) notBlacklisted(sender) external returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint_(uint amount) internal { // выпустить монету
        balanceOf[owner] += amount;
        totalSupply += amount;
        emit Transfer(address(0), owner, amount);
    }

    function mint(uint amount) onlyOwner public {
        mint_(amount);
    }

    function burn (uint amount) onlyOwner public  {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function blackList(address user, bool blacklist) onlyOwner public  {
        blackListed[user] = blacklist;
    }
}