// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import { MultiSigWallet } from "../src/multi-sig.sol";

contract DeployMultiSigWallet is Script {
    function run() external {
        // 从环境变量读取 owner 列表，也可以直接写死
        address owner1 = vm.envAddress("OWNER1");
        address owner2 = vm.envAddress("OWNER2");
        address owner3 = vm.envAddress("OWNER3");

        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        uint256 requiredConfirmations = 2;

        vm.startBroadcast(); // 开始广播交易
        new MultiSigWallet(owners, requiredConfirmations);
        vm.stopBroadcast();  // 结束广播
    }
}