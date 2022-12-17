// SPDX-License-Identifier: MIT
// Important: I'm relying on overflow control from Solidity 0.8+
pragma solidity >=0.8 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CoinA is ERC20 {
    constructor(address _mintee) ERC20("CoinA", "TTK") {
        _mint(_mintee, 10000);
    }
}