// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import { MultiSigWallet } from "../src/multi-sig.sol"; // 确保这里的路径与你的合约文件实际路径一致

contract MultiSigWalletTest is Test {
    MultiSigWallet wallet;
    address owner1;
    address owner2;
    address owner3;
    address nonOwner;
    address payable receiver;

    function setUp() public {
        // 模拟五个地址
        owner1 = address(0xA1);
        owner2 = address(0xA2);
        owner3 = address(0xA3);
        nonOwner = address(0xB1);
        receiver = payable(address(0xC1));

        // 给 owner 地址一些 ETH，方便发交易
        vm.deal(owner1, 10 ether);
        vm.deal(owner2, 10 ether);
        vm.deal(owner3, 10 ether);

        // 部署 multi-sig，让三人中至少两人确认
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        wallet = new MultiSigWallet(owners, 2);

        // 往钱包里充值 5 ETH
        vm.deal(address(wallet), 5 ether);
    }

    function testOnlyOwnerCanSubmit() public {
        vm.prank(nonOwner);
        // 确保这里的 revert 消息与合约中的 require 消息完全匹配，注意空格！
        vm.expectRevert("only owner run");
        wallet.submitTransaction(receiver, 1 ether, "");
    }

    function testSubmitAndCount() public {
        vm.prank(owner1);
        wallet.submitTransaction(receiver, 1 ether, "0x"); // 提交
        assertEq(wallet.txCount(), 1);
    }

    function testConfirmAndPreventDuplicates() public {
        // 先提交
        vm.prank(owner1);
        wallet.submitTransaction(receiver, 1 ether, "");

        // 确认一次
        vm.prank(owner2);
        wallet.confirmTransaction(0);

        // 重新获取最新数据，只关注 numConfirmations
        (,, , , uint256 numConfirmations) = wallet.transactions(0);
        assertEq(numConfirmations, 1);

        // 重复确认要 revert
        vm.prank(owner2);
        // 确保这里的 revert 消息与合约中的 require 消息完全匹配
        vm.expectRevert("had been confirmed");
        wallet.confirmTransaction(0);

        // 重复确认失败后，确认数不应该增加，仍为1
        // 再次获取最新数据，确保状态未改变
        (,, , , numConfirmations) = wallet.transactions(0);
        assertEq(numConfirmations, 1);
    }

    function testExecuteFlow() public {
        // 提交一笔转 1 ETH 给 receiver
        vm.prank(owner1);
        wallet.submitTransaction(receiver, 1 ether, "");

        // 两位 owner 确认
        vm.prank(owner1);
        wallet.confirmTransaction(0);
        vm.prank(owner2);
        wallet.confirmTransaction(0);

        // 执行前余额
        uint256 balBefore = receiver.balance;

        // 执行
        vm.prank(owner3); // 第三位 owner 也可以来 call execute
        wallet.executeTransaction(0);

        assertEq(receiver.balance, balBefore + 1 ether);
        // 正确解构元组并访问 `executed` 字段
        // 其他不使用的变量用逗号跳过即可避免“unused local variable”警告
        (,, , bool executed,) = wallet.transactions(0);
        assertTrue(executed);
    }

    function testCannotExecuteWithoutEnoughConfirms() public {
        vm.prank(owner1);
        wallet.submitTransaction(receiver, 1 ether, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner1);
        // 确保这里的 revert 消息与合约中的 require 消息完全匹配
        vm.expectRevert("required is less than need");
        wallet.executeTransaction(0);
    }

    function testRevokeConfirmation() public {
        vm.prank(owner1);
        wallet.submitTransaction(receiver, 1 ether, "");

        vm.prank(owner2);
        wallet.confirmTransaction(0);
        // 获取最新数据中的 numConfirmations
        (,, , , uint256 numConfirmations) = wallet.transactions(0);
        assertEq(numConfirmations, 1);

        vm.prank(owner2);
        wallet.revokeConfirmation(0);
        
        // 撤销后再次获取最新数据，确认 numConfirmations 变为 0
        (,, , , numConfirmations) = wallet.transactions(0);
        assertEq(numConfirmations, 0);

        // 撤销后再次确认 OK
        vm.prank(owner2);
        wallet.confirmTransaction(0);
        // 再次确认后获取最新数据，确认 numConfirmations 再次变为 1
        (,, , , numConfirmations) = wallet.transactions(0);
        assertEq(numConfirmations, 1);
    }
}