// SPDX-License-Identifier: MIT
pragma solidity >=0.8 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract VestingManager is Ownable, ReentrancyGuard{
    IERC20 token;

    struct Vesting {
        address beneficiary;
        // uint256 amountRemaining;
        uint256 amountClaimed;
        uint256 totalVested;
        uint256 startTime;

        uint256 vestingPeriod;
    }

    mapping(address => Vesting) vestings;

    constructor(address _token) {
        token = IERC20(_token);
    }

    event VestingCreated(address beneficiary, uint256 amount);
    event VestingReleased(address beneficiary, uint256 amount);
    event Claimed(address beneficiary, uint256 amount);


    // Only the contract owner should call it
    function createVesting(address _beneficiaryAddress, uint256 _totalAllocation, uint256 _vestingWeeks) external onlyOwner nonReentrant {
        // When a new vesting struct is made, beneficiary is set to _beneficiaryAddress, so if uninitialized ( == address(0)), go ahead and make the struct
        require(vestings[_beneficiaryAddress].beneficiary == address(0), "Beneficiary already has a vesting struct.");
        require(_totalAllocation > 0, "Amount must be positive");
        require(_vestingWeeks > 0 && _vestingWeeks <= 1000, "Invalid vesting time length");

        // Pull funds from caller (owner)
        token.transferFrom(this.owner(), address(this), _totalAllocation);

        // Record in vestings
       vestings[_beneficiaryAddress] = Vesting({
                                        beneficiary: _beneficiaryAddress, 
                                        totalVested: _totalAllocation, 
                                        amountClaimed: 0, 
                                        startTime: block.timestamp, 
                                        vestingPeriod: (_vestingWeeks * (1 seconds))
                                    });

        emit VestingCreated(_beneficiaryAddress, _totalAllocation);
    }

    // Only the contract owner should call it
    function releaseVesting(address _beneficiaryAddress) external onlyOwner nonReentrant{
        require(vestings[_beneficiaryAddress].beneficiary == _beneficiaryAddress, "Beneficiary does not have a vesting.");
      
        // Check beneficiary address
        require(vestings[_beneficiaryAddress].beneficiary == _beneficiaryAddress, "Beneficiary does not have a vesting.");

        // Check if any funds are ready
        uint256 unclaimedReady = ready(_beneficiaryAddress);
        require(unclaimedReady > 0, "No funds available");
        
        // Return unclaimed to beneficiary
        token.transfer(_beneficiaryAddress, unclaimedReady);

        // Update struct
        vestings[_beneficiaryAddress].amountClaimed += unclaimedReady;

        emit VestingReleased(_beneficiaryAddress, unclaimedReady);

    }

    function vested(address _beneficiaryAddress) public view returns (uint256) {
        require(vestings[_beneficiaryAddress].beneficiary == _beneficiaryAddress, "Beneficiary does not have a vesting.");
        
        return (vestings[_beneficiaryAddress].totalVested);
    }

    function claimed(address _beneficiaryAddress) public view returns (uint256) {
        require(vestings[_beneficiaryAddress].beneficiary == _beneficiaryAddress, "Beneficiary does not have a vesting.");
        
        return (vestings[_beneficiaryAddress].amountClaimed);
    }

    function unclaimed(address _beneficiaryAddress) public view returns (uint256) {
        require(vestings[_beneficiaryAddress].beneficiary == _beneficiaryAddress, "Beneficiary does not have a vesting.");
        require(vestings[_beneficiaryAddress].totalVested > vestings[_beneficiaryAddress].amountClaimed, "Error, claimed more than allowed");
        
        return (vestings[_beneficiaryAddress].totalVested - vestings[_beneficiaryAddress].amountClaimed);
    }

    function ready(address _beneficiaryAddress) public view returns (uint256) {
        require(vestings[_beneficiaryAddress].beneficiary == _beneficiaryAddress, "Beneficiary does not have a vesting.");
        uint256 available = vestingFunction(_beneficiaryAddress, block.timestamp);
        
        return (available - vestings[_beneficiaryAddress].amountClaimed);
    }

    function claimReady() external nonReentrant{
        // Check beneficiary address
        require(vestings[msg.sender].beneficiary == msg.sender, "Beneficiary does not have a vesting.");

        // Check if any funds are ready
        uint256 unclaimedReady = ready(msg.sender);
        require(unclaimedReady > 0, "No funds available");
        
        // Return unclaimed to sender
        token.transfer(msg.sender, unclaimedReady);

        // Update struct
        vestings[msg.sender].amountClaimed += unclaimedReady;
        emit Claimed(msg.sender, unclaimedReady);
    }

    function vestingFunction(address _beneficiaryAddress, uint256 _blockTimestamp) internal view virtual returns (uint256) {
        require(vestings[_beneficiaryAddress].beneficiary == _beneficiaryAddress, "Beneficiary does not have a vesting.");

        uint256 x = _blockTimestamp;
        uint256 s = vestings[_beneficiaryAddress].startTime;
        uint256 f = vestings[_beneficiaryAddress].vestingPeriod;

        /* 1. If the provided block timestamp precedes the vesting instance’s creation block timestamp
            (call it s for “start”), there’s nothing available to be claimed: return 0;
        */
        if (x <= s){
            return(0);
        }
        /* 2. If the provided block timestamp succeeds the vesting instance’s creation block timestamp
            plus the total vesting period in blocks (call it f for “finish”), return the total vested value minus the previously claimed amount.
        */
        else if (x >= (s + f)){
            return(unclaimed(_beneficiaryAddress));
        }
        /* 3. If the provided block timestamp is x, between s and f, return (x−s/f) times the total
            vested value. Remember that Solidity rounds down to zero, so be attentive to not always return zero here.
        */
        else {
            uint256 available = (vested(_beneficiaryAddress) * (x - s)) / f;
            return (available);
        }
    }
}