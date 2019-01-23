pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import 'zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';
////////////////////////////////////////////////////////////////////////////////////////////
/// @title CryptoPatentBlockGenerator Contract
/// @author DecentraCorp
/// @notice this contract is built from the zeppelin-solidity library
/// @dev All function calls are currently implement without side effects
////////////////////////////////////////////////////////////////////////////////////////////

/// @author Christopher Dixon
/// @dev this contract contains both the Ownable and ERC721Token contracts from Open Zepplin
contract CryptoPatentBlockGenerator is Ownable, ERC721Token("CryptoPatentBlock", "CPB") {
///@param globalIdeaCount tracks how many Idea Blocks exist
///@param stakeAmountInIDC is the amount of ideacoin  that must be staked to activate a replication
///@param ideaVariables maps a specific ideas info struct to its ideaId number
  uint public globalIdeaCount = 0;
  uint public stakeAmountInIDC = 100;
  uint public globalRepCount = 0;
  uint public globalUseBlocknumber = 0;

  mapping (uint256 => IdeaInfo) public ideaVariables;
  mapping(address => mapping(uint => uint)) public replicationTracker;
  //maps a replicators address to the ideas id to store a unique replication
  //ID for that replication
  mapping (address => bool) replications;
  //tracks if an address is a replication
  mapping (address => ReplicationInfo) repInfo;
  //mapping of replication info by replication address
  mapping (address => mapping (uint => uint)) repOwnes;
  //tracks which address owns a specific replication by its ideaID
  mapping (uint => uint) ideaRepCounter;
  //tracks the total number of replications for a specific idea
  mapping(address => uint) public globalUseBlockTracker;


///@struct IdeaInfo is built to store only needed variables to the blockchain, IPFS handles the rest
struct IdeaInfo {
  uint globalUseBlockAmount;
  uint royalty;
  uint miningTime;
  address inventorAddress;
}

struct ReplicationInfo {
  uint BlockReward;
  address OwnersAddress;
  uint IdeaID;
  uint Royalty;
  uint RepID;
  uint MiningTime;
  address InventorsAddress;
  address ReplicationAddress;
}
// ReplicationInfo stores replication information

event NewRep(address _newRep);

///@notice _generateIdeaBlock generates a Proof of Idea Ownership token. PoIO tokens act like patents
  function _generateIdeaBlock(
  string _ideaIPFS,
  uint _globalUseBlockAmount,
  uint _miningTime,
  uint _royalty,
  address _inventorsAddress
  )
   external
  onlyOwner
  {
    globalIdeaCount++;
  uint _ideaId = globalIdeaCount;
  _mint(_inventorsAddress , _ideaId);

  _setTokenURI(_ideaId, _ideaIPFS);

  setIdeaInfo(
     _globalUseBlockAmount,
     _royalty,
     _miningTime,
     _inventorsAddress
    );

  }

///@notice setIdeaInfo handles the struct creation logic for ideablocks
function setIdeaInfo(
  uint _globalUseBlockAmount,
  uint _royalty,
  uint _miningTime,
  address _inventorAddress
  )
  internal
  {

    IdeaInfo memory _info = IdeaInfo({
      globalUseBlockAmount: uint(_globalUseBlockAmount),
      royalty: uint(_royalty),
      miningTime: uint(_miningTime),
      inventorAddress: address(_inventorAddress)
      });

      uint _ideaId = globalIdeaCount;
      ideaVariables[_ideaId] = _info;
  }

  function _generateReplicationBlock(uint _ideaId, address _replicatorAdd) internal  {
    globalRepCount++;
  uint _replicationId = globalRepCount;
  _mint(_replicatorAdd, _replicationId);
  replicationTracker[_replicatorAdd][_ideaId] =_replicationId;

  }

  function _replicationBlock(uint _ideaId, address _repAdd, address _replicatorAdd) external onlyOwner {
    uint RepBlockReward = getGlobalUseBlockAmount(_ideaId);
    //sets RepBlockReward as the specific rep block amount Stored for an idea
    uint royalty = getRoyalty(_ideaId);
    //sets royalty as the specific royalty amount for an idea
    uint blockReward = RepBlockReward - royalty;
    //subtracts the royalty amount from the block reward
    uint _ideaMiningTime = getIdeaMiningTime(_ideaId);
    uint _repMiningTime = now + _ideaMiningTime;
    address inventor = getInventor(_ideaId);
    //sets inventor as the specific inventor for an idea

    _generateReplicationBlock(_ideaId, _replicatorAdd);
    //generates an ERC721 replication block token

    uint _repId = globalRepCount;
    //sets _repNumber equal to globalRepCount

    ReplicationInfo memory _info = ReplicationInfo({
      BlockReward: uint( blockReward),
      OwnersAddress: address(_replicatorAdd),
      IdeaID: uint(_ideaId),
      Royalty: uint(royalty),
      RepID: uint(_repId),
      MiningTime: uint(_repMiningTime),
      InventorsAddress: address(inventor),
      ReplicationAddress: address(_repAdd)
      });
  //creates replication struct for new rep

      repInfo[_repAdd] = _info;
      //stores new struct stored at the replications address
      uint ideaRepCount = ideaRepCounter[_ideaId];
      ideaRepCounter[_ideaId] = ideaRepCount++;
      //increments the global rep count for a specific idea
    replications[_repAdd] = true;
  //stores replications address as a replicator
    uint ownerRepCount = repOwnes[_replicatorAdd][_ideaId];
  //sets ownerRepCount to how many replications of a specific idea a replicator owns
    repOwnes[_replicatorAdd][_ideaId] = ownerRepCount++;
  //increments the amount of replications for an idea a replicator owns
  emit NewRep(_replicatorAdd);
  }

  ///@notice _generateGUSBlock is only called by the CryptoPatent Blockchain when certain criterea is met
  ///@dev the GUB token is minted to the replication owner
    function _generateGUSBlock(address _replicationOwner) external onlyOwner {
      globalUseBlocknumber++;
      uint _blockId = globalUseBlocknumber;
    _mint(_replicationOwner, _blockId);
    globalUseBlockTracker[_replicationOwner] = _blockId;
    }




///@notice the following functions allow for easier access to info by both the front end and other contracts
///@dev all the following contracts allow for the retreval of token block information
  function getGlobalUseBlockAmount(uint _ideaId) public view returns(uint) {
    IdeaInfo memory info = ideaVariables[_ideaId];
    uint globalUseBlockAmount = info.globalUseBlockAmount;
    return globalUseBlockAmount;
  }


    function getRoyalty(uint _ideaId) public view returns(uint) {
      IdeaInfo memory info = ideaVariables[_ideaId];
      uint royalty = info.royalty;
      return royalty;
    }

    function getInventor(uint _ideaId) public view returns(address) {
      IdeaInfo memory info = ideaVariables[_ideaId];
      address inventorAdd = info.inventorAddress;
      return inventorAdd;
    }
    function getIdeaMiningTime(uint _ideaId) public view returns(uint) {
      IdeaInfo memory info = ideaVariables[_ideaId];
      uint _miningTime = info.miningTime;
      return _miningTime;
    }
    function setMiningTime(uint _ideaId) external view {
      IdeaInfo memory info = ideaVariables[_ideaId];
       info.miningTime = now;
    }

    function getBlockReward(address _repAdd) public view returns(uint) {
      ReplicationInfo memory info = repInfo[_repAdd];
      uint blockReward = info.BlockReward;
      return blockReward;
    }


    function getOwnersAddress(address _repAdd) public view returns(address) {
      ReplicationInfo memory info = repInfo[_repAdd];
      address repOwner = info.OwnersAddress;
      return repOwner;
    }

    function getIdeaID(address _repAdd) public view returns(uint) {
      ReplicationInfo memory info = repInfo[_repAdd];
      uint ideaId = info.IdeaID;
      return ideaId;
    }

    function getInventorsAddress(address _repAdd) public view returns(address) {
      ReplicationInfo memory info = repInfo[_repAdd];
      address InvtAdd = info.InventorsAddress;
      return InvtAdd;
    }

    function getReplicationAddress(address _repAdd) public view returns(address) {
      ReplicationInfo memory info = repInfo[_repAdd];
      address repAdd = info.ReplicationAddress;
      return repAdd;
    }

    function getRoyalty(address _repAdd) public view returns(uint) {
      ReplicationInfo memory info = repInfo[_repAdd];
      uint royalty = info.Royalty;
      return royalty;
    }

    function getRepID(address _repAdd) public view returns(uint) {
      ReplicationInfo memory info = repInfo[_repAdd];
      uint repId = info.RepID;
      return repId;
    }

    function checkIfRep(address _add) external view returns(bool) {
    return replications[_add];
    }

    function getNumOfReps(address _add, uint _ideaId) external view returns(uint) {
    return repOwnes[_add][_ideaId];
    }

    function getRepTotal(uint _ideaId) external view returns(uint) {
    return ideaRepCounter[_ideaId];
    }

    function getRepMiningTime(address _repAdd) external view returns(uint) {
    ReplicationInfo memory info = repInfo[_repAdd];
    uint miningTime = info.MiningTime;
    return miningTime;
    }

    function setRepMiningTime(address _repAdd) external onlyOwner {
      ReplicationInfo memory info = repInfo[_repAdd];
      uint _ideaId = getIdeaID(_repAdd);
      uint _ideaMiningTime = getIdeaMiningTime(_ideaId);
      info.MiningTime = now + _ideaMiningTime;

    }

    function getID(address _ideaAdd) public view returns(uint){
      return getIdeaID(_ideaAdd);
    }
}
