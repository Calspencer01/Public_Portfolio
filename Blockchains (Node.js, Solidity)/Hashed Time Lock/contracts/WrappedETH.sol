// SPDX-License-Identifier: MIT
// Important: I'm relying on overflow control from Solidity 0.8+
pragma solidity >=0.8 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract WrappedETH is Ownable, ReentrancyGuard, ERC20 {
    constructor() ERC20("Wrapped ETH", "WETH") {
    }

    function deposit() external payable nonReentrant {
        _mint(msg.sender, msg.value);
    }

    function withdraw() external nonReentrant {
        uint256 balance = balanceOf(msg.sender);

        _burn(msg.sender, balance);

        payable(msg.sender).transfer(balance);
    }
}