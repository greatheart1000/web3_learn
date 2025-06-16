# 相关资料
## MetaMask
i[image](https://github.com/greatheart1000/web3_learn/blob/master/web3%E8%BD%AC%E5%9E%8B%E8%87%AA%E5%AD%A6%E8%B7%AF%E7%BA%BF%E5%9B%BE_%E5%89%AF%E6%9C%AC.jpg)
学习资料 https://github.com/smartcontractkit/Web3_tutorial_Chinese  
编程环境 https://remix.ethereum.org/
https://docs.chain.link/   <br>MetaMask
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
npm init 创建一个 nodejs项目，会有package.json文件        <br>
code . vscode 打开当前的文件夹       <br>

npm install hardhat --save-dev  <br>安装 hardhat包 只有开发环境使用 安装后 package.json多了内容 <br>"devDependencies": {
    "hardhat": "^2.24.2"
  }
npx hardhat  通过npm 创建一个hardhat项目 <br>
.gitignore 会忽略哪些文件 <br>

ignition文件夹 <br>
hardhat.config.js文件  <br>
contract文件夹 <br>
test文件夹 <br>
npm install @chainlink/contracts --save-dev 安装这个包 <br>
npm uninstall @chainlink/contracts 删除命令
npx hardhat compile 这个命令编译所有在contract文件夹的sol文件


Ethers.js的安装命令 npm install --save ethers <br>
ethers.js 的网址 https://docs.ethers.org/v6/api/ 
npx hardhat run scripts/DeployFundeMe.js

npm install --save-dev dotenv  安装第三方的包  <br>
Alchemy,Infura,QuickNode //第三方服务商  <br>
npm install --save-dev dotenv  <br>
npm install --save-dev @chainlink/env-enc 加密的包 明文变密文 <br>
npx env-enc set-pw 设置密码  <br>
npx env-enc set   <br>
SEPOLIE_URL       <br>
Please enter the variable value (input will be hidden):
**********************************************
Would you like to set another variable? Please enter the variable name (or press ENTER to finish):  <br>
PRIVATE_KEY  <br>
会多一个配置文件 显示如下: <br>
npm install --save-dev dotenv  
.env.enc
SEPLIO_URL: ENCRYPTED|YeqxnACd4b1r+iG3cz04PSUogDd5JN4UReAcHNMiVjdcrIeZ0AkuXdCsIR6Hpe5NprGWixsJ9jfO0xQjY0QGmii0Bqx/A2Vkn3Tb4tc7AJdkELZhp7Hi/yNbdUsmTA==      <br>
PRIVATE_KEY: ENCRYPTED|s7BL6qGaXjpbLDrNAVRLbANXqXRpZaSEh0DmP370Ie+Q3fweqTWnTciY06uEpssu9bBp5GF4               <br>

然后harthat.config.js里面的 require("dotenv").config 改为 require("@chainlink/env-enc").config() <br> 
require("@nomicfoundation/hardhat-toolbox"); <br>
require("dotenv").config  =>  require("@chainlink/env-enc").config() <br>
然后运行命令  npx hardhat run scripts/deployFundeMe.js --network sepolia   <br>



solana教程  https://ruilab.xyz/blockchain <br>

