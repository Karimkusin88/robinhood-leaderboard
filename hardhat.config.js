require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.24",
  networks: {
    robinhood: {
      url: process.env.RPC_URL || "https://rpc.testnet.chain.robinhood.com",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 46630,
    },
  },
};
