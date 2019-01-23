pragma solidity ^0.4.21;
import "./RBLogic.sol";
////////////////////////////////////////////////////////////////////////////////////////////
/// @title UseLogic Contract for the CryptoPatent Blockchain
/// @author DecentraCorp
/// @notice this contract is the fouth contract in the CryptoPatent Blockchain
/// @dev All function calls are currently implement without side effects
////////////////////////////////////////////////////////////////////////////////////////////
/// @author Christopher Dixon

contract UseLogic is RBLogic {

///@notice generateUseBlockWeight allows a replication block to generate a local use weight
///        and possibly a global use blocks
///@dev this function is the first in a chain of function and implements the onlyReplication modifier
///@dev generateUseBlockWeight is fired from this function are to be used by the EPMS to trigger internal timers set to info in the original idea's IPFS info
function generateUseBlockWeight() public onlyReplication {
  address _rep = msg.sender;
  UseBlockWeight(_rep);
  }

///@notice generateGlobalUseBlock is an internal function called when the cryptopatent blockchain has determined
///        that a replication has mined a global use block.
function generateGlobalUseBlock(address _rep) internal {
  address repOwnerAddress = CPBG.getOwnersAddress(_rep);
//sets repOwnerAddress as a specific replications owner from a rep struct
  address inventor = CPBG.getInventorsAddress(_rep);
//sets inventor as a specific idea owner from a rep struct
  uint ideaID = CPBG.getIdeaID(_rep);
//sets ideaID as a specific replications ideaID from a rep struct
  uint royalty = CPBG.getRoyalty(_rep);
//sets royalty as a specific replications royalty from a rep struct
  uint BlockReward = CPBG.getGlobalUseBlockAmount(ideaID);
//sets BlockReward as the block reward for a specific idea
  BlockReward = BlockReward - royalty;
//stes BlockReward equal to itself minus the royalty
  BlockReward = calculatePromo(BlockReward, ideaID);
//calculates BlockReward according to promotion status of a member
  globalUseBlock++;
//increments global use block counter
  DCPoA.generateGUSBlock(repOwnerAddress);
  DCPoA.proxyIDCMint(repOwnerAddress, BlockReward);
//mints the replication Owner his block reward
  DCPoA.proxyIDCMint(inventor, royalty);
//mints royalties to the idea inventor
DCPoA.increaseMemLev( repOwnerAddress);
//increases Member Level
  emit GlobalUseBlock(_rep, ideaID);
}

///@notice UseBlockWeight is an internal function that tracks loacal use weightTracker
///@dev this is called by generateUseBlockWeight
function UseBlockWeight(address _rep) internal {
  uint ideaID = CPBG.getIdeaID(_rep);
//sets ideaID as a specific ideaID from the replications struct
  uint repID = CPBG.getRepID(_rep);
//sets repID as a specific replications id from the replications struct
  uint _blockReward = 1;
//sets _blockReward equal to one
  uint _amount = calculatePromo(_blockReward, ideaID);
//sets _amount equal to the calculated block reward dependant upon promotion level of the replicator
  uint weight = localWeightTracker[_rep][repID];
// sets weight equal to the current weight of a specific replication
  uint newWeight = weight + _amount;
// increases the weight of a specific replication
  uint globalWeight = weightTracker[ideaID];
//sets globalWeight as the current highest weight for a specific idea
  uint repTimeLord = CPBG.getRepMiningTime(_rep);
//gets a replications mining time to prevent network spam/replication abuse
  require(now >= repTimeLord);
//this require fails if the rep is calling to frequently
  localWeightTracker[_rep][repID] = newWeight;
//sets the newWeight for that specific replication
  CPBG.setRepMiningTime(_rep);
//sets _reps mining time back to zero(kinda)
  if(newWeight >= globalWeight) {
//checks if the replication has the heaviest weight
    generateGlobalUseBlock(_rep);
//if it does it generates a global use block
    CPBG.setMiningTime(ideaID);
//resets the global mining time for a specific idea after a useBlock is mined
    }
    emit LocalUseWeight(_rep, newWeight);
  }
}
