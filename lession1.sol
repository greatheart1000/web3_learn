// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;
contract Hellworld{
    bool boolvar = true;
    bool boolvar1 = false;
    uint256 num =100;
    int8 num1= -1;
    bytes32 bytevar="hello world";
    string stringval ="hello world";
    address addvar =0xC6F2Ee18072B353E1f921DD1615DC4634650002b;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;
contract Hellworld{
  
    string stringval ="hello world";
    //写一个可读的函数
    function sayhello() public view returns(string memory)//这部分是函数的声明
    {
        return stringval;
    }
    //写一个修改的函数
    function sethelloworld(string memory newString) public {
       stringval = newString;
    }
    //对字符串进行拼接或者说是计算 pure关键字是进行运算
    function concactstring(string memory string1) internal pure returns(string memory) {
            return string.concat(string1,"from frank's contract");
    }
}
}
