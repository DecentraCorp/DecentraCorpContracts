

 module.exports = {
   networks: {
    DCPoA: {
       host: "localhost",
       port: 8545,
       network_id: '*', // Match any network id
     },
   ropsten: {
     provider: function(){
       return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"+ infura_apikey)
     },

     network_id: 3
   },
   compilers: {
    solc: {
      version: '0.5.0',
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  }
 }
};
