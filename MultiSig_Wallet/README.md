### 一、项目简介
多重签名钱包（Multi‐Sig Wallet）要求交易必须得到预先设定数量的「所有者」（owners）共同签名 / 确认后，才能执行。常见场景：

公司金库：大额转账必须 N 个财务负责人中至少 M 人同意
DAO 资金库：核心成员投票后才执行支出
### 二、核心难点
权限管理

如何确保只有配置的 owners 能提交&确认交易 <br>
可动态添加/移除 owners 并调整阈值  <br>
交易生命周期

提交（submit）、确认（confirm）、撤销确认（revoke）、执行（execute） <br>
状态管理：防止重复执行
阈值保障

确保只有当同一笔交易获得 ≥M 个不同 owner 确认后，才允许执行 <br>
安全性 : <br>
防重放、重入攻击（Re-entrancy） <br>
防止死锁：一旦 owners 不可用或阈值过高后交易永远无法执行 <br>
离线签名（可选进阶） <br>

使用 EIP-712 让 owner 在钱包外签名，然后聚合提交，节省 on-chain 交互次数 <br>
### 三、实现思路
在合约构造时，传入 owners 列表和 required（确认阈值）

用一个自增 txIndex 标识每笔待执行交易，交易结构体 Transaction 包含目标地址、金额、调用数据、执行状态、已确认人数等 <br>

存两张映射： <br>

mapping(uint => Transaction) public transactions; <br>
mapping(uint => mapping(address => bool)) public isConfirmed; <br>
四个核心方法：

submitTransaction(...)：由某个 owner 提交一笔新交易 <br>
confirmTransaction(txId)：owner 对 txId 进行确认，确认数达到阈值时可执行 <br>
revokeConfirmation(txId)：owner 收回自己的确认 <br>
executeTransaction(txId)：当确认数 ≥ 阈值，真正发起 call <br>
关键事件：Submit, Confirm, Revoke, Execute  <br>

防重入：给 executeTransaction 加 nonReentrant（可用 OpenZeppelin 的 ReentrancyGuard） <br>
```
