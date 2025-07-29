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
anchor init solana-playground  创建一个solana项目  <br>
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


Uniswap 是以太坊区块链上的去中心化交易所（DEX），它基于自动化做市商（AMM，Automated Market Maker）模型，而不是传统的订单簿交易系统。
Uniswap 由 Hayden Adams 于 2018 年推出，其核心目标是促进以太坊网络中 ERC-20 代币的流动性交易。

Uniswap 的核心特点
1. 去中心化
没有中心化的控制方，所有交易直接在智能合约中完成。
2. 自动化做市商（AMM）模型
Uniswap 通过一个数学公式（x×y=kx \times y = kx×y=k）自动平衡买卖双方的价格和流动性，而非依赖传统的订单簿。
3. 流动性池
用户可以将代币存入流动性池，为市场提供流动性，并从中获得交易手续费作为奖励。
4. 无需许可（Permissionless）
任何人都可以在 Uniswap 上创建交易对或添加流动性，而无需第三方授权。
5. 完全透明
所有的交易和流动性池操作都记录在以太坊的公开区块链上。

Uniswap 的工作原理
1. 流动性池
Uniswap 使用流动性池（Liquidity Pool）而不是买卖订单簿。
每个交易对（如 ETH/USDT）都有一个池子，流动性提供者（Liquidity Providers, LPs）通过存入一对代币（例如 1 ETH 和等值的 USDT）为池子提供流动性。
2. 恒定乘积公式（x×y=kx \times y = kx×y=k）
Uniswap 使用恒定乘积公式来维持池子的平衡：
● xxx：流动性池中一种代币的数量。
● yyy：流动性池中另一种代币的数量。
● kkk：恒定值，代表总池子价值。
当用户交易代币时，Uniswap 会调整池中代币的数量以确保公式始终成立。
3. 手续费
每笔交易收取 0.3% 的手续费，作为奖励分配给流动性提供者。
4. 价格滑点
由于恒定乘积公式的限制，大额交易会显著影响池中代币的比例，导致价格滑点（Slippage）。

Uniswap 的版本更新
1. Uniswap V1（2018）
  ○ 只支持 ETH 和 ERC-20 代币的交易对。
  ○ 用户需要在交易中将 ETH 用作中间媒介。
2. Uniswap V2（2020）
  ○ 支持 ERC-20 与 ERC-20 的直接交易对。
  ○ 引入闪电贷（Flash Swaps）。
  ○ 改进价格预言机。
3. Uniswap V3（2021）
  ○ 引入集中流动性（Concentrated Liquidity），允许流动性提供者选择价格范围，提高资本效率。
  ○ 提供多个手续费级别（如 0.05%、0.3%、1%）。
  ○ 极大提高了交易效率和流动性管理灵活性。


