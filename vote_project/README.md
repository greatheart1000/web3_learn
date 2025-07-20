## Foundry

Foundry 是一个用 Rust 编写的极速、便携且模块化的以太坊应用开发工具集。 <br>
Foundry 包括： <br>
Forge： 以太坊测试框架（类似于 Truffle、Hardhat 和 DappTools）。 <br>
Cast： 与 EVM 智能合约交互、发送交易和获取链上数据的瑞士军刀（多功能工具）。 <br>
Anvil： 本地以太坊节点，类似于 Ganache、Hardhat Network。 <br>
Chisel： 快速、实用且详细的 Solidity REPL（交互式命令行环境）。 <br>
https://book.getfoundry.sh/ <br>

## Usage

### Build

```shell
$ forge build
```
### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```
### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

###  创建新的 Foundry 项目 <br>
mkdir my-voting-project  <br>
cd my-voting-project  <br>
forge init <br>
放置你的合约文件：   <br>
将你之前编写的 Vote.sol 文件放到 src 目录下。 <br>
例如：my-voting-project/src/Vote.sol  <br>


编写部署脚本 (Solidity Script)  <br>
我们将使用 forge script 来编写和执行部署。 <br>

创建部署脚本文件： <br>
在 script 目录下创建一个新的 Solidity 文件，例如 DeployVote.s.sol。 <br>
文件路径：my-voting-project/script/DeployVote.s.sol  <br>

编写部署脚本内容： <br>
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Script} from "forge-std/Script.sol";
import {Vote} from "../src/Vote.sol"; // 导入你的合约
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
```

#### 部署合约到本地开发网络 (Anvil)
Anvil 是 Foundry 提供的一个本地 EVM 实例，非常适合开发和测试。
1. 启动 Anvil：
打开一个新的终端窗口（保持当前 Foundry 项目终端的打开），然后运行：
```
anvil
```
Anvil 会启动一个本地区块链，并显示一些测试账户和私钥。它通常监听在 http://127.0.0.1:8545。

2. 在原始终端中部署合约：
回到你的 Foundry 项目终端，运行部署脚本。
``` forge script script/DeployVote.s.sol --rpc-url http://127.0.0.1:8545 --broadcast --verify --ffi ```

script/DeployVote.s.sol: 指定要运行的部署脚本文件。 <br>
--rpc-url http://127.0.0.1:8545: 指定连接到本地 Anvil 实例。  <br>
--broadcast: 告诉 Forge 执行交易（实际部署合约）。 <br>
--verify (可选): 如果你部署到公共测试网或主网，它会尝试验证合约代码，但对于本地 Anvil 无需。这里加上是为了模拟真实部署流程。<br>
--ffi (可选): 允许脚本调用外部程序，虽然当前脚本可能用不到，但经常与 script 一起使用。 <br>
执行后，你应该会看到交易被发送，合约被部署，并最终在输出中看到合约的地址。 <br>

编写测试用例 (Solidity Test)   <br>
现在我们来编写一些测试，验证你的合约功能。  <br>

创建测试文件：  <br>
在 test 目录下创建一个新的 Solidity 文件，例如 Vote.t.sol。  <br>
文件路径：my-voting-project/test/Vote.t.sol  <br>
编写测试内容：  <br>
forge test 
