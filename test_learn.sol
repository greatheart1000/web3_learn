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

    Info[] infos;

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
