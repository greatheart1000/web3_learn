// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 如果需要ERC20代币捐赠 (当前代码未用到，但保留导入)
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// 管理合约所有权
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol"; 
// 防重入
// 注意：OpenZeppelin Contracts v5+ 版本中 ReentrancyGuard 移到了 utils 目录下
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol"; 
// 导入 Foundry 的 console.log 用于调试 (仅开发环境使用)
import {console} from "forge-std/console.sol";

contract DecentralizedCharity is Ownable, ReentrancyGuard {
    // 移除不使用的 owner 状态变量，因为 Ownable 已经提供了
    // address public owner; 

    // 枚举定义项目状态
    enum CampaignStatus {
        Pending,    // 待审核 (如果需要审核)
        Active,     // 进行中，可捐赠
        Funded,     // 已达成筹款
        Expired,    // 已过期未达成目标
        Withdrawed, // 资金已全部取出
        Cancelled   // 项目被取消，未通过 
    }

    // 慈善项目的具体信息结构体
    struct Campaign {
        string name;            // 项目名称
        address creator;        // 发起人
        string description;     // 项目描述
        uint256 target_amount;  // 筹款目标
        uint256 raisedAmount;   // 已筹集金额 (注意拼写统一)
        uint256 withdrawAmount; // 已取款金额 (注意拼写统一)
        uint256 createTime;     // 项目发起时间
        uint256 deadline;       // 项目截止时间
        CampaignStatus status;  // 项目状态
        uint256 mileStoneStatus; // 里程碑状态
        uint256 lastWithdrawTime; // 上次取款时间 (注意拼写统一)
    }

    // nextCampaignID 用于为新项目生成唯一ID
    uint256 public nextCampaignID; 
    // id -> 项目详情映射
    mapping(uint256 => Campaign) public campaigns; 
    // 发起人地址 -> 他创建的项目ID列表 (方便查询)
    mapping(address => uint256[]) public creatorCampaigns; 

    // --- 构造函数 ---
    // 将部署者设为合约拥有者
    constructor() Ownable(msg.sender) { 
        nextCampaignID = 0; // 初始化项目ID计数器
    }

    // --- 修饰符 ---
    // 检查项目ID是否存在且有效
    modifier campaignExists(uint256 _campaignId) {
        require(_campaignId < nextCampaignID, "Campaign does not exist."); 
        _; // 执行被修饰函数的主体代码
    }

    // 检查调用者是否为项目的创建者
    modifier onlyCreatorCampaign(uint256 _campaignId) {
        require(campaigns[_campaignId].creator == msg.sender, "Only creator can manage this project.");
        _;
    }

    // --- 事件：方便链下监听 ---
    event CampaignCreated(
        uint256 indexed campaignId,
        address indexed creator,
        uint256 target_amount,
        uint256 indexed deadline
    );

    event CampaignStatusChanged(
        uint256 indexed campaignId,
        CampaignStatus oldStatus,
        CampaignStatus newStatus
    );

    event Donated(
        uint256 indexed campaignId,
        address indexed addr,
        uint256 value
    );

    event FundsWithdrawn(
        uint256 indexed campaignId,
        address indexed addr,
        uint256 value
    );

    // --- 1. 创建慈善项目的实现 ---
    // 谁可以调用： 任何人。
    // 参数： 项目名称、描述、筹款目标 (ETH)、筹款截止日期 (例如，当前时间 + 多少秒)。
    // 逻辑：
    // 生成新的 campaignId。
    // 初始化 Campaign 结构体，creator 为 msg.sender，status 为 Active。
    // 将新项目添加到 campaigns mapping。
    // 更新 nextCampaignId。
    // 发出 CampaignCreated 事件。
    function createCampaign(
        string memory _name,
        string memory _description,
        uint256 _target_amount,
        uint256 _durationInDays // 以天为单位
    ) public {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_target_amount > 0, "Target amount must be greater than 0");
        require(_durationInDays > 0, "Duration must be at least 1 day");

        uint256 newcampaignId = nextCampaignID;
        uint256 deal_time = block.timestamp + (_durationInDays * 1 days); // 计算截止时间

        // 初始化一个慈善项目并存储
        campaigns[newcampaignId] = Campaign({
            name: _name,
            creator: msg.sender, // 修正为 creator
            description: _description,
            target_amount: _target_amount, // 修正为 _target_amount
            raisedAmount: 0,
            withdrawAmount: 0, // 修正拼写
            createTime: block.timestamp,
            deadline: deal_time,
            status: CampaignStatus.Active, 
            mileStoneStatus: 0,
            lastWithdrawTime: 0 // 修正拼写
        });

        creatorCampaigns[msg.sender].push(newcampaignId); // 记录发起人创建的项目ID
        emit CampaignCreated(newcampaignId, msg.sender, _target_amount, deal_time);
        nextCampaignID++; 
    }

    // --- 2. 捐赠 donate ---
    // 谁可以调用： 任何人。
    // 参数： campaignId。
    // 逻辑：
    // payable 函数，接收 ETH。
    // 检查 campaignId 是否存在。
    // 检查项目状态是否为 Active 且未过期 (block.timestamp <= campaign.deadline)。
    // 增加 campaign.raisedAmount。
    // 如果 raisedAmount 达到或超过 goalAmount，更新 status 为 Funded，
    // 发出 CampaignStatusChanged 事件。
    // 发出 Donated 事件。

    // receive() 函数：用于接收不带数据的 ETH
    receive() external payable {
        // 允许直接向合约发送ETH，但不推荐，应该通过donate函数
        revert("Please use the donate function to send funds.");
    }
    
    // donate 函数：处理带 campaignId 的捐赠
    function donate(uint256 _campaignId) 
        public 
        payable 
        nonReentrant 
        campaignExists(_campaignId) 
    {
        require(msg.value > 0, "Donation amount must be greater than 0");

        Campaign storage campaign = campaigns[_campaignId]; // 结构体 
        // 检查项目状态和截止日期
        require(campaign.status == CampaignStatus.Active, "Campaign is not active for donations.");
        require(block.timestamp < campaign.deadline, "Campaign has expired.");

        campaign.raisedAmount += msg.value; // 增加已筹集金额 (注意拼写)

        // 检查是否达到目标
        if (campaign.raisedAmount >= campaign.target_amount && campaign.status != CampaignStatus.Funded) { // 使用 >=
            CampaignStatus oldStatus = campaign.status;
            campaign.status = CampaignStatus.Funded; // 如果筹款金额大于等于目标，改变状态 
            emit CampaignStatusChanged(_campaignId, oldStatus, CampaignStatus.Funded);
        }
        emit Donated(_campaignId, msg.sender, msg.value); // 在 if 块外部，每次捐赠都发出事件
    }

    // --- 2.3. 提款 withdrawFunds (挑战点：分阶段提款) ---
    // 谁可以调用： campaign.creator。
    // 参数： campaignId, amount (要提取的金额)。
    // 逻辑：
    // 检查 campaignId 是否存在。
    // 检查调用者是否为 campaign.creator。
    // 检查项目状态是否为 Funded。
    // 检查请求提款的 amount 是否有效：
    // amount > 0。
    // campaign.withdrawAmount + amount <= campaign.raisedAmount (不能提取超过已筹集的)。
    // 更新 campaign.withdrawAmount。
    // 将 ETH 发送给 campaign.creator (使用 call 防止重入问题)。
    // 如果所有资金都已提取（即 withdrawAmount == target_amount 且 status == Funded），更新 status 为 Withdrawed。
    // 发出 FundsWithdrawn 事件。
    function withdrawFunds(uint256 _campaignId, uint256 _amount) 
        public
        nonReentrant 
        campaignExists(_campaignId)
        onlyCreatorCampaign(_campaignId) // 使用修饰符检查是否为创建者
    {
        // 初始化这个筹款项目 
        Campaign storage campaign = campaigns[_campaignId];

        // 状态检查：必须是 Funded 才能提款
        require(campaign.status == CampaignStatus.Funded, "Campaign is not funded or already withdrawn/cancelled.");
        require(_amount > 0, "Withdrawal amount must be greater than 0."); 

        // 检查提款金额是否合法
        require(campaign.withdrawAmount + _amount <= campaign.raisedAmount, "Cannot withdraw more than raised funds."); 

        // 更新已取款金额
        campaign.withdrawAmount += _amount; 

        // 将 ETH 发送给创建者
        (bool success, ) = payable(campaign.creator).call{value: _amount}("");
        require(success, "Failed to withdraw funds."); // 取款必须成功

        // 如果所有可提款的资金都已提取
        // 这里的逻辑可以根据你的“里程碑”设计调整。
        // 如果是达到目标金额后才能提光，则检查 withdrawAmount >= target_amount
        if (campaign.withdrawAmount >= campaign.target_amount) { // 修正拼写
            CampaignStatus oldStatus = campaign.status;
            campaign.status = CampaignStatus.Withdrawed; // 资金已全部取出 更新状态
            emit CampaignStatusChanged(_campaignId, oldStatus, CampaignStatus.Withdrawed); // 更新日志
        }
        emit FundsWithdrawn(_campaignId, campaign.creator, _amount); // 每次提款都发出事件
    }

    // --- 2.4. 获取项目信息 getCampaign 和 getCampaignsByCreator ---
    // 谁可以调用： 任何人 (view 函数)。
    // 参数： campaignId 或 creatorAddress。
    // 逻辑： 返回 Campaign 结构体的所有字段，或返回某个发起人创建的所有项目ID列表。
    function getCampaign(uint256 _campaignId) public view campaignExists(_campaignId) 
        returns(
            string memory name,        // 项目名称
            address creator,           // 发起人
            string memory description, // 项目描述
            uint256 target_amount,     // 筹款目标
            uint256 raisedAmount,      // 已筹集金额
            uint256 withdrawAmount,    // 已取款金额
            uint256 createTime,        // 项目发起时间
            uint256 deadline,          // 项目截止时间
            CampaignStatus status,     // 项目状态
            uint256 mileStoneStatus,   // 里程碑状态
            uint256 lastWithdrawTime   // 上次取款时间
        ) 
    {
        // 获取单个项目详情
        Campaign storage campaign = campaigns[_campaignId];
        return (
            campaign.name,
            campaign.creator,
            campaign.description,
            campaign.target_amount,
            campaign.raisedAmount,
            campaign.withdrawAmount,
            campaign.createTime,
            campaign.deadline,
            campaign.status,
            campaign.mileStoneStatus,
            campaign.lastWithdrawTime
        );
    }

    // 获取所有项目总数
    function getTotalCampaigns() public view returns(uint256){
        return nextCampaignID; // nextCampaignID 存储的是下一个可用的ID，也表示已创建项目的总数
    }

    // 获取某个发起人创建的所有项目ID
    function getCampaignsByCreator(address _addr) public view returns(uint256[] memory){
        return creatorCampaigns[_addr];
    }

    // --- 2.5. 更新项目状态 (外部可调用，用于过期项目) ---
    // 这是一个可以由任何人调用来更新过期项目状态的函数（非 view 函数，因为会修改状态）
    function updateCampaignStatus(uint256 _campaignId) public campaignExists(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        // 如果项目仍然是 Active 且已过截止日期但未达到目标
        if (campaign.status == CampaignStatus.Active && block.timestamp >= campaign.deadline) { // >= 因为时间点到达即过期
            // 确保未达到目标金额
            if (campaign.raisedAmount < campaign.target_amount) {
                CampaignStatus oldStatus = campaign.status; 
                campaign.status = CampaignStatus.Expired;
                emit CampaignStatusChanged(_campaignId, oldStatus, CampaignStatus.Expired);
            }
        }
    }

    // 合约拥有者取消项目 (例如，发现项目是骗局或不合规)
    function cancelCampaign(uint256 _campaignId) public onlyOwner campaignExists(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        // 确保你不能取消一个已经被标记为 Withdrawed 或 Cancelled 的项目。
        require(
            campaign.status != CampaignStatus.Withdrawed && 
            campaign.status != CampaignStatus.Cancelled,
            "Campaign cannot be cancelled in current state."
        );
        CampaignStatus oldStatus = campaign.status; 
        campaign.status = CampaignStatus.Cancelled;
        emit CampaignStatusChanged(_campaignId, oldStatus, CampaignStatus.Cancelled);
    }
}