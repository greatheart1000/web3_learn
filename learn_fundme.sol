pragma solidity ^0.8.20;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Fundme{
    //创建一个众筹的合约，这个合约有收款功能，有退款功能 通过函数来接受funder的ETH
    //1.当筹到了目标值的钱后，筹款者可以提取钱款
    //2. 当筹到的金额小于目标值，可以把收到的钱退回给投资者
    //3.投资人可以查看，并记录投资人每个人的投资款
    uint256 MIN_VALUE =100*10**18; //设置最小额度 
    //现在想设置为USD 
    AggregatorV3Interface internal dataFeed; //变量声明也得复制过来

    //构造函数 变量声明会使用，通常在第一次的时候使用，后面不会再声明了 
    //https://docs.chain.link/data-feeds/price-feeds/addresses?page=1&testnetPage=1&network=ethereum&search=
    constructor(){
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }
    mapping(address => uint256) public FunderstoAmount;//记录投资人的 这是一个字典
    function fund() external payable {
        require(ConvertEthtoUSD(msg.value)>=MIN_VALUE,"the money is too low,send more ETH");
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
}
