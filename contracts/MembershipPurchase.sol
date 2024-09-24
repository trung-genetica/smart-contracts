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
    
    uint256 public oneYearFee = 18000 * 10**18;  // 1-year membership fee in Life Point tokens (18 decimals)
    uint256 public threeYearFee = 45000 * 10**18;  // 3-year membership fee in Life Point tokens (18 decimals)

    enum MembershipDuration { ONE_YEAR, THREE_YEARS }

    struct Member {
        bool isMember;
        uint256 expiration;
    }

    mapping(address => Member) public members;  // Track membership status and expiration
    mapping(uint256 => bool) public orderProcessed;  // Track processed orderIds

    event MembershipPurchased(address indexed user, uint256 amount, uint256 indexed orderId, uint8 duration);
    
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

    // Function to purchase a membership, specifying the orderId and duration (1 or 3 years)
    function purchaseMembership(uint256 orderId, MembershipDuration duration) external {
        require(!members[msg.sender].isMember, "Already a member");
        require(!orderProcessed[orderId], "Order already processed");

        uint256 membershipFee = getMembershipFee(duration);
        
        // Check if the user has enough Life Point tokens
        uint256 userBalance = lifePointToken.balanceOf(msg.sender);
        require(userBalance >= membershipFee, "Not enough Life Point tokens");
        
        // Transfer Life Point tokens from the user to the contract
        bool success = lifePointToken.transferFrom(msg.sender, address(this), membershipFee);
        require(success, "Token transfer failed");

        // Mark the user as a member and update their expiration time
        members[msg.sender] = Member({
            isMember: true,
            expiration: block.timestamp + getMembershipDuration(duration)
        });

        // Mark the orderId as processed
        orderProcessed[orderId] = true;
        
        // Emit event with the orderId and membership duration
        emit MembershipPurchased(msg.sender, membershipFee, orderId, uint8(duration));
    }

    // Function to withdraw Life Point tokens from the contract (only owner)
    function withdrawTokens(uint256 amount) external onlyOwner {
        bool success = lifePointToken.transferFrom(address(this), owner, amount);
        require(success, "Token withdrawal failed");
    }

    // Helper function to get the membership fee based on duration (1 or 3 years)
    function getMembershipFee(MembershipDuration duration) internal view returns (uint256) {
        if (duration == MembershipDuration.ONE_YEAR) {
            return oneYearFee;
        } else {
            return threeYearFee;
        }
    }

    // Helper function to get the membership duration in seconds (1 year = 365 days, 3 years = 1095 days)
    function getMembershipDuration(MembershipDuration duration) internal pure returns (uint256) {
        if (duration == MembershipDuration.ONE_YEAR) {
            return 365 days;
        } else {
            return 1095 days;
        }
    }

    // Check if a member's membership is still valid
    function isMembershipActive(address member) external view returns (bool) {
        return members[member].isMember && block.timestamp < members[member].expiration;
    }
}
