// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Fundme{
    //创建一个众筹的合约，这个合约有收款功能，有退款功能 通过函数来接受funder的ETH
    //1.当筹到了目标值的钱后，筹款者可以提取钱款
    //2. 当筹到的金额小于目标值，可以把收到的钱退回给投资者
    //3.投资人可以查看，并记录投资人每个人的投资款
    uint256 constant MIN_VALUE =100*10**18; //设置最小额度 
    uint256 constant TARGET_NUM =1000*10**18; //constant关键词 常量 以后这个值就不会变
    address public  owner ; // 合约的所有者
    // 锁定期 两个变量 锁定期 从什么时候开始，第二，锁定期有多久
    uint256 deployTimestamp;
    uint256 locktime ; //秒
    address erc20Addr;
    bool public getfundsuccess; //默认都是false
    //现在想设置为USD 
    AggregatorV3Interface internal dataFeed; //变量声明也得复制过来

    //构造函数 变量声明会使用，通常在第一次的时候使用，后面不会再声明了 
    //https://docs.chain.link/data-feeds/price-feeds/addresses?page=1&testnetPage=1&network=ethereum&search=
    constructor(uint256 locktime_){
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner =msg.sender;
        deployTimestamp =block.timestamp; //block 环境变量 开始时间
        locktime =locktime_;


    }
    mapping(address => uint256) public FunderstoAmount;//记录投资人的 这是一个字典
    function fund() external payable {
        require(ConvertEthtoUSD(msg.value)>=MIN_VALUE,"the money is too low,send more ETH");
        require(block.timestamp < deployTimestamp + locktime, "window is closed");
        FunderstoAmount[msg.sender]=msg.value;
    } //这是一收款函数
    //https://docs.chain.link/data-feeds/getting-started#overview
   function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }
    function ConvertEthtoUSD(uint256 ETHamount) internal view  returns(uint256){
        uint256 Ethprice =uint(getChainlinkDataFeedLatestAnswer());
        return ETHamount*Ethprice/(10**8);
        //ETH USD 的精度 10**8
    }
    //锁定期内达到目标值，可以取钱
    //transfer transfer ETH  and revert if tx failed
    //send  transfer ETH  and if failed return false  if success  return true
    //call 不仅转账 还有金额 这种用call处 transfer ETH and data with value and bool

    function getFund() external windowClose OnlyOwner{
        //必须 限定 只有owner才能取钱
        
        require(ConvertEthtoUSD(address(this).balance)>= TARGET_NUM,"THE target is not reached");
        //require(block.timestamp>=deployTimestamp+ locktime ,"window is  not closed");
        // require(msg.sender ==owner,"only owner can call this function");//只有管理者才能取这个钱
        //payable(msg.sender).transfer(address(this).balance);
        //bool success =  payable(msg.sender).send(address(this).balance);
        //require(success,"tx failed");
        //(bool,result) =  addr.call{value: value}("") 公式 第三种写法
        bool success;
        (success, )= payable(msg.sender).call{value: address(this).balance}("");
        require(success,"transfer ETH is failed");
        FunderstoAmount[msg.sender]= 0; 
        getfundsuccess= true;

    }

    //
    //修改合约所有权  将合约所有者转移到别人
    function transferOwner(address newddr) public OnlyOwner { 
        // require(msg.sender==owner,"only owner can call this function");
        owner =newddr;

    }

    //投资期内 没达到目标值 就退款
    function refund() external   windowClose {
        require(ConvertEthtoUSD(address(this).balance)<TARGET_NUM,"THE target is  reached");
        require(FunderstoAmount[msg.sender]!=0,"you dont't send money");
        
         bool success;
        (success, )= payable(msg.sender).call{value: FunderstoAmount[msg.sender]}("");
         require(success,"transfer ETH is failed"); //需要其成功
         FunderstoAmount[msg.sender]= 0; //要清零

    }
        //1.funder 哪个地址进行修改 ，2. UpdateAmount修改的值  3.哪个合约可以调用 只允许ERC20Fundme调用
    function SetFunderToAmount(address funder,uint256 UpdateAmount) external {
            require(msg.sender==erc20Addr,"you dont not have permittiom to run this function");
            FunderstoAmount[funder] =UpdateAmount; //得到了更新
    }

    function setErc20Addr(address erc20addr_) public OnlyOwner {
        erc20Addr =erc20addr_;
    }
    //修改器 就是有多个同样的require用在多个地方
    modifier windowClose(){
            require(block.timestamp>= deployTimestamp+ locktime ,"window is opened");
            _; //这个下划线 是要先执行上面的
    }
    modifier  OnlyOwner(){
        require(msg.sender ==owner,"only owner can call this function");
         _;
    }
    
    
}
