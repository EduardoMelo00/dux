
require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-ethers');
require('@nomiclabs/hardhat-etherscan');
require('@openzeppelin/hardhat-upgrades');

const dotenv = require('dotenv');
dotenv.config();
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task('accounts', 'Prints the list of accounts', async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000
      }
    }
  },
  networks: {
    localhost: {
      url: 'http://127.0.0.1:8545',
    },
    hardhat: {
      forking: {
        url: process.env.FORKING_ENDPOINT,
      }
    },
    rinkeby: {
      url:
        process.env.RINKEBY_ENDPOINT,
      accounts: [process.env.DEPLOY_ACCOUNT_PRIVATE_KEY],
      gasPrice: 80000000000,
      blockGasLimit: 22450000,
    }
  },

  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY,
  },
};