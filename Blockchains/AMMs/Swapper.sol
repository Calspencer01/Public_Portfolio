// SPDX-License-Identifier: MIT
// Important: I'm relying on overflow control from Solidity 0.8+
pragma solidity >=0.8 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "hardhat/console.sol";

contract Swapper is Ownable, ReentrancyGuard {
	uint256 constant FEE_PERCENT = 2;
	uint256 constant MAX_SLIPPAGE_PERCENT = 2;
	enum Direction { FirstToSecond, SecondToFirst }

	uint256 swapperId;

	ERC20 token1;
	uint256 liquidity1;
	uint256 liquidityRewards1;

	ERC20 token2;
	uint256 liquidity2;
	uint256 liquidityRewards2;

	uint256 k;
	
	uint256 nProviders = 0;
	uint256 totalShares = 0;

	// Once a provider has been added, it will always be remembered. Number of providers will only ever increase
	mapping (uint256 => address) providerAddress; // Pool ID => provider address
	mapping (address => uint256) shares;
	mapping (address => bool) providerExists;
 	

	///////////////////
	// Pool Creation //
	///////////////////

	constructor(ERC20 _token1, uint256 _value1, ERC20 _token2, uint256 _value2, uint256 _swapperId, address _sender) {
		// Store _sender as a new provider
		addProvider(_sender);

		// Need to specify it's a pointer to a storage item TODO
		// Update global variables
		swapperId = _swapperId;

		token1 = _token1;
		liquidity1 = _value1;
		liquidityRewards1 = 0;

		token2 = _token2;
		liquidity2 = _value2;
		liquidityRewards2 = 0;

		k = _value1 * _value2;
		
		shares[_sender] = 100;
		totalShares = shares[_sender];
	}

	////////////////////////// 
	// Conversion functions //
	//////////////////////////

	function convert(uint256 _amount, Direction _direction) internal view returns (uint256, uint256) {
		// Need to specify it's a pointer to a storage item
		if(_direction == Direction.FirstToSecond) {
			// uint storage x
			uint256 x = liquidity1 + _amount;
			uint256 y = k / x;
			uint256 leftover = k % x;

			if (leftover > 0) {
				y++;
				leftover = _amount - ((k / y) - liquidity1);
			}

			return (liquidity2 - y, leftover);
		}
		else {
			uint256 y = liquidity2 + _amount;
			uint256 x = k / y;

			uint256 leftover = k % y;

			if(leftover > 0) {
				x++;
				leftover = _amount - ((k / x) - liquidity2);
			}

			return (liquidity1 - x, leftover);
		}
	}

	function convert_paying_fees(uint256 _amount, Direction _direction) internal view returns (uint256, uint256, uint256) {
		uint256 originalConverted;
		uint256 leftover;

		(originalConverted, leftover) = convert(_amount, _direction);

		uint256 converted = (originalConverted * (100 - FEE_PERCENT)) / 100;

		uint256 fee = originalConverted - converted;

		return (converted, fee, leftover);
	}

	////////////////////////
	// Swapping functions //
	////////////////////////

	function swap(uint256 _amount, Direction _direction) external returns(uint256 amount, uint256 converted) {
		uint256 amount_;
		uint256 converted_;

		(amount_, converted_) = swap_slippage(_amount, _direction, 0);
		return(amount_, converted_);
	}

	function swap_slippage(uint256 _amount, Direction _direction, uint256 _minimumLiquidity) internal returns (uint256, uint256) {
		uint256 converted;
		uint256 fee;
		uint256 leftover;

		(converted, fee, leftover) = convert_paying_fees(_amount, _direction);
		
		require(converted >= _minimumLiquidity, "Slippage");

		if(_direction == Direction.FirstToSecond) {
			liquidity1 += (_amount - leftover);
			liquidity2 -= (converted + fee);

			liquidityRewards2 += fee;
		}
		else {
			liquidity2 += (_amount - leftover);
			liquidity1 -= (converted + fee);

			liquidityRewards1 += fee;
		}
		return(_amount - leftover, converted);
	}

	/////////////////////////
	// Liquidity Functions //
	/////////////////////////

	function addLiquidity(uint256 _amount, Direction _direction, address _sender) external nonReentrant returns (uint256, uint256){
		uint256 converted;
		uint256 newShare;

		// Require amount > 0

		// Add a new liquidity provider (if doesn't exist yet)
		addProvider(_sender);
	
		if(_direction == Direction.FirstToSecond) {
			// Convert amount to token2 liquidity
			converted = (_amount * liquidity2) / liquidity1;
			
			// Update Liquidities
			liquidity1 += _amount;
			liquidity2 += converted;
		}
		else {
			// Convert amount to token 1 liquidity
			converted = (_amount * liquidity1) / liquidity2;

			// Update liquidities
			liquidity2 += _amount;
			liquidity1 += converted;
		}
		// Calculate new fraction of totalShares
		newShare = (_amount * shares[_sender]) / totalShares;

		// Update k using new liquidities
		k = liquidity1 * liquidity2;

		// Update total shares (across all providers)
		totalShares += newShare;

		// Update shares of this provider
		shares[_sender] += newShare;

		return (_amount, converted);
	}


	function removeLiquidity(uint256 _amount, Direction _direction, address _sender) external nonReentrant  returns (uint256, uint256){
		uint256 converted;
		uint256 newShare;

		// Require amount > 0

		require(providerExists[_sender] == false, "Error - No record of this address");

		if(_direction == Direction.FirstToSecond) {
			// Convert amount to token2 liquidity
			converted = (_amount * liquidity2) / liquidity1;

			// Update liquidities
			liquidity1 -= _amount;
			liquidity2 -= converted;
		}
		else {
			// Convert amount to token1 liquidity
			converted = (_amount * liquidity1) / liquidity2;

			// Update liquidities
			liquidity2 -= _amount;
			liquidity1 -= converted;
		}
		// Calculate new fraction of totalShares
		newShare = (_amount * shares[_sender]) / totalShares;

		// Update k using new liquidities
		k = liquidity1 * liquidity2;

		// Update total shares (across all providers)
		totalShares -= newShare;

		// Update shares of this provider
		shares[_sender] -= newShare;

		return (_amount, converted);
	}

	function clearLiquidity(address _sender) external nonReentrant {
		require(providerExists[_sender] == false, "Error - No record of this address");

		// Get total share owned by provider
		uint256 providerAmount = (shares[_sender] * liquidity1) / totalShares;

		// Remove all liquidity
		this.removeLiquidity(providerAmount, Direction.FirstToSecond, _sender);
	}

	function providerRewards(uint256 _providerId) public returns (address, uint256, uint256){
		// Get address of provider
		address provider = providerAddress[_providerId];

		// Get number of shares owned by provider
		uint256 providerShares = shares[provider];
		
		// Calculate provider's rewards for each token
		uint256 providerRewards1 = (liquidityRewards1 * providerShares) / totalShares;
		uint256 providerRewards2 = (liquidityRewards2 * providerShares) / totalShares;

		// Store old reward values
		uint256 oldLiqRewards1 = liquidityRewards1;
		uint256 oldLiqRewards2 = liquidityRewards2;

		// Remove rewards for the provider
		liquidityRewards1 -= providerRewards1;
		liquidityRewards2 -= providerRewards2;
		
		// Ensure that the provider rewards removed from liquidityRewards is correct
		require(providerRewards1 + providerRewards2 <= (oldLiqRewards1 + oldLiqRewards2) - (liquidityRewards1 + liquidityRewards2), "Error - Invalid Liquidity Rewards");
		
		return(provider, providerRewards1, providerRewards2);
	}

	function addProvider(address _sender) internal returns (bool){
		// New provider
		if (providerExists[_sender] == false){
			// Increase the Pool's number of providers 
			nProviders++;

			// Store address of sender in map
			providerAddress[nProviders] = _sender;

			// Provider now exists in map
			providerExists[_sender] = true;
			return false;
		}
		// Existing provider
		else {
			return true;
		}
	}

	function get_nProviders() external view returns (uint256){
		return nProviders;
	}

	function get_token1() external view returns (ERC20){
		return token1;
	}
	function get_token2() external view returns (ERC20){
		return token2;
	}
	
}