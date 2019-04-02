var Notio = artifacts.require("./CryptoPatent/Notio.sol");
var DCPoA = artifacts.require("./DecentraCorp/DecentraCorpPoA.sol");
var IdeaBlockGen = artifacts.require("./CryptoPatent/IdeaBlockGenerator.sol");
var RepBlockGen = artifacts.require("./CryptoPatent/ReplicationBlockGenerator.sol");
var UseBlockGen = artifacts.require("./CryptoPatent/GlobalUseBlockGenerator.sol");
var CryptoPatent = artifacts.require("./CryptoPatent/CryptoPatentBlockchain.sol");
var ChaosCoin = artifacts.require("./ChaosCasino/ChaosCoin.sol");
var ChaosCasino = artifacts.require("./ChaosCasino/ChaosCasino.sol");
var PoPT = artifacts.require("./DC_Depot/ProofOfPurchaseToken.sol");
var Depot = artifacts.require("./DC_Depot/DC_Depot.sol");
var BlockGen = artifacts.require("./CryptoPatent/CryptoPatentBlockchain.sol");



module.exports = (deployer) => {
  var  b, cp;
 deployer.then(function(){
   return CryptoPatent.deployed();
  }).then(function() {
    return BlockGen.deployed();
  }).then(function(instance) {
    b = instance;
    return b.transferOwnership(DCPoA.address);
  }).then(function() {
    return Notio.deployed();
  }).then(function(instance) {
    b = instance;
    return b.transferOwnership(DCPoA.address);
  }).then(function() {
    return DCPoA.deployed();
  }).then(function(instance) {
    b = instance;
    return b.addApprovedContract(CryptoPatent.address);
  }).then(function(){
    return ChaosCoin.deployed();
  }).then(function(instance) {
    b = instance;
    return b.transferOwnership(DCPoA.address);
  }).then(function(){
    return PoPT.deployed();
  }).then(function(instance) {
    b = instance;
    return b.transferOwnership(DCPoA.address);
  }).then(function() {
    return DCPoA.deployed();
  }).then(function(instance) {
    b = instance;
    return b.addApprovedContract(Depot.address);
  }).then(function() {
    return DCPoA.deployed();
  }).then(function(instance) {
    b = instance;
    return b.addApprovedContract(ChaosCasino.address);
  })

};
