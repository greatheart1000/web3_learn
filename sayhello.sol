// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract Hello{
        // bool boolvar =true;
        // bool boolvar2=false;
        // uint256 a=100;
        // uint64 b=12;
        // int128 c=-1;
        // string num ='fggfg';
        // bytes32 str="hello world";
        string addstr="heelo world";
    //声明一个结构体
    address myaddr=0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    struct Info{string phrase;
    uint256 id;
    address addr;}
    Info[] infos;

    function sayhello(uint256 _id) public  view returns(string memory){
        for (uint256 i=0;i<infos.length;i++){
            if (infos[i].id==_id){
                return addstring(infos[i].phrase);
            }
            return addstring(addstr);
        }
        return addstring(addstr);
    }
    //直接赋值 把上面的字符串改变了 
    function sethelloworld(string memory newstring,uint256 _id) public{
        addstr = newstring;
        Info memory info=Info(newstring, _id ,msg.sender);
        infos.push(info);
        
    }

    //字符串加别的字符
    function addstring(string memory newstr) internal pure returns (string memory) {
        return string.concat(newstr,"from caijian's change");
    }
}
