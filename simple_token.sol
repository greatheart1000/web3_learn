// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract Fundtoken{
     //ERC20，NFT，Hardhat，CCIP跨链  这是最简单的token发行 2025/6/4 23:00
    //创建通证
    //1.通证名字
    //2.通证简称
    //3.发行数量
    //4 .owner 谁有最高权限
    //5. balance address=>unint256 ;

    //mint : 铸造一些token到某些地址里面 获取通证
    //transfer : 转移token 
    // balanceOf :查看某个地址通证的数量
    string public TokenName;
    string public tokenSymbol;
    uint256 public  TokenNumber;
    address public owner;
    mapping(address =>uint256) public balances;
    //构造函数 初始化
    constructor(string memory tokenName,
    string memory tokensymbol){
            TokenName = tokenName;
            tokenSymbol = tokensymbol;
            owner = msg.sender;

    }
    //这里 没有涉及到ETH 之类的地址的交换，只是修改了某个地址的值
    //mint : 铸造一些token到某些地址里面 获取通证
    function mint(uint256 addressToamount) public {
        balances[msg.sender] +=addressToamount ;
        TokenNumber+=addressToamount ; //总的通证也要增加

    }
     //transfer : 转移token  address payee谁要得到token,谁的地址,uint256 amount得到多少的token
     function transfer(address payee,uint256 amount) public {
        require(balances[msg.sender]>=amount,"the token is not enough");
        balances[msg.sender]-=  amount; //发起人要减掉这么多token 
        balances[payee] += amount ;//接收人要增加这么多token 
     }

    // balanceOf :查看某个地址通证的数量
    function balanceOf(address newaddr) public view returns(uint256) {
        return balances[newaddr]; //直接返回token数量
    }

}
