// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Vote} from "../src/Vote.sol"; // 导入你的合约
import {console} from "forge-std/console.sol";

contract DeployVote is Script {
    function run() public returns (Vote voteContract) {
        // 开始一个新的广播交易块。所有在此块内进行的外部调用都将被视为交易。
        // vm.startBroadcast() 会从当前默认的私钥（通常是你的第一个地址）发送交易。
        // 或者，你可以指定私钥：vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        vm.startBroadcast();

        // 部署 Vote 合约
        voteContract = new Vote();

        // 结束广播交易块。
        vm.stopBroadcast();

        // 打印部署的合约地址（可选，方便调试）
        console.log("Vote contract deployed to:", address(voteContract));
    }
}