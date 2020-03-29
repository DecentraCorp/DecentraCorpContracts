const HDWalletProvider = require("@truffle/hdwallet-provider");
const infuraProjectId = "7b70a7de34834780be9d4eeec825b9d1";
const _mnemonic =
  "life extend whale clown walnut leopard nut purse frame dwarf ecology inherit";

module.exports = {
  networks: {
    development: {
      protocol: "http",
      host: "localhost",
      port: 7545,
      gas: 8000000,
      gasPrice: 23000000000,
      networkId: "*"
    },
    ropsten: {
      provider: () =>
        new HDWalletProvider(
          _mnemonic,
          "https://ropsten.infura.io/v3/" + infuraProjectId
        ),
      gas: 8000000,
      gasPrice: 23000000000,
      networkId: 3
    },
    rinkeby: {
      provider: () =>
        new HDWalletProvider(
          _mnemonic,
          "https://rinkeby.infura.io/v3/" + infuraProjectId
        ),
      gas: 8000000,
      gasPrice: 23000000000
    }
  },
  compilers: {
    solc: {
      version: "0.5.0",
      settings: {
        optimizer: {
          enabled: true,
          runs: 300
        }
      }
    }
  }
};
