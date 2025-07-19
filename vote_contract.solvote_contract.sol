// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;
//设计一个简单的投票合约 
/**好的，我们来设计一个简单的投票合约。
一、思路（Thought Process）
实现一个投票合约的核心目标是让用户可以对预设的选项进行投票，并且确保每个用户只能投一次票，最终可以查看投票结果。
谁能创建投票？ 通常是合约的部署者（owner），他可以添加投票选项。
投票选项如何存储？ 我们需要一个数据结构来存储每个选项的名称和当前的票数。一个结构体（struct）和数组（array）的组合很合适。
如何防止重复投票？ 我们需要一个机制来记录哪些地址已经投过票。一个映射（mapping）可以很好地实现这一点，将地址映射到布尔值（表示是否已投票）。
投票函数：
它应该接收一个参数，表示用户想投票给哪个选项（通常是选项的索引）。
在投票前，检查投票者是否已经投过票。
检查投票的选项索引是否有效。
增加对应选项的票数。
更新投票者的投票状态。
查看结果： 提供函数来查询某个选项的票数，或者获取所有选项的详细信息。
事件（Events）： 发出事件以便外部应用（如前端界面）可以监听投票的发生和投票选项的添加。
所有者特权： 只有合约所有者才能添加投票选项。这可以通过一个 onlyOwner 修饰器来实现。**/
contract Vote{
    // 设置管理者
    address public onwer;
    //每个人对应的票数
    struct Proposal{
        string name;  // 选项名称
        uint256 amount;// 该选项获得的票数
    }
    //
    Proposal[] proposals;

    //
    mapping (address => uint) votes;

    //是否已经投票过
    mapping(address=>bool) hasVoted;
    // 事件：当一个新的投票选项被添加时触发 indexed 关键字时，这个参数的值会被存储在一个特殊的、可搜索的索引中
    event ProposalAdded(uint256 indexed index ,string name);

    //投票过触发
    event VoteCast(address indexed index, uint256 indexed proposalIndex);
    // 事件：当投票结束时触发（可选，但对于更复杂的逻辑有用）
    event VotingEnded();

    constructor(){
        address owner =msg.sender; // 将部署合约的地址设为owner
        }
    // 修饰器：只允许owner调用
    modifier onlyOwner(){
            require(msg.sender==onwer,"Only owner can call this function.");
            _;
        }
    
    //只有没投票的才能够进行投票
    modifier addressisValid(){
        require(!hasVoted[msg.sender],"has not voted");
        _;

    }
    /// @notice 添加一个新的投票选项
    /// @param _name 投票选项的名称
    function addVote(string memory _name) public onlyOwner {
        proposals.push(Proposal(_name,0));
        //触发事件
        emit ProposalAdded(proposals.length-1,_name); // 发出事件，索引是数组的最后一个
    }
     /// @notice 对指定的投票选项进行投票
    /// @param _proposalIndex 要投票的选项的索引
    function voteSelect(uint256 _proposalIndex) public addressisValid {
        require(_proposalIndex<proposals.length-1,"not valid index");
         // 增加对应选项的票数
        proposals[_proposalIndex].amount++;
         // 标记此地址已投票
        hasVoted[msg.sender]=true;
        emit VoteCast(msg.sender,_proposalIndex);//发出投票事件
    }
    /// @notice 获取所有投票选项的数量
    /// @return 投票选项的总数
    function getCountofVote() public view returns(uint256) {
        return proposals.length;
    }
    
    // @notice 获取指定索引的投票选项信息
    // @param _proposalIndex 投票选项的索引
    // @return name 选项名称
    // @return voteCount 选项票数
    function getTargetVote(uint256 _proposalIndex) public view returns(string memory name,
    uint256 amount){
        require(_proposalIndex < proposals.length,"invalid index");
        Proposal storage proposal = proposals[_proposalIndex];
        return (proposal.name,proposal.amount) ;
    }
    // @notice 获取当前投票结果中，票数最高的选项（简单版本，不处理平局）
    // @return winningProposalIndex 获胜选项的索引
    // @return winningVoteCount 获胜选项的票数
    function getMostVote() public view returns(uint256 winnerindex, uint256 winnercount){
        if (proposals.length==0){
            return (0,0); // 没有提案
        }
    winnerindex =0;
    winnercount = proposals[0].amount;
    for (uint256 i=1;i<proposals.length;i++){
        if (proposals[i].amount>winnercount){
            winnercount =proposals[i].amount;
            winnerindex =i;    
        }
    }
    }
    }
