// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Fundme} from "./fundMe.sol"; //不要忘记这里的分号
//1.让Fundme的参与者 基于mapping 领取相应的token
//2.让Fundme的参与者 自由的transfer token
//3. 在使用token以后 需要burn通证

contract FundMeERC20 is ERC20 {
    Fundme fundme; //声明这个变量
     constructor(address fundmeaddr)  ERC20("FundTokenERC20","FT") {
        fundme =Fundme(fundmeaddr); 
     } 
     //就是这种写法 {}代表函数体 不需要任何操作
     //初始化完成 
    //让参与者领取token 需要铸造通证
     function mint(uint256 amountTomint) public {
        require(fundme.FunderstoAmount(msg.sender)>=amountTomint,"you cannot mint this amount token");
        require(fundme.getfundsuccess(),"the fundme is not complete");
        _mint(msg.sender,amountTomint); //给其这么多的通证 已经给到了这个地址 现在要减去相应的值;
        fundme.SetFunderToAmount(msg.sender,fundme.FunderstoAmount(msg.sender)-amountTomint);
     }
        //claim 兑换 使用完成后 就要burn掉 
     function claim(uint256 amountClaim) public {
        // comlete claim 完成兑换
        // burn 相应数量的amountClaim
       require(balanceOf(msg.sender)>=amountClaim,"you dont have enough ERC20token"); 
       require(fundme.getfundsuccess(),"the fundme is not complete");
       _burn(msg.sender,amountClaim); //烧掉这么多的ERC20token


     }
}
//我不理解 这里的fundMe = FundMe(fundMeAddr); 因为 FundMe的构造函数不是要传入uint256 locktime_吗
 //为什么传入的是地址，第二，fundMe.fundersToAmount(msg.sender) 难道不是fundMe.fundersToAmount[msg.sender]吗 
 //因为 fundersToAmount是一个mapping呀
/* 第一个问题：fundMe = FundMe(fundMeAddr); 为什么传入的是地址而不是 uint256 locktime_？
这里涉及到的是Solidity中合约的实例化和类型转换。

FundMe(fundMeAddr) 并不是在调用 FundMe 合约的构造函数。
当你在一个合约（FundTokenERC20）中想要与另一个已经部署的合约（FundMe）进行交互时，你需要一个该合约的实例
（instance）。这个实例是基于其地址和**接口（ABI）**来创建的，而不是通过再次调用其构造函数来部署一个新的合约。

FundMe(fundMeAddr) 的作用是创建一个 FundMe 类型的合约实例。
这行代码的含义是：

将 fundMeAddr（一个已部署的 FundMe 合约的地址）类型转换为 FundMe 类型。
这样，fundMe 变量就成为了一个可以用来调用 FundMe 合约中公共函数的对象，就像你在JavaScript中获取一个DOM元素对象一样。
构造函数只在合约部署时执行一次。
FundMe 合约的构造函数 constructor(uint256 _lockTime) 只在 FundMe 合约首次部署到区块链上时执行。一旦部署完成，你不能再次调用它的构造函数来改变其内部状态（比如 lockTime）。

总结来说，fundMe = FundMe(fundMeAddr); 的目的是让 FundTokenERC20 合约能够通过已知的 FundMe 合约地址来
与之进行通信和调用其公共函数，而不是部署一个新的 FundMe 合约。

第二个问题：fundMe.fundersToAmount(msg.sender) 难道不是 fundMe.fundersToAmount[msg.sender] 吗？
因为 fundersToAmount 是一个 mapping。
这是一个关于Solidity中 public 状态变量的自动生成getter函数的特性。

public mapping 的自动生成getter函数：
在 FundMe 合约中，你声明了 mapping(address => uint256) public fundersToAmount;。
当一个状态变量被声明为 public 时，Solidity编译器会自动为它生成一个同名的getter函数。
对于 mapping 类型的 public 状态变量，这个自动生成的getter函数会接受 mapping 的 key 作为参数，并返回对应 value。

fundMe.fundersToAmount(msg.sender) 的实际意义：
因此，fundMe.fundersToAmount(msg.sender) 实际上是在调用 FundMe 合约中由编译器为 fundersToAmount 这个 public mapping 自动生成的getter函数。这个函数接收 msg.sender 作为参数，并返回 msg.sender 在 fundersToAmount mapping 中对应的 uint256 值。

fundersToAmount[msg.sender] 用于内部访问：
fundersToAmount[msg.sender] 这种语法是在合约内部直接访问 mapping 中的值时使用的。例如，在 FundMe 合约的 fund() 函数中，你会看到 fundersToAmount[msg.sender] = msg.value;。

所以，在 FundTokenERC20 合约中，为了访问 FundMe 合约中的 fundersToAmount mapping 的值，你需要通过自动生成的 public getter函数来调用，这就是 fundMe.fundersToAmount(msg.sender) 的原因。
 */
