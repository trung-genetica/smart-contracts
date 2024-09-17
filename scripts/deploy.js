const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    
    console.log("Deploying contracts with the account:", deployer.address);
    const balance = await deployer.provider.getBalance(deployer.address).toString();
    console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

    // Deploy LifePoint token
    const LifePoint = await ethers.getContractFactory("CustomToken");
    const lifePoint = await LifePoint.deploy();
    await lifePoint.deployed();
    console.log("LifePoint deployed to:", lifePoint.address);

    // Deploy TokenLock
    const TokenLock = await ethers.getContractFactory("TokenLock");
    const tokenLock = await TokenLock.deploy();
    await tokenLock.deployed();
    console.log("TokenLock deployed to:", tokenLock.address);

    // Initialize TokenLock contract
    const depositDeadline = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now
    const lockDuration = 3600 * 24 * 1; // 1 day
    const tx = await tokenLock.initialize(
        deployer.address, // Owner address
        lifePoint.address, // Token address
        depositDeadline,
        lockDuration,
        "Locked LifePoint",
        "LLP"
    );
    await tx.wait();
    console.log("TokenLock initialized.");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });