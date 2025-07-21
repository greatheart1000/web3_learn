// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; // 确保与你的合约版本一致

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol"; // 用于调试打印

// 导入你的慈善合约。
// 注意：这里的路径是相对于 script 目录的，并且合约名称需要正确。
// 如果你的合约名为 DecentralChart，请改为 import {DecentralChart} from "../src/DecentralizedCharity.sol";
// 假设你的合约文件名为 DecentralizedCharity.sol，并且合约内部名称也是 DecentralizedCharity
import {DecentralizedCharity} from "../src/DecentralizedCharity.sol";

contract DeployCharity is Script {
    function run() public returns (DecentralizedCharity charityContract) {
        // 开始一个新的广播交易块。所有在此块内进行的外部调用都将被视为交易。
        // vm.startBroadcast() 会从当前默认的私钥（通常是你的第一个地址）发送交易。
        // 部署到测试网或主网时，通常会使用 vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        // 但对于本地 Anvil，默认行为已经足够。
        vm.startBroadcast();
        // 部署你的 DecentralizedCharity 合约
        // 如果你的合约名称是 DecentralChart，这里就写 new DecentralChart();
        charityContract = new DecentralizedCharity();

        // 结束广播交易块。
        vm.stopBroadcast();
        // 打印部署的合约地址，方便你查看和后续交互
        //assumeAddressIsNotconsole.log("Decentralized Charity contract deployed to:", address(charityContract));
    }
}