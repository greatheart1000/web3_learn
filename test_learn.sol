为什么可以不返回？

在 Solidity/EVM 的交易（transaction）模型里，状态修改型函数（也就是不带 view/pure 的函数）本质上是发了一笔交易到链上，改变了合约的存储。
对于这类交易，区块链节点并不会把“return data”当作 RPC 调用的结果回传给发起者——你发完交易，只能拿到一个交易哈希（tx hash），无法直接读到 Solidity 里 return 的值。
所以，绝大多数做状态修改的函数都干脆不写返回值：它们只做写状态，并通过事件（event）或后续的 view 函数来让外部读取结果。
如果你真的想给调用者返回值，有两种途径：

在内部调用时（contract→contract），你可以写 returns(...) 然后 return x;，调用合约 A 的合约 B 会拿到返回值。
在 RPC 层面想知道写入的结果，通常用 event：
 setHelloWorld 不需要返回值，这是一个状态修改函数 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HelloWorld {
    string strVar = "Hello World";
  
    struct Info {
        string phrase;
        uint256 id;
        address addr;
    }

    Info[] infos; //声明了一个动态数组 infos 来存储 Info 结构体的实例

    mapping(uint256 id => Info info) infoMapping;
  
    function sayHello(uint256 _id) public view returns(string memory) {
        if(infoMapping[_id].addr == address(0x0)) {
            return addinfo(strVar); 
        } else {
            return addinfo(infoMapping[_id].phrase);
        }
    }
    
    function setHelloWorld(string memory newString, uint256 _id) public {
        Info memory info = Info(newString, _id, msg.sender);
        infoMapping[_id] = info;
    }


    function addinfo(string memory helloWorldStr) internal pure returns(string memory) {
        return string.concat(helloWorldStr, " from Frank's contract.");
    }
}
// 获取数组中某个位置的 Info 实例
    function getInfo(uint256 index) public view returns (string memory, uint256, address) {
        require(index < infos.length, "Index out of bounds");
        return (infos[index].phrase, infos[index].id, infos[index].addr);
    }

    // 获取数组的长度
    function getInfosLength() public view returns (uint256) {
        return infos.length;
    }

############################################################### 重新学习 加深印象
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Helloworld{
    string strval ="hello world";
    struct Info {
        string word;
        uint256 id;
        address addr;
    }
    Info[] infos; //声明一个数组类别的结构体
    mapping(uint256 id => Info info) mappvar ;

    function sayhello(uint256 num) public view returns(string memory ){
        if (mappvar[num].addr==address(0x0)){
            return strval;
        }
        else {
            return mappvar[num].word;
        }
    
        //for关键字 遍历
    //     for(uint256 i = 0; i<infos.length; i++)
    //     {
    //         if(infos[i].id == num ){
    //             return addstring(infos[i].word);
    //         }
    //         return strval;

    //     }
    // } 
    //不给这个sayhello函数传参数,只是单纯地给其返回变量strval

    function setHelloworld(string memory newstring,uint256 id_) public {
        // strval =newstring;
        Info memory info= Info(newstring, id_,  msg.sender);
        mappvar[id_] =info; //键值对
        infos.push(info); //注意这里 变量是info 
    } //此函数是改变变量strval的值的函数

    function addstring(string memory str1) internal pure returns(string memory){
        return string.concat(str1,"from fank's contract");
    } //这里的 internal pure 就是不希望外部调用 pure关键字说明这是单纯的计算函数

}
################################################
