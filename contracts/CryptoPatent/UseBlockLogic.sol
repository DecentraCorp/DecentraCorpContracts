pragma solidity ^0.5.0;
import './RepBlockLogic.sol';

contract UseBlockLogic is RepBlockLogic {

  ///@notice generateGlobalUseBlock is an internal function called when the cryptopatent blockchain has determined
  ///        that a replication has mined a global use block.
  function generateGlobalUseBlock(address _rep) internal {
  ReplicationInfo memory infoR = repInfo[_rep];

    address repOwnerAddress = infoR.OwnersAddress;
  //sets repOwnerAddress as a specific replications owner from a rep struct
    address inventor = infoR.InventorsAddress;
  //sets inventor as a specific idea owner from a rep struct
    uint ideaID = infoR.IdeaID;
  //sets ideaID as a specific replications ideaID from a rep struct
    uint royalty = infoR.Royalty;
  //sets royalty as a specific replications royalty from a rep struct
    uint BlockReward =  infoR.BlockReward;
  //sets BlockReward as the block reward for a specific idea
    globalUseBlock++;
    DCPoA.proxyNTCMint(repOwnerAddress, BlockReward);
  //mints the replication Owner his block reward
    DCPoA.proxyNTCMint(inventor, royalty);
  //mints royalties to the idea inventor
    emit GlobalUseBlock(_rep, ideaID);
  }

  ///@notice UseBlockWeight is an internal function that tracks loacal use weightTracker
  ///@dev this is called by generateUseBlockWeight
  function generateUseBlockWeight() public {
    require(replications[msg.sender]);
    address _rep = msg.sender;

    ReplicationInfo memory infoR = repInfo[_rep];

    uint ideaID = infoR.IdeaID;
  //sets ideaID as a specific ideaID from the replications struct
    IdeaBlock memory info = ideaVariables[ideaID];

    uint weight = localWeightTracker[_rep];
  // sets weight equal to the current weight of a specific replication
    uint newWeight = weight + 1;
  // increases the weight of a specific replication
    uint globalWeight = weightTracker[ideaID];

    require(now >= localMiningtimeTracker[_rep] +  info.miningTime);
  //this require fails if the rep is calling to frequently
    localWeightTracker[_rep] = newWeight;
  //sets the newWeight for that specific replication
    if(newWeight > globalWeight) {
  //checks if the replication has the heaviest weight
    generateGlobalUseBlock(_rep);
  //if it does it generates a global use block
      localMiningtimeTracker[_rep] = now;
  //resets the global mining time for a specific idea after a useBlock is mined
     weightTracker[ideaID] = newWeight;
  }else {
      localMiningtimeTracker[_rep] = now;
      emit LocalUseWeight(_rep, newWeight);
    }
  }


}
