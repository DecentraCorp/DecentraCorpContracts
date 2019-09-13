pragma solidity ^0.5.0;
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import '@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol';
import "@openzeppelin/upgrades/contracts/Initializable.sol";


contract AccountAbstraction is Initializable, Ownable {

mapping(string => string) UserNameToHash;
mapping(string => bool) IsTaken;
mapping(string => address) addressBook;
mapping(address => string) nameFinder;
mapping(address => bool) exists;



function initialize() public initializer {
  Ownable.initialize(msg.sender);
}

function createAccount(string memory _userName, string memory _ipfsHash) public {
  require(IsTaken[_userName] != true);
  UserNameToHash[_userName] = _ipfsHash;
  IsTaken[_userName] = true;
  addressBook[_userName] = msg.sender;
  exists[msg.sender] = true;
  nameFinder[msg.sender] = _userName;
}

function retrieveAccount(string memory _userName) public view returns(string memory) {
  return UserNameToHash[_userName];
}

function checkAvailibility(string memory _userName) public view returns(bool) {
  return IsTaken[_userName];
}

function getAddress(string memory _userName) public view returns(address) {
  return addressBook[_userName];
}

function getName(address _add) public view returns(string memory){
  return nameFinder[_add];
}

function checkIfAccount(address _add) public view returns(bool) {
  return exists[_add];
}

}
