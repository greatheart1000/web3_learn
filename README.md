# 相关资料
## MetaMask
![image](岗位转型路线规划图_副本.jpg)
Rust 资料 https://kaisery.github.io/trpl-zh-cn/ch01-02-hello-world.html  <br>
学习资料 https://github.com/smartcontractkit/Web3_tutorial_Chinese  
编程环境 https://remix.ethereum.org/
web3学习资料和工作机会 https://wcngrtwsafnt.feishu.cn/wiki/VqDqwq3jXirAkXkeHOFc4D9anof  <br>
https://docs.chain.link/   <br>
MetaMask  metamask登录密码 baichuan24G  <br>
 <br> https://kcno38rbm7bc.feishu.cn/wiki/OQ5lwXujliSOA4khSZjc0jagnYJ<br>
 Etherscan.io 这个网站的 账号: JianCai0706 密码: qPH8.!-UQ9e9g/5  <br>
 App Name: web3  APIKeyToken : 2GAIWVSPN4XMC1GVW7I4X1G5AS8CV95BZ1 <br>
  web3社区 https://discord.gg/hEKMJEwPXb <br>
 水龙头 https://faucets.chain.link/<br>
 查询网络的id 网址 https://chainlist.org/ 比如 Ethereum Sepolia 11155111  以太坊主网: Ethereum Mainnet 1
 https://faucets.chain.link/ 领取ETH测试网的币 <br>
 https://sepolia.etherscan.io/tx/0xa8b86d1b578f27c32ca76cbae8717eeab649b6a4b67f3074bf5c3fe9df78402a 查看交易记录 <br>
 跟我学 Solidity https://learnblockchain.cn/article/1952<br>

 ERC20 标准合约 https://docs.openzeppelin.com/contracts/4.x/erc20 <br>

 node -v <br>
 node init <br>
 npm install hardhat --save-dev <br>
 npx hardhat  node情况下运行某个命令 <br>
 怎么在这个路径下打开vscode呢 命令是什么 code . <br>

node -v 查看当前node的版本           <br>
#### 1. npm init 创建一个 nodejs项目，会有package.json文件        <br>
#### 2 . code . vscode 打开当前的文件夹       <br>

#### 3 .npm install hardhat --save-dev  <br>安装 hardhat包 只有开发环境使用 安装后 package.json多了内容 <br>"devDependencies": {
    "hardhat": "^2.24.2"
  }
#### 4 . npx hardhat  通过npm 创建一个hardhat项目 这时package.json会多 @nomicfoundation/hardhat-toolbox  还会多了contracts文件夹 <br>  
.gitignore 会忽略哪些文件 <br>

ignition文件夹 <br>
hardhat.config.js文件  <br>
contract文件夹 <br>
test文件夹 <br>
#### 5.  npm install @chainlink/contracts --save-dev 安装这个包 package.json的 devDependencies会多出 @chainlink/contracts <br>
#### 5.1 npm uninstall @chainlink/contracts 删除命令
#### 6.  npx hardhat compile 这个命令编译所有在contract文件夹的sol文件 显示： Compiled 2 Solidity files successfully (evm target: paris)


#### 7. Ethers.js的安装命令 npm install --save ethers <br>
ethers.js 的网址是: https://docs.ethers.org/v6/api/ <br>
#### 8. npx hardhat run scripts/DeployFundeMe.js   显示如下：<br>
contract is deploying <br>
contract has been deployed successfully,contract address is 0x5FbDB2315678afecb367f032d93F642f64180aa3 <br>
<br>
如果没成功就 rm -rf artifacts cache 再次运行 npx hardhat compile 以及npx hardhat run scripts/DeployFundeMe.js <br>
<br>
npm install --save-dev dotenv  安装第三方的包  <br>
##### Alchemy,Infura,QuickNode //第三方服务商  <br>
#### 9. npm install --save-dev dotenv  <br>
#### 10. npm install --save-dev @chainlink/env-enc  加密的包 明文变密文 <br>
#### 11. npx env-enc set-pw 设置密码111111  <br>
#### 12 . npx env-enc set   <br>
SEPOLIE_URL    PRIVATE_KEY    <br>
Please enter the variable value (input will be hidden):
**********************************************
Would you like to set another variable? Please enter the variable name (or press ENTER to finish):  <br>
PRIVATE_KEY  <br>
会多一个配置文件 显示如下: <br>
npm install --save-dev dotenv  
##### 13. 多出一个文件: .env.enc
SEPLIO_URL: ENCRYPTED|YeqxnACd4b1r+iG3cz04PSUogDd5JN4UReAcHNMiVjdcrIeZ0AkuXdCsIR6Hpe5NprGWixsJ9jfO0xQjY0QGmii0Bqx/A2Vkn3Tb4tc7AJdkELZhp7Hi/yNbdUsmTA==      <br>
PRIVATE_KEY: ENCRYPTED|s7BL6qGaXjpbLDrNAVRLbANXqXRpZaSEh0DmP370Ie+Q3fweqTWnTciY06uEpssu9bBp5GF4               <br>

#### 14. 然后harthat.config.js里面的 require("dotenv").config 改为 require("@chainlink/env-enc").config() <br> 
require("@nomicfoundation/hardhat-toolbox"); <br>
require("dotenv").config  =>  require("@chainlink/env-enc").config() <br>
然后运行命令  npx hardhat run scripts/deployFundeMe.js --network sepolia   <br>


npm install --save-dev @chainlink/env-enc



solana教程  https://ruilab.xyz/blockchain <br>

<br>
##### hardhat deploy官网有教程 大有收获： https://www.npmjs.com/package/hardhat-deploy <br>


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
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Vote} from "../src/Vote.sol";

contract VoteTest is Test {
    Vote public voteContract;
    address public deployer;
    address public voter1;
    address public voter2;

    function setUp() public {
        // 在每个测试函数运行之前执行，用于设置测试环境
        deployer = makeAddr("deployer"); // Foundry 内置的生成地址函数
        voter1 = makeAddr("voter1");
        voter2 = makeAddr("voter2");

        vm.startPrank(deployer); // 模拟 deployer 账户进行操作
        voteContract = new Vote();
        vm.stopPrank();

        // 添加一些提案
        vm.startPrank(deployer);
        voteContract.addProposal("Proposal A"); // index 0
        voteContract.addProposal("Proposal B"); // index 1
        vm.stopPrank();
    }

    function testOwnerIsDeployer() public view {
        assertEq(voteContract.owner(), deployer);
    }

    function testAddProposal() public {
        vm.startPrank(deployer);
        voteContract.addProposal("New Proposal");
        vm.stopPrank();
        (string memory name, uint256 count) = voteContract.getProposal(2);
        assertEq(name, "New Proposal");
        assertEq(count, 0);
    }

    function testOnlyOwnerCanAddProposal() public {
        vm.startPrank(voter1); // 模拟普通用户 voter1
        vm.expectRevert("Only owner can call this function"); // 期望操作会回滚并带有特定消息
        voteContract.addProposal("Should Fail");
        vm.stopPrank();
    }

    function testVote() public {
        vm.startPrank(voter1);
        voteContract.vote(0); // voter1 投给 Proposal A
        vm.stopPrank();

        (string memory nameA, uint256 countA) = voteContract.getProposal(0);
        assertEq(countA, 1);
        assertTrue(voteContract.hasVoted(voter1));
        assertEq(voteContract.votedProposalIndex(voter1), 0);
    }

    function testCannotVoteTwice() public {
        vm.startPrank(voter1);
        voteContract.vote(0); // 第一次投票
        vm.expectRevert("You have already voted"); // 期望第二次投票会回滚
        voteContract.vote(1); // 尝试再次投票
        vm.stopPrank();
    }

    function testInvalidProposalIndex() public {
        vm.startPrank(voter1);
        vm.expectRevert("Invalid proposal index");
        voteContract.vote(99); // 投给不存在的提案
        vm.stopPrank();
    }

    function testMultipleVotes() public {
        vm.startPrank(voter1);
        voteContract.vote(0);
        vm.stopPrank();

        vm.startPrank(voter2);
        voteContract.vote(1);
        vm.stopPrank();

        (, uint256 countA) = voteContract.getProposal(0);
        (, uint256 countB) = voteContract.getProposal(1);

        assertEq(countA, 1);
        assertEq(countB, 1);
    }
} ```
