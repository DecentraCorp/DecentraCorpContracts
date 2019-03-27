
var Depot = artifacts.require("./DC_Depot/DC_Depot.sol");
var DCPoA = artifacts.require("./DecentraCorp/DecentraCorpPoA.sol");
var Notio = artifacts.require("./CryptoPatent/Notio.sol");
var PoPT = artifacts.require("./DC_Depot/ProofOfPurchaseToken.sol");




module.exports = (deployer) => {
  deployer.deploy(Depot, PoPT.address, Notio.address, DCPoA.address)
};
