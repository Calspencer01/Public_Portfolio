// SPDX-License-Identifier: MIT
// Important: I'm relying on overflow control from Solidity 0.8+
pragma solidity >=0.8 <0.9.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "hardhat/console.sol";

import "contracts/Swapper.sol";

contract AMM is Ownable, ReentrancyGuard {

    mapping(address => mapping (address => uint256)) swapperId;
    mapping(uint256 => Swapper) swappers;

    uint256 nSwappers = 0;

    event SwapperCreated(uint256 swapperId, address token1, address token2);
	event LiquidityAdded(uint256 swapperId, address provider, uint256 value1, uint256 value2);
	event LiquidityRemoved(uint256 swapperId, address provider, uint256 value1, uint256 value2);
	
    
    // TODO
    //make convert interal, get functions, TODOS, emits,// TODO addresses before nums in params 
    // require statements, create swapper if doesnt exist
    // pointer to storage location
    // switch order of token.transfers
    // provider rewards require
    // Function identifiers

    function getSwapper(ERC20 _token1, ERC20 _token2) public view returns (uint256) {
		return swapperId[address(_token1)][address(_token2)];
	}

    function createSwapper(ERC20 _token1, uint256 _value1, ERC20 _token2, uint256 _value2) external nonReentrant {
        require(_value1 > 0 && _value2 > 0, "Token values should be positive in order to create swapper");
        require(swapperId[address(_token1)][address(_token2)] == 0, "Swapper already exists");
        
        // Record the increase in number of swappers
        nSwappers++;

        // ID of the swapper = number of swappers (once included)
        uint256 newId = nSwappers;

        // Update map to get ID from tokens
        swapperId[address(_token1)][address(_token2)] = newId;

       // Create new swapper
        swappers[newId] = new Swapper(_token1, _value1, _token2, _value2, newId, msg.sender);

        // Transfer liquidity from provider
		_token1.transferFrom(msg.sender, address(this), _value1);
		_token2.transferFrom(msg.sender, address(this), _value2);

		emit SwapperCreated(newId, address(_token1), address(_token2));
    }

    function swap(uint256 _swapperId, uint256 _amount, Swapper.Direction _direction) external {
		require(_amount > 0, "Amount should be positive");
        uint256 amount1;
		uint256 amount2;

        // Swap within a specific swapper
        (amount1, amount2) = swappers[_swapperId].swap(_amount, _direction);

        // Transfer amounts returned by Swapper.swapper_swap()
        if (_direction == Swapper.Direction.FirstToSecond){
            swappers[_swapperId].get_token1().transferFrom(msg.sender, address(this), amount1);
	        swappers[_swapperId].get_token2().transfer(msg.sender, amount2);
        }
        else {
            swappers[_swapperId].get_token2().transferFrom(msg.sender, address(this), amount1);
			swappers[_swapperId].get_token1().transfer(msg.sender, amount2);
        }
	}

    function addLiquidity(uint256 _swapperId, uint256 _amount, Swapper.Direction _direction) external nonReentrant {
        uint256 amount;
		uint256 converted;

        // Add liquidity to a specific swapper from a specific provider
        (amount, converted) = swappers[_swapperId].addLiquidity(_amount, _direction, msg.sender);

        // Transfer amounts returned by Swapper.addLiquidity()
        if (_direction == Swapper.Direction.FirstToSecond){
            swappers[_swapperId].get_token1().transferFrom(msg.sender, address(this), amount);
			swappers[_swapperId].get_token2().transferFrom(msg.sender, address(this), converted);
			
            emit LiquidityAdded(_swapperId, msg.sender, amount, converted);
        } else {
            swappers[_swapperId].get_token2().transferFrom(msg.sender, address(this), amount);
			swappers[_swapperId].get_token1().transferFrom(msg.sender, address(this), converted);
			
            emit LiquidityAdded(_swapperId, msg.sender, amount, converted);
        }
       // Update liquidity rewards 
        rewardSwapperLiquidity(_swapperId);
    }

    function removeLiquidity(uint256 _swapperId, uint256 _amount, Swapper.Direction _direction) external nonReentrant {
        uint256 amount;
		uint256 converted;
        
        // Add liquidity to a specific swapper from a specific provider
        (amount, converted) = swappers[_swapperId].removeLiquidity(_amount, _direction, msg.sender);
       
       // Transfer amounts returned by Swapper.addLiquidity()
        if (_direction == Swapper.Direction.FirstToSecond){
            swappers[_swapperId].get_token1().transfer(msg.sender, _amount);
			swappers[_swapperId].get_token2().transfer(msg.sender, converted);
			
            emit LiquidityRemoved(_swapperId, msg.sender, amount, converted);
        } else {
            swappers[_swapperId].get_token1().transfer(msg.sender, _amount);
			swappers[_swapperId].get_token2().transfer(msg.sender, converted);
			
            emit LiquidityRemoved(_swapperId, msg.sender, amount, converted);
        }

       // Update liquidity rewards 
        rewardSwapperLiquidity(_swapperId);
    }

    // Remove all of a provider's liquidity from a specific swapper
    function clearLiquidity(uint256 _swapperId) external nonReentrant {
        swappers[_swapperId].clearLiquidity(msg.sender);
    }

    // Reward liqudity for all swappers
    function rewardLiquidity() internal {
        for (uint256 i = 1; i <= nSwappers; i++){
            rewardSwapperLiquidity(i);
        }
	}

    // Reward liquidty to all providers in a swapper
    function rewardSwapperLiquidity(uint256 _swapperId) internal {
        uint256 rewards1;
        uint256 rewards2;
        address provider;

        // Get maximum provider ID
        uint256 max_providerId = swappers[_swapperId].get_nProviders();

		// Assumes IDs range from 1:nProviders (not 0:nProviders-1)
        // Iterate through all provider IDs
		for (uint256 i = 1; i <= max_providerId; i++){
            // Get value of rewards for each provider
			(provider, rewards1, rewards2) = swappers[_swapperId].providerRewards(i);

            // Transfer rewards
            swappers[_swapperId].get_token1().transfer(provider, rewards1);
		    swappers[_swapperId].get_token2().transfer(provider, rewards2);
        }
	}
}