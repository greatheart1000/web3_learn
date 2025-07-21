// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ReentrancyGuard.sol";

contract MultiSigWallet is ReentrancyGuard {
    /*---- 状态变量 ----*/
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;          // 执行一笔交易所需的最少确认数

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    // txIndex => Transaction
    mapping(uint256 => Transaction) public transactions;
    // txIndex => owner => 已确认？
    mapping(uint256 => mapping(address => bool)) public isConfirmed;
    uint256 public txCount;          // 交易计数器

    /*---- 事件 ----*/
    event Submit(
        uint256 indexed txIndex,
        address indexed owner,
        address to,
        uint256 value,
        bytes data
    );
    event Confirm(uint256 indexed txIndex, address indexed owner);
    event Revoke(uint256 indexed txIndex, address indexed owner);
    event Execute(uint256 indexed txIndex);

    /*---- 构造函数 ----*/
    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "need >0  owner");
        require(_required > 0 && _required <= _owners.length, "unsafe required value");

        for (uint256 i = 0; i < _owners.length; i++) {
            address o = _owners[i];
            require(o != address(0), "address(0) cannot be owner");
            require(!isOwner[o], "owner");
            isOwner[o] = true;
            owners.push(o);
        }

        required = _required;
    }

    /*---- 修饰器 ----*/
    modifier onlyOwner() {
        require(isOwner[msg.sender], "only owner run");
        _;
    }

    modifier txExists(uint256 _txIndex) {
        require(_txIndex < txCount, "transactions ");
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(!transactions[_txIndex].executed, "transactions had been executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "had been confirmed");
        _;
    }

    /*---- 提交交易 ----*/
    function submitTransaction(
        address _to,
        uint256 _value,
        bytes calldata _data
    )
        external
        onlyOwner
    {
        transactions[txCount] = Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        });

        emit Submit(txCount, msg.sender, _to, _value, _data);
        txCount++;
    }

    /*---- 确认交易 ----*/
    function confirmTransaction(uint256 _txIndex)
        external
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage txn = transactions[_txIndex];
        txn.numConfirmations++;
        isConfirmed[_txIndex][msg.sender] = true;

        emit Confirm(_txIndex, msg.sender);
    }

    /*---- 撤销确认 ----*/
    function revokeConfirmation(uint256 _txIndex)
        external
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        require(isConfirmed[_txIndex][msg.sender], "dont be Confirmed,");
        Transaction storage txn = transactions[_txIndex];
        txn.numConfirmations--;
        isConfirmed[_txIndex][msg.sender] = false;

        emit Revoke(_txIndex, msg.sender);
    }

    /*---- 执行交易 ----*/
    function executeTransaction(uint256 _txIndex)
        external
        nonReentrant
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage txn = transactions[_txIndex];
        require(txn.numConfirmations >= required, "required is less than need");

        txn.executed = true;
        (bool success, ) = txn.to.call{value: txn.value}(txn.data);
        require(success, "transaction failed");

        emit Execute(_txIndex);
    }

    /*---- 接收 ETH ----*/
    receive() external payable {}
}