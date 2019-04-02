
var ChaosCoin = artifacts.require("./ChaosCasino/ChaosCoin.sol");
var ChaosCasino = artifacts.require("./ChaosCasino/ChaosCasino.sol");
var DCPoA = artifacts.require("./DecentraCorp/DecentraCorpPoA.sol");
var RepBlockGen = artifacts.require("./CryptoPatent/CryptoPatentBlockchain.sol");



module.exports = (deployer) => {
  deployer.deploy(ChaosCasino, DCPoA.address,  RepBlockGen.address, ChaosCoin.address)
};
