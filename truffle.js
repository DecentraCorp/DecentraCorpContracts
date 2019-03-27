
 require("babel-register")({
   ignore: /node_modules\/(?!zeppelin-solidity)/
 });
 require("babel-polyfill");
 var HDWalletProvider = require("truffle-hdwallet-provider");

 var infura_apikey = "lHjU6q5aNKEfjBA0FQJr";
 var mnemonic = "category claim bright modify pond mass pet coffee orbit series harsh wish";
//test wallet mnemonic
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
      version: '^0.4.24',
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
