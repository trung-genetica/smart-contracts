// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

// Interface for the Life Point ERC-20 token
interface ERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Membership {
    // Variables
    address public owner;  // Contract owner
    ERC20 public lifePointToken;  // Address of the Life Point ERC-20 token contract
    uint256 public membershipFee = 18000 * 10**18;  // Membership fee in Life Point tokens (18 decimals)

    mapping(address => bool) public isMember;  // Track who has purchased membership
    mapping(uint256 => bool) public orderProcessed;  // Track processed orderIds

    event MembershipPurchased(address indexed user, uint256 amount, uint256 indexed orderId);
    
    // Constructor to initialize contract owner and Life Point token address
    constructor(address _lifePointToken) {
        owner = msg.sender;
        lifePointToken = ERC20(_lifePointToken);
    }

    // Modifier to allow only the contract owner to execute certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this");
        _;
    }

    // Function to purchase a membership with an orderId from the backend
    function purchaseMembership(uint256 orderId) external {
        require(!isMember[msg.sender], "Already a member");
        require(!orderProcessed[orderId], "Order already processed");
        
        // Check if the user has enough Life Point tokens
        uint256 userBalance = lifePointToken.balanceOf(msg.sender);
        require(userBalance >= membershipFee, "Not enough Life Point tokens");
        
        // Transfer Life Point tokens from the user to the contract
        bool success = lifePointToken.transferFrom(msg.sender, address(this), membershipFee);
        require(success, "Token transfer failed");
        
        // Mark the user as a member and the orderId as processed
        isMember[msg.sender] = true;
        orderProcessed[orderId] = true;
        
        // Emit event with the orderId
        emit MembershipPurchased(msg.sender, membershipFee, orderId);
    }

    // Function to withdraw Life Point tokens from the contract (only owner)
    function withdrawTokens(uint256 amount) external onlyOwner {
        bool success = lifePointToken.transferFrom(address(this), owner, amount);
        require(success, "Token withdrawal failed");
    }
}
