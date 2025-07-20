// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // 与你的生产合约保持一致

import { Test, console } from "forge-std/Test.sol";
import { Vote } from "../src/Vote.sol";

contract VoteTest is Test {
    /// 在测试合约里声明事件，方便 vm.expectEmit + emit
    event VoteCast(address indexed voter, uint256 indexed proposalIndex);

    Vote public voteContract;
    address public deployer;
    address public voter1;
    address public voter2;
    address public stranger;

    function setUp() public {
        // 准备四个测试账户
        deployer  = makeAddr("deployer");
        voter1    = makeAddr("voter1");
        voter2    = makeAddr("voter2");
        stranger  = makeAddr("stranger");

        // deployer 部署合约并添加三个初始提案
        vm.startPrank(deployer);
        voteContract = new Vote();
        voteContract.addVote("Option A"); // idx 0
        voteContract.addVote("Option B"); // idx 1
        voteContract.addVote("Option C"); // idx 2
        vm.stopPrank();
    }

    // ==================== 构造函数和所有者测试 ====================

    function testOwnerIsDeployer() public {
        assertEq(voteContract.owner(), deployer, "Deployer should be the contract owner");
    }

    // ==================== addVote 函数测试 ====================

    function testAddVote() public {
        vm.startPrank(deployer);
        voteContract.addVote("New Option D");
        vm.stopPrank();

        assertEq(voteContract.getCountofVote(), 4, "Should have 4 proposals after adding one");
        (string memory name, uint256 count) = voteContract.getTargetVote(3);
        assertEq(name, "New Option D", "New proposal name should match");
        assertEq(count, 0, "New proposal vote count should be 0");
    }

    function testAddVote_OnlyOwner() public {
        vm.startPrank(voter1);
        vm.expectRevert("Only owner can call this function.");
        voteContract.addVote("Should not be added");
        vm.stopPrank();
    }

    // ==================== voteSelect 函数测试 ====================

    function testVoteSelect() public {
        vm.startPrank(voter1);
        // 1）先告诉 Forge 我们期望的事件
        vm.expectEmit(
            /* checkTopic1 */ true,
            /* checkTopic2 */ true,
            /* checkTopic3 */ false,
            /* checkData   */ true,
            address(voteContract)
        );
        emit VoteCast(voter1, 0);

        // 2）再真正调用，合约内部会 emit
        voteContract.voteSelect(0);
        vm.stopPrank();

        // 3）最后检查状态变化
        (, uint256 amount) = voteContract.getTargetVote(0);
        assertEq(amount, 1, "Option A vote count should be 1");
        assertTrue(voteContract.hasVoted(voter1), "Voter1 should be marked as voted");
    }

    function testVoteSelect_CannotVoteTwice() public {
        vm.startPrank(voter1);
        voteContract.voteSelect(0);
        vm.expectRevert("Already voted");
        voteContract.voteSelect(1);
        vm.stopPrank();
    }

    function testVoteSelect_InvalidIndex() public {
        vm.startPrank(voter1);
        vm.expectRevert("not valid index");
        voteContract.voteSelect(99);
        vm.stopPrank();
    }

    function testMultipleVoters() public {
        vm.startPrank(voter1);
        voteContract.voteSelect(0);
        vm.stopPrank();

        vm.startPrank(voter2);
        voteContract.voteSelect(1);
        vm.stopPrank();

        (, uint256 countA) = voteContract.getTargetVote(0);
        (, uint256 countB) = voteContract.getTargetVote(1);
        assertEq(countA, 1, "Option A should have 1 vote");
        assertEq(countB, 1, "Option B should have 1 vote");
        assertTrue(voteContract.hasVoted(voter1), "Voter1 should be voted");
        assertTrue(voteContract.hasVoted(voter2), "Voter2 should be voted");
    }

    // ==================== getCountofVote 函数测试 ====================

    function testGetCountofVote() public {
        assertEq(voteContract.getCountofVote(), 3, "Initial proposals count should be 3");
    }

    // ==================== getTargetVote 函数测试 ====================

    function testGetTargetVote() public {
        (string memory name0, uint256 amount0) = voteContract.getTargetVote(0);
        assertEq(name0, "Option A", "Name of proposal 0 should be 'Option A'");
        assertEq(amount0, 0, "Amount of proposal 0 should be 0 initially");
    }

    function testGetTargetVote_InvalidIndex() public {
        vm.expectRevert("invalid index");
        voteContract.getTargetVote(99);
    }

    // ==================== getMostVote 函数测试 ====================

    function testGetMostVote_NoVotesYet() public {
        (uint256 winnerIndex, uint256 winnerCount) = voteContract.getMostVote();
        assertEq(winnerIndex, 0, "Initial winner index should be 0");
        assertEq(winnerCount, 0, "Initial winner count should be 0");
    }

    function testGetMostVote_AfterVotes() public {
        // 三个不同地址分别投票
        vm.startPrank(voter1);
        voteContract.voteSelect(0); // A:1
        vm.stopPrank();

        vm.startPrank(voter2);
        voteContract.voteSelect(0); // A:2
        vm.stopPrank();

        vm.startPrank(stranger);
        voteContract.voteSelect(1); // B:1
        vm.stopPrank();

        (uint256 winnerIndex, uint256 winnerCount) = voteContract.getMostVote();
        assertEq(winnerIndex, 0, "Winner should be Option A");
        assertEq(winnerCount, 2, "Option A should have 2 votes");
    }

    function testGetMostVote_EmptyProposals() public {
        Vote emptyVoteContract = new Vote();
        (uint256 winnerIndex, uint256 winnerCount) = emptyVoteContract.getMostVote();
        assertEq(winnerIndex, 0, "Winner index should be 0 for empty proposals");
        assertEq(winnerCount, 0, "Winner count should be 0 for empty proposals");
    }
}
