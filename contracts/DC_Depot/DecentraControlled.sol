pragma solidity ^0.5.0;
import "zos-lib/contracts/Initializable.sol";
import "openzeppelin-eth/contracts/ownership/Ownable.sol";
/////////////////////////////////////////////////////////////////////////////////////////////
contract DecentraCorpPoA {
  function proxyNTCMint(address _add, uint _amount) external;
  function proxyNTCBurn(address _add, uint _amount) external;
  function getLevel(address _add) public view returns(uint);
  function balanceOf(address _addr) public view returns (uint);
}
/// DecentraCorp PoA inteface

contract DecentraControlled is Initializable, Ownable {


  DecentraCorpPoA public DCPoA;


  uint public globalItemCount;
  uint public etherEarned;
  uint public globalEscrowCount;
  uint public _NTC_PriceMod;
  uint public _DecentraCorpFee;

  string public forSale;
  string public needsProcessing;

  address[] public processors;
  mapping(address => bool) approvedProcessingFacility;
  mapping(string => uint) IPFStoID;
  mapping(address => uint) PoPTokens;


event ItemForSale( string itemHash);
event ItemInEscrow(uint escrowNumber, address ProcessingFaility, string IPFS);
event NewProcessingFacility(address newFacility);
event UpdatedIPFS(uint _itemInfoById, string _newIPFSHash);

function initialize() public initializer {
  Ownable.initialize(msg.sender);
  _NTC_PriceMod = 10;
  _DecentraCorpFee = 0.001 ether;
}



/*
@notice mintItemToken allows an external contract (the Forra contract) to mint tokens
@dev this function utilizes other functions found in open-zepplin's ERC721 library
@dev this contract is designed to be "owned" by the Forra contract
@param _itemIPFSHash is a hash generated from an item's info being uploaded to IPFS
@param _itemid is always set to the newly incremented globalItemCount
@param IPFStoID is used to allow a backwards itemId look up from an items associated IPFS hash
*/
  function _mintItemToken( string memory _itemIPFSHash) internal {
  globalItemCount++;
  uint _itemId = globalItemCount;
  IPFStoID[_itemIPFSHash] = _itemId;
  }
/*


/*
@notice ipfsLookUp is designed to facilitate a look-up of an itemsId number from its associated
IPFS Hash
@dev this function is set to view and therefore requires no gas to call
@param  _ipfsHash is meant to be the hash of the item being looked up
@return returns the items id number
*/
 function ipfsLookUp(string memory _ipfsHash) public view returns(uint) {
  uint itemId = IPFStoID[_ipfsHash];
  return itemId;
  }


  function getDCDEtherBalance() public view returns(uint) {
    return address(this).balance;
  }


  function DCTokenHF(address _newDCAdd) public onlyOwner {
    DCPoA = DecentraCorpPoA(_newDCAdd);
  }



  function sellItem(string memory _ipfsHash) public {
    forSale =_ipfsHash;
    emit ItemForSale( _ipfsHash);
  }

  function getForSale()public view returns(string memory) {
    return forSale;
  }

  function getProcessingList()public view returns(string memory) {
    return needsProcessing;
  }

  function applyForProcessingFacility() public {
    require(DCPoA.getLevel(msg.sender) >= 100);
    processors.push(msg.sender);
    approvedProcessingFacility[msg.sender] = true;
    emit NewProcessingFacility(msg.sender);
  }

function CheckIfApproved(address _add) public view returns(bool) {
  return approvedProcessingFacility[_add];
}

}
