pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import 'zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';
/*
@title Proof of Purchase token
@author Christopher Dixon
@notice This contract generates ERC721 Proof of Purchase tokens for use with the Forra.io marketplace platform
@dev Everything in this contract has been tested and is working as of 09/05/18
@param globalItemCount is used to track how many PoP tokens have been created
@param mapping allows for an easy token look up by IPFS hash
@param UpdatedIPFS describing the updating of a tokens IPFS Hash
*/
contract ProofOfPurchaseToken is ERC721Token("Proof Of Purchase Token", "PoPT"), Ownable {
  uint public globalItemCount = 0;

  mapping(string => uint) IPFStoID;

  event UpdatedIPFS(uint _itemInfoById, string _newIPFSHash);
/*
@notice mintItemToken allows an external contract (the Forra contract) to mint tokens
@dev this function utilizes other functions found in open-zepplin's ERC721 library
@dev this contract is designed to be "owned" by the Forra contract
@param _itemIPFSHash is a hash generated from an item's info being uploaded to IPFS
@param _itemid is always set to the newly incremented globalItemCount
@param IPFStoID is used to allow a backwards itemId look up from an items associated IPFS hash
*/
  function _mintItemToken( string _itemIPFSHash) external onlyOwner {
  globalItemCount++;
  uint _itemId = globalItemCount;
  _mint(msg.sender, _itemId);
  _setTokenURI(_itemId, _itemIPFSHash);
  IPFStoID[_itemIPFSHash] = _itemId;
  }
/*
@notice updatePOPTokenIPFS allows the dev team to update an items IPFS hash should its info ever need updating
@dev this function is set to onlyOwner as it has an associated function on the Dev-Controlled contract designed
to allow a dev to call it
@param _itemId is the existing tokens Id number
@param _newIPFSHash is the new IPFS hash
*/
 function updatePOPTokenIPFS(uint _itemId, string _newIPFSHash) public onlyOwner{
    _setTokenURI(_itemId, _newIPFSHash);
   emit UpdatedIPFS(_itemId, _newIPFSHash);
  }

/*
@notice ipfsLookUp is designed to facilitate a look-up of an itemsId number from its associated
IPFS Hash
@dev this function is set to view and therefore requires no gas to call
@param  _ipfsHash is meant to be the hash of the item being looked up
@return returns the items id number
*/
 function ipfsLookUp(string _ipfsHash) public view returns(uint) {
  uint itemId = IPFStoID[_ipfsHash];
  return itemId;
  }

}
