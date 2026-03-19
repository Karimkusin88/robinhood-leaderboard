require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with:", deployer.address);
  const Contract = await ethers.getContractFactory("RobinhoodLeaderboard");
  const contract = await Contract.deploy();
  await contract.waitForDeployment();
  const addr = await contract.getAddress();
  console.log("✅ RobinhoodLeaderboard deployed:", addr);
  console.log("Explorer:", `https://explorer.testnet.chain.robinhood.com/address/${addr}`);
}

main().catch((e) => { console.error(e); process.exitCode = 1; });
