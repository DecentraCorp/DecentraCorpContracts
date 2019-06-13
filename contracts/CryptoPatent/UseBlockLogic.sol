pragma solidity ^0.5.0;
import './RepBlockLogic.sol';

contract UseBlockLogic is RepBlockLogic {
  ///@notice generateGlobalUseBlock is an internal function called when the cryptopatent blockchain has determined
  ///        that a replication has mined a global use block.
  function generateGlobalUseBlock(address _rep) internal {
  ReplicationInfo memory infoR = repInfo[_rep];
  //pulls a specific replications information in to be used as the variable infoR
  // sets poolModedBlockReward equal to the block reward for a specific replications
  // and multiplies it by how many replications a member owns. this is the pool mining bonus
    globalUseBlock++;
  //increases the Global UseBlock count
    DCPoA.proxyNTCMint(infoR.OwnersAddress, infoR.BlockReward);
  //mints the replication Owner his modded block reward
    DCPoA.proxyNTCMint(infoR.InventorsAddress, infoR.Royalty);
  //mints royalties to the idea inventor
    emit GlobalUseBlock(_rep, infoR.OwnersAddress, infoR.IdeaID);
  }

  ///@notice UseBlockWeight is an internal function that tracks loacal use weightTracker
  ///@dev this is called by generateUseBlockWeight
  function generateUseBlockWeight(string memory _DLhash) public {
  //requires the msg.sender's address is an activated replication
    require(replications[msg.sender]);
    address _rep = msg.sender;
  //pulls the specific replications replication block into memory
    ReplicationInfo memory infoR = repInfo[_rep];
  //requires that the DeviceLock IPFS hash sent from the MineUseBlock function of the EPMS matches
  //the one stored in the devices Replication Block...
  //this encodes both strings as == doesnt work with strings in solidity directly
    require(keccak256(abi.encodePacked((_DLhash))) == keccak256(abi.encodePacked((infoR.DeviceLockHash))));
  //pulls a specific replications information in to be used as the variable infoR
    uint ideaID = infoR.IdeaID;
  //sets ideaID as a specific ideaID from the replications struct
    IdeaBlock memory info = ideaVariables[ideaID];
  //pulls a specific idea struct int to be used as the variable info
    uint newWeight = localWeightTracker[_rep] + 1;
  // increases the weight of a specific replication
    require(now >= localMiningtimeTracker[_rep] +  info.miningTime);
  //requires the time the function is called to be later than the combined total of its last call
  //and the specific ideas mining time resraint
  //this require fails if the rep is calling to frequently
    if(newWeight > weightTracker[ideaID]) {
  //checks if the replication has the heaviest weight
    generateGlobalUseBlock(_rep);
  //if it does it generates a global use block
     localMiningtimeTracker[_rep] = now;
  //resets the global mining time for a specific idea after a useBlock is mined
     weightTracker[ideaID] = newWeight;
  //sets the global block height to the weight of the mining replication
     localWeightTracker[_rep] = 0;
  //resets the local weight tracker for the mining replication
  } else {
    //if the replications weight is not heavy enough to mine a new block
      localMiningtimeTracker[_rep] = now;
    //set its local mining time tracker to the current time so it cant abuse the mining function
      localWeightTracker[_rep] = newWeight;
    //setts the local weight tracker for the rep to its new weight
      emit LocalUseWeight(_rep, infoR.OwnersAddress, newWeight);
    //emit event signaling that a replication mined a local weight without a global Useblock
    }
  }

}
