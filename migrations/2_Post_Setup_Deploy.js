
var DCPoA = artifacts.require("./DecentraCorp/DecentraCorpPoA.sol");
var CryptoPatent = artifacts.require("./CryptoPatent/CryptoPatentBlockchain.sol");
var ChaosCasino = artifacts.require("./ChaosCasino/ChaosCasino.sol");
var Depot = artifacts.require("./DC_Depot/DC_Depot.sol");



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
    return NotiCoin.deployed();
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
