// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// контракт ERC20, который реализует стандартный интерфейс для токенов Ethereum.
contract ERC20 {
    //Это объявление переменных, которые хранят общее количество токенов (totalSupply), балансы адресов (balanceOf), разрешения на снятие токенов (allowance), название токена (name), символ токена (symbol) и количество десятичных знаков токена (decimals).
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    string public name = "ELENA MIRONOVA";
    string public symbol = "ELM";
    uint8 public decimals = 18;
    //Здесь объявляются переменные owner, которая хранит адрес владельца контракта, и blackListed, которая хранит информацию о том, находится ли адрес в черном списке.
    address public immutable owner;
    mapping(address => bool) public blackListed;
    //Эти строки объявляют события Transfer и Approval, которые будут использоваться для отслеживания передачи токенов и установки разрешений.
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    //Этот модификатор проверяет, что вызывающий контракт является владельцем контракта.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    //Этот модификатор проверяет, что адрес пользователя и количество токенов не являются нулевыми значениями.
    modifier notZero(address user, uint amount) {
        require(user != address(0) && amount > 0,"amount and address should not be zero");
        _;
    }
    //Этот модификатор проверяет, что адрес пользователя не находится в черном списке.
    modifier notBlacklisted(address user) {
        require(blackListed[user] == false);
        _;
    }

    // Это конструктор контракта, который устанавливает владельца контракта и создает начальное количество токенов.
    constructor(uint amount) {
        owner = msg.sender;
        mint_(amount);
    }

    //Это функция для передачи токенов от отправителя к получателю.
    function transfer(
        address recipient,
        uint amount
    ) public notZero(recipient, amount) notBlacklisted(msg.sender) returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    //Эта функция устанавливает разрешение на снятие токенов от владельца контракта к указанному адресу.
    function approve(address spender, uint amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    //Эта функция позволяет переводить токены от отправителя к получателю с использованием предварительно установленного разрешения.
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external notZero(recipient, amount) notBlacklisted(sender) returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    //Эта внутренняя функция увеличивает баланс владельца контракта и общее количество токенов.
    function mint_(uint amount) internal {
        balanceOf[owner] += amount;
        totalSupply += amount;
        emit Transfer(address(0), owner, amount);
    }

    //Эта функция позволяет владельцу контракта создавать новые токены.
    function mint(uint amount) public onlyOwner {
        mint_(amount);
    }

    //Эта функция позволяет владельцу контракта сжигать токены.
    function burn(uint amount) public onlyOwner {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    //Эта функция позволяет владельцу контракта добавлять или удалять адреса из черного списка.
    function blackList(address user, bool blacklist) public onlyOwner {
        blackListed[user] = blacklist;
    }
}
