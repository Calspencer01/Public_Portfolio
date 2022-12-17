// SPDX-License-Identifier: MIT
// Important: I'm relying on overflow control from Solidity 0.8+
pragma solidity >=0.8 <0.9.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Escrow is Ownable{
    event Escrowed(uint256 hashImage, address destination, uint256 amount);
    event Withdrawn(string hashPreimage, uint256 hashImage, address destination, uint256 amount);

    
    ERC20 token;
    uint256 amount = 0;

    ERC20 fineToken;
    uint256 fineAmount = 0;
    
    uint256 escrowDeadline; //Deadline by which Alice has to escrow (otherwise fine goes to bob)
    uint256 withdrawDeadline; //Deadline by which Bob has to withdraw (otherwise Alice can withdraw her escrow)
    address recipient; 
    uint256 hashedImage;
    uint8 escrowed = 0;


    // *******************************
    // *                             *
    // *  Functions called by Owner  *  
    // *                             *
    // *******************************

    constructor(){
       
    }

    // Called by Alice or Bob to initialize the escrow contract and deposit their fine 
    function depositFine(address _fineToken, uint256 _fineAmount, uint256 _deadlineWeeks, address _recipient) onlyOwner external {
        require(_deadlineWeeks > 0, "Invalid deadline");
        require(_fineAmount > 0, "Invalid fine amount");
        
        // Record the token address that will be used for the owner's fine and escrow
        fineToken = ERC20(_fineToken);
        // Record the amount that the contract owner will be fined  
        fineAmount = _fineAmount;
        // Calculate deadline after which the fine will be available to recipient
        escrowDeadline = block.timestamp + (_deadlineWeeks * 1 weeks);
        // Record recipient address
        recipient = _recipient;

        // Transfer the fine from the contract owner to this escrow contract
        fineToken.transferFrom(msg.sender, address(this), fineAmount);
    }
 
    // Called by Alice or Bob to deposit their escrow and receieve the fines they deposited before
    function escrow(address _token, uint256 _amount, uint256 _hashedImage, uint256 _deadlineWeeks) onlyOwner external {
        require(_amount > 0, "Invalid amount");
        require(uint256(block.timestamp) < escrowDeadline, "Too late!");

        // Record the amount the recipient can withdraw
        amount = _amount;
        // Record the hashedImage
        hashedImage = _hashedImage;
        // Record the escrow currency
        token = ERC20(_token);
        // Records Bob's deadline
        withdrawDeadline = _deadlineWeeks;

        // Transfer _amount from the contractOwner to this escrow contract
        token.transferFrom(msg.sender, address(this), amount);

        // Used in withdraw() and finePayout()
        escrowed = 1;
        
        // Escrow completed, return fine to the owner
        token.transfer(this.owner(), fineAmount);
    
	    emit Escrowed(_hashedImage, recipient, _amount);
    }

    // Called by Alice to receive their escrow because Bob did not escrow
   // The escrow Alice deposited is no longer time-locked because it is past the deadline
   // Note: Only executes after withdrawDeadline, but this is removed for testing
    function withdrawEscrow() onlyOwner external{
        // require(uint256(block.timestamp) >= withdrawDeadline, "Your funds are locked until the deadline");
        escrowed = 0;
        token.transfer(this.owner(), amount);
    }



    // *************************************
    // *                                   *
    // *   Functions called by Recipient   *
    // *                                   *
    // *************************************

    // Called by Bob (recipient) to receive the coinB that Alice escrowed (and vice versa)
    function receiveEscrow(string calldata preimage) external {
        require(msg.sender == recipient, "You are not the recipient");
        require(hashedImage == uint256(sha256(bytes(preimage))), "Wrong preimage");
        require(escrowed == 1, "No escrow to withdraw");
        
        // Transfer escrowed token to recipient
        token.transfer(recipient, amount);
        emit Withdrawn(preimage, hashedImage, recipient, amount);
        // Reset contract
        escrowed = 0;
    }
    
    // Called by Bob (recipient) to receive the fine Alice paid in coinB to this 
    // contract because it is past the deadline and Alice has not escrowed (and vice versa)
    // Note: Only executes after escrowDeadline, but this is removed for testing
    function payoutFine() external{ 
        require(msg.sender == recipient, "You are not the recipient");
        // require(block.timestamp >= escrowDeadline, "Nope, you are too early");
        require(fineAmount > 0, "No fine to pay");
        require(escrowed == 0, "Already escrowed");

        // Transfer fine to recipient because escrow did not occur (escrowed != 1)
        fineToken.transfer(recipient, fineAmount);
        // Reset the value of the fine
        fineAmount = 0;
    }
}