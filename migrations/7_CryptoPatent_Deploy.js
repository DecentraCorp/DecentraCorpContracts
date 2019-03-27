var Notio = artifacts.require("./CryptoPatent/Notio.sol");
var DCPoA = artifacts.require("./DecentraCorp/DecentraCorpPoA.sol");
var BlockGen = artifacts.require("./CryptoPatent/CryptoPatentBlockGenerator.sol");
var CryptoPatent = artifacts.require("./CryptoPatent/CryptoPatentBlockchain.sol");


module.exports = (deployer) => {
  deployer.deploy(CryptoPatent, DCPoA.address, Notio.address, BlockGen.address)
};
