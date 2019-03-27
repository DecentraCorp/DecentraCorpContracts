var BlockGen = artifacts.require("./CryptoPatent/CryptoPatentBlockGenerator.sol");



module.exports = (deployer) => {
 deployer.deploy(BlockGen)
};
