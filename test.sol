// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;
contract Hellworld{
  
    string stringval ="hello world";
    //写一个可读的函数
    function sayhello() public view returns(string memory)//这部分是函数的声明
    {
        return concactstring(stringval);
    }
    //写一个修改的函数
    function sethelloworld(string memory newString) public {
       stringval = newString;
    }
    //对字符串进行拼接或者说是计算
    function concactstring(string memory string1) internal pure returns(string memory) {
            return string.concat(string1,"from frank's contract");
    }
}
