pragma solidity ^0.5.0;
import  './IdeaBlockLogic.sol';


contract RepBlockLogic is IdeaBlockLogic {


  ///@notice generateReplicationBlock is used to generate a replication block when someone sucessfully replicates an Idea
  ///@dev this requires the replicator has enough Notio to meet the stake amount and burns it from existence
  ///@dev it also adds the replicator as a member of DecentraCorp
  ///@dev finally, this contract calls the Proof of Replication Ownership contract and mints a PoRO token to the msg.sender
  function generateReplicationBlock(uint _ideaId, address _repAdd) public  {
  require(DCPoA._checkIfMember(msg.sender));
  DCPoA.proxyNTCBurn(msg.sender, repStake);
  globalRepCount++;

  IdeaBlock memory info = ideaVariables[_ideaId];

  uint RepBlockReward  = info.globalUseBlockAmount;
  //sets RepBlockReward as the specific rep block amount Stored for an idea
  uint royalty = info.royalty;
  //sets royalty as the specific royalty amount for an idea
  uint blockReward = RepBlockReward - royalty;
  //subtracts the royalty amount from the block reward
  address inventor = info.inventorAddress;
  //sets inventor as the specific inventor for an idea
  uint _repId = globalRepCount;
  //sets _repNumber equal to globalRepCount

  ReplicationInfo memory _info = ReplicationInfo({
    BlockReward: uint( blockReward),
    OwnersAddress: address(msg.sender),
    IdeaID: uint(_ideaId),
    Royalty: uint(royalty),
    RepID: uint(_repId),
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
    uint ownerRepCount = repOwnes[msg.sender][_ideaId];
    //sets ownerRepCount to how many replications of a specific idea a replicator owns
    repOwnes[msg.sender][_ideaId] = ownerRepCount++;
    //increments the amount of replications for an idea a replicator owns
    DCPoA.increaseMemLev(msg.sender);
    localMiningtimeTracker[_repAdd] = now;
    emit NewReplication(_repAdd);
    }

}
