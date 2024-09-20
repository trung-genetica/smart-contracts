// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CustomToken is ERC20, Ownable {
    constructor() ERC20("LifePoint", "LP") {
        _mint(msg.sender, 100000000 * 10 ** decimals()); // 100,000,000
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}