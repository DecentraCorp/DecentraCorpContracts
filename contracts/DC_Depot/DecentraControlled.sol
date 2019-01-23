pragma solidity ^0.4.21;


import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

/////////////////////////////////////////////////////////////////////////////////////////////
contract DecentraCorpPoA {
  function proxyIDCMint(address _add, uint _amount) external;
  function proxyIDCBurn(address _add, uint _amount) external;
  function mintItemToken( string _itemIPFSHash) external;
  function getRank(address _add) public view returns(uint);
  function getLevel(address _add) public view returns(uint);
}
/// DecentraCorp PoA inteface
////////////////////////////////////////////////////////////////////////////////////////////
contract IdeaCoin {
    function balanceOf(address _addr) public constant returns (uint);

}
/// IdeaCoin interface
/////////////////////////////////////////////////////////////////////////////////////////////
contract ProofOfPurchaseToken{
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function balanceOf(address _owner) public view returns (uint256);
    function updatePOPTokenIPFS(uint _itemId, string _newIPFSHash) public;
    function ipfsLookUp(string _ipfsHash) public view returns(uint);
}
/////////////////////////////////////////////////////////////////////////////////////////////

contract DecentraControlled is Ownable {



  DecentraCorpPoA public decentraCorp;
  ProofOfPurchaseToken public PoPT;
  IdeaCoin public IDC;
  uint public etherEarned = 0;
  uint public globalEscrowCount = 0;
  uint public _IDC_PriceMod = 10;
  uint public _DecentraCorpFee = 0.001 ether;

  string public forSale;
  string public needsProcessing;

  address[] public processors;
  mapping(address => bool) approvedProcessingFacility;



event ItemForSale( string itemHash);
event ItemInEscrow(uint escrowNumber, address ProcessingFaility, string IPFS);
event NewProcessingFacility(address newFacility);

    function getDCDEtherBalance() public view returns(uint) {
        return address(this).balance;
    }

    function getDCDPoPBalance() public view returns(uint) {
        return PoPT.balanceOf(this);
    }


    function updateItemPOPTokenIPFS(uint _itemId, string _newIPFSHash) public onlyOwner {
        PoPT.updatePOPTokenIPFS(_itemId, _newIPFSHash);
        }

    function PoPTokenHF(address _newPoPAdd) public onlyOwner {
        PoPT = ProofOfPurchaseToken(_newPoPAdd);
        }

  function sellItem(string _ipfsHash) public {
    forSale =_ipfsHash;
    emit ItemForSale( _ipfsHash);
  }

  function getForSale()public view returns(string) {
    return forSale;
  }

  function getProcessingList()public view returns(string) {
    return needsProcessing;
  }

  function applyForProcessingFacility(address _facAdd) public {
    require(decentraCorp.getRank(_facAdd) >= 100);
    require(decentraCorp.getLevel(msg.sender) >= 100);
    processors.push(_facAdd);
    approvedProcessingFacility[_facAdd] = true;
    emit NewProcessingFacility(_facAdd);
  }

function CheckIfApproved(address _add) public view returns(bool) {
  return approvedProcessingFacility[_add];
}

}
