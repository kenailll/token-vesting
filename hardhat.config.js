require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');

require('solidity-coverage');
require("hardhat-gas-reporter");
require("hardhat-tracer");
require('hardhat-log-remover');
/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  solidity: {
    compilers: [
      { version: '0.8.2',
        settings: { 
          optimizer: {
            enabled: true,
            runs: 200
          },
        }
      },
      { version: '0.6.12',
        settings: { 
          optimizer: {
            enabled: true,
            runs: 200
          },
        }
      },
    ],
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
      accounts:{
        count: 400
      }
    },
    bsctest: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      accounts: [
        "0x2da6afd74db6887bcbf79735c0d77e20901f444607a9b51a6b58e315eb9a356c",
      ],
      allowUnlimitedContractSize: true
    },
  },
  gasReporter: {
    enabled: true,
    currency: 'BNB',
    gasPrice: 5
  }
};

