var DCPoA = artifacts.require("./DecentraCorp/DecentraCorpPoA.sol");
var Notio = artifacts.require("./CryptoPatent/Notio.sol");
var BlockGen = artifacts.require("./CryptoPatent/CryptoPatentBlockGenerator.sol");
var PoPT = artifacts.require("./DC_Depot/ProofOfPurchaseToken.sol");
var ChaosCoin = artifacts.require("./ChaosCasino/ChaosCoin.sol");



module.exports = (deployer) => {
  deployer.deploy(DCPoA, Notio.address, BlockGen.address, ChaosCoin.address, PoPT.address)
};
