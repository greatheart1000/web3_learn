// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Hellworld} from"./test.sol";

contract HelloWorldFactory{
        Hellworld hw;//在HelloWorldFactory成功创建了一个Hellworld合约
        Hellworld[] hws; //声明一个以Hellworld合约的数组
        function createHelloworld() public { //这个是创建合约的函数
            hw = new Hellworld();
            hws.push(hw); //创建一个合约同时将其存入到hws 
        }
        //这是创建读取合约的函数
        function getHelloworldbyIndex(uint256 _index) public view returns (Hellworld){
            return hws[_index];
        }

}
