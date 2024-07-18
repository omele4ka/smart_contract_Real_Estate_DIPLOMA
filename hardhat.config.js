require("@nomicfoundation/hardhat-toolbox");

const { alchemyApiKey, privateKey } = require('./secrets.json');

module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${alchemyApiKey}`,
      accounts: [`0x${privateKey}`]
    }
  }
};