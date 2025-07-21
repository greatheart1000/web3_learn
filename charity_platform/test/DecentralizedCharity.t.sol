// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DecentralizedCharity} from "../src/DecentralizedCharity.sol";

contract DecentralizedCharityTest is Test {
    DecentralizedCharity public charity; 
    address public deployer; 
    address public alice;    
    address public bob;      

    function setUp() public {
        deployer = makeAddr("deployer"); 
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        vm.startHoax(deployer);
        charity = new DecentralizedCharity(); 
        vm.stopHoax(); 
    }

    function test_CreateCampaign_Success() public {
        vm.startHoax(alice);
        string memory name = "Save the Trees";
        string memory description = "Planting trees to fight deforestation.";
        uint256 targetAmount = 1 ether; 
        uint256 durationInDays = 30; 

        charity.createCampaign(name, description, targetAmount, durationInDays);
        vm.stopHoax();

        uint256 campaignId = 0; 
        (
            string memory retrievedName,
            address retrievedCreator,
            string memory retrievedDescription,
            uint256 retrievedTargetAmount,
            uint256 retrievedRaisedAmount,
            uint256 retrievedWithdrawAmount,
            uint256 retrievedCreateTime,
            uint256 retrievedDeadline,
            DecentralizedCharity.CampaignStatus retrievedStatus, // 修正：使用 charity.CampaignStatus
            uint256 retrievedMileStoneStatus,
            uint256 retrievedLastWithdrawTime
        ) = charity.getCampaign(campaignId);

        assertEq(retrievedName, name, "Campaign name mismatch");
        assertEq(retrievedCreator, alice, "Campaign creator mismatch");
        assertEq(retrievedTargetAmount, targetAmount, "Campaign target amount mismatch");
        assertEq(retrievedRaisedAmount, 0, "Initial raised amount should be 0");
        assertEq(uint256(retrievedStatus), uint256(charity.CampaignStatus.Active), "Campaign status should be Active"); 

        assertEq(charity.getTotalCampaigns(), 1, "nextCampaignID should be 1");
    }

    function test_CreateCampaign_RevertOnEmptyName() public {
        vm.startHoax(alice);
        vm.expectRevert("Name cannot be empty"); 
        charity.createCampaign("", "desc", 1 ether, 30);
        vm.stopHoax();
    }

    function test_CreateCampaign_RevertOnZeroTargetAmount() public {
        vm.startHoax(alice);
        vm.expectRevert("target amount must be greater than 0"); 
        charity.createCampaign("name", "desc", 0, 30);
        vm.stopHoax();
    }

    function test_Donate_Success() public {
        vm.startHoax(alice);
        charity.createCampaign("Test Campaign", "Desc", 1 ether, 30);
        vm.stopHoax();
        uint256 campaignId = 0;

        vm.startHoax(bob);
        uint256 donationAmount = 0.5 ether;
        vm.deal(bob, 1 ether); 
        
        vm.expectEmit(true, true, true, true); 
        emit charity.Donated(campaignId, bob, donationAmount);

        vm.expectNoEmit();

        charity.donate{value: donationAmount}(campaignId);
        vm.stopHoax();

        (, , , , uint256 raisedAmount, , , , , , ) = charity.getCampaign(campaignId);
        assertEq(raisedAmount, donationAmount, "Raised amount should match donation");
    }

    function test_Donate_BecomesFunded() public {
        vm.startHoax(alice);
        charity.createCampaign("Funding Test", "Desc", 1 ether, 30);
        vm.stopHoax();
        uint256 campaignId = 0;

        vm.startHoax(bob);
        uint256 donationAmount = 1 ether;
        vm.deal(bob, 1 ether);
        
        vm.expectEmit(true, true, true, true);
        emit charity.Donated(campaignId, bob, donationAmount);

        vm.expectEmit(true, true, true, true);
        emit charity.CampaignStatusChanged(campaignId, charity.CampaignStatus.Active, charity.CampaignStatus.Funded); // 修正：使用 charity.CampaignStatus

        charity.donate{value: donationAmount}(campaignId);
        vm.stopHoax();

        (, , , , uint256 raisedAmount, , , , DecentralizedCharity.CampaignStatus status, , ) = charity.getCampaign(campaignId); // 修正：使用 charity.CampaignStatus
        assertEq(raisedAmount, donationAmount, "Raised amount should match exact target");
        assertEq(uint256(status), uint256(charity.CampaignStatus.Funded), "Campaign status should be Funded"); // 修正：使用 charity.CampaignStatus
    }

    function test_Donate_RevertOnZeroDonation() public {
        vm.startHoax(alice);
        charity.createCampaign("Test", "Desc", 1 ether, 30);
        vm.stopHoax();
        uint256 campaignId = 0;

        vm.startHoax(bob);
        vm.expectRevert("Donation amount must be greater than 0");
        charity.donate{value: 0}(campaignId); 
        vm.stopHoax();
    }

    function test_Donate_RevertOnExpiredCampaign() public {
        vm.startHoax(alice);
        charity.createCampaign("Expiring", "Desc", 1 ether, 1); 
        vm.stopHoax();
        uint256 campaignId = 0;

        vm.warp(block.timestamp + 2 days); 

        vm.startHoax(bob);
        vm.deal(bob, 1 ether);
        vm.expectRevert("Campaign has expired.");
        charity.donate{value: 0.1 ether}(campaignId);
        vm.stopHoax();
    }

    function test_WithdrawFunds_Success() public {
        vm.startHoax(alice);
        charity.createCampaign("Withdraw Test", "Desc", 1 ether, 30);
        vm.stopHoax();
        uint256 campaignId = 0;

        vm.startHoax(bob);
        vm.deal(bob, 1 ether);
        charity.donate{value: 1 ether}(campaignId);
        vm.stopHoax();

        vm.startHoax(alice);
        uint256 withdrawAmount = 0.5 ether;
        uint256 initialCreatorBalance = alice.balance; 

        vm.expectEmit(true, true, true, true);
        emit charity.FundsWithdrawn(campaignId, alice, withdrawAmount);
        
        vm.expectNoEmit();

        charity.withdrawFunds(campaignId, withdrawAmount);
        vm.stopHoax();

        (, , , , , uint256 currentWithdrawAmount, , , , , ) = charity.getCampaign(campaignId);
        assertEq(currentWithdrawAmount, withdrawAmount, "Withdrawal amount mismatch");
        assertEq(alice.balance, initialCreatorBalance + withdrawAmount, "Creator balance not updated correctly");
    }

    function test_WithdrawFunds_RevertIfNotCreator() public {
        vm.startHoax(alice);
        charity.createCampaign("Auth Test", "Desc", 1 ether, 30);
        vm.stopHoax();
        uint256 campaignId = 0;

        vm.startHoax(bob);
        vm.deal(bob, 1 ether);
        charity.donate{value: 1 ether}(campaignId);
        vm.stopHoax();

        vm.startHoax(bob);
        vm.expectRevert("Only creator can manage this project."); 
        charity.withdrawFunds(campaignId, 0.1 ether);
        vm.stopHoax();
    }

    function test_WithdrawFunds_BecomesWithdrawed() public {
        vm.startHoax(alice);
        charity.createCampaign("Full Withdraw", "Desc", 1 ether, 30);
        vm.stopHoax();
        uint256 campaignId = 0;

        vm.startHoax(bob);
        vm.deal(bob, 1 ether);
        charity.donate{value: 1 ether}(campaignId);
        vm.stopHoax();

        vm.startHoax(alice);
        uint256 withdrawAmount = 1 ether; 

        vm.expectEmit(true, true, true, true);
        emit charity.FundsWithdrawn(campaignId, alice, withdrawAmount);

        vm.expectEmit(true, true, true, true);
        emit charity.CampaignStatusChanged(campaignId, charity.CampaignStatus.Funded, charity.CampaignStatus.Withdrawed); // 修正：使用 charity.CampaignStatus

        charity.withdrawFunds(campaignId, withdrawAmount);
        vm.stopHoax();

        (, , , , , , , , DecentralizedCharity.CampaignStatus status, , ) = charity.getCampaign(campaignId); // 修正：使用 charity.CampaignStatus
        assertEq(uint256(status), uint256(charity.CampaignStatus.Withdrawed), "Campaign status should be Withdrawed"); // 修正：使用 charity.CampaignStatus
    }

    function test_UpdateCampaignStatus_ToExpired() public {
        vm.startHoax(alice);
        charity.createCampaign("Expired Test", "Desc", 1 ether, 1); 
        vm.stopHoax();
        uint256 campaignId = 0;

        vm.warp(block.timestamp + 2 days); 

        vm.startHoax(bob); 
        
        vm.expectEmit(true, true, true, true);
        emit charity.CampaignStatusChanged(campaignId, charity.CampaignStatus.Active, charity.CampaignStatus.Expired); // 修正：使用 charity.CampaignStatus

        charity.updateCampaignStatus(campaignId);
        vm.stopHoax();

        (, , , , , , , , DecentralizedCharity.CampaignStatus status, , ) = charity.getCampaign(campaignId); // 修正：使用 charity.CampaignStatus
        assertEq(uint256(status), uint256(charity.CampaignStatus.Expired), "Campaign status should be Expired"); // 修正：使用 charity.CampaignStatus
    }

    function test_UpdateCampaignStatus_NoChangeIfNotExpiredOrFunded() public {
        vm.startHoax(alice);
        charity.createCampaign("No Change Test", "Desc", 1 ether, 30);
        vm.stopHoax();
        uint256 campaignId = 0;

        vm.startHoax(bob);
        vm.expectNoEmit(); 
        charity.updateCampaignStatus(campaignId);
        vm.stopHoax();

        (, , , , , , , , DecentralizedCharity.CampaignStatus status, , ) = charity.getCampaign(campaignId); // 修正：使用 charity.CampaignStatus
        assertEq(uint256(status), uint256(charity.CampaignStatus.Active), "Campaign status should remain Active"); // 修正：使用 charity.CampaignStatus
    }
    
    function test_CancelCampaign_Success() public {
        vm.startHoax(alice);
        charity.createCampaign("Cancel Test", "Desc", 1 ether, 30);
        vm.stopHoax();
        uint256 campaignId = 0;

        vm.startHoax(deployer); 
        
        vm.expectEmit(true, true, true, true);
        emit charity.CampaignStatusChanged(campaignId, charity.CampaignStatus.Active, charity.CampaignStatus.Cancelled); // 修正：使用 charity.CampaignStatus

        charity.cancelCampaign(campaignId);
        vm.stopHoax();

        (, , , , , , , , DecentralizedCharity.CampaignStatus status, , ) = charity.getCampaign(campaignId); // 修正：使用 charity.CampaignStatus
        assertEq(uint256(status), uint256(charity.CampaignStatus.Cancelled), "Campaign status should be Cancelled"); // 修正：使用 charity.CampaignStatus
    }

    function test_CancelCampaign_RevertIfNotOwner() public {
        vm.startHoax(alice);
        charity.createCampaign("Cancel Auth Test", "Desc", 1 ether, 30);
        vm.stopHoax();
        uint256 campaignId = 0;

        vm.startHoax(alice);
        vm.expectRevert("Ownable: caller is not the owner"); 
        charity.cancelCampaign(campaignId);
        vm.stopHoax();
    }
}