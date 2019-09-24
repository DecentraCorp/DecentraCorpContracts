pragma solidity ^0.5.0;
import  './IdeaBlockLogic.sol';


contract RepBlockLogic is IdeaBlockLogic {


  ///@notice generateReplicationBlock is used to generate a replication block when someone sucessfully replicates an Idea
  ///@dev this requires the replicator has enough NotioCoin to meet the stake amount and burns it from existence
  ///@dev it also adds the replicator as a member of DecentraCorp
  ///@dev finally, this contract calls the Proof of Replication Ownership contract and mints a PoRO token to the msg.sender
  function generateReplicationBlock(uint _ideaId, address _repAdd, address _repOwner, string memory _userId, string memory _DLhash) public  {
    address member = DCPoA.getAddFromPass(_userId);
//pulls the members address in from his username
  uint level = DCPoA.getLevel(member);
//gets the members level
  IdeaProposal storage info = ideaProposals[_ideaId];
//pulls the ideas variables in as info
  require(DCPoA._checkIfMember(member));
//requires the address of the member is an active member
  require(level >= info.levelRequirement);
//requires the members level be equal to or greater than the level required to stake the idea
  require(info.IdeaBlock);
//requires the selected idea is an IdeaBlock
  DCPoA.proxyNTCBurn(member, info.stakeAmount);
//burns the stake amount for the specific Idea from the members account
  uint blockReward = info.globalUseBlockAmount - info.royalty;
  //subtracts the royalty amount from the block reward
  address inventor = info.inventorAddress;
  //sets inventor as the specific inventor for an idea




  ReplicationInfo storage i = repInfo[_repAdd];
    i.BlockReward = blockReward;
    i.IdeaID = _ideaId;
    i.Royalty = info.royalty;
    i.InventorsAddress = inventor;
    i.ReplicationAddress = _repAdd;
    i.ReplicationMember = member;
    i.OwnersAddress = _repOwner;
    i.DeviceLockHash = _DLhash;

  //creates replication struct for new rep
  if(i.OwnersAddress == 0x0000000000000000000000000000000000000000) {
    i.OwnersAddress = member;
  }

    ideaRepCounter[_ideaId] = ideaRepCounter[_ideaId]++;
    //increments the global rep count for a specific idea
    replications[_repAdd] = true;
    //stores replications address as a replicator
    repOwnes[member][_ideaId] = repOwnes[member][_ideaId]++;
    //increments the amount of replications for an idea a replicator owns
    DCPoA.increaseMemLev(member);
    localMiningtimeTracker[_repAdd] = now;
    emit NewReplication(_repAdd, member);
    }

}
