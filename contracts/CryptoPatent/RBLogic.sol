pragma solidity ^0.4.21;
import "./IBLogic.sol";
////////////////////////////////////////////////////////////////////////////////////////////
/// @title RBLogic Contract for the CryptoPatent Blockchain
/// @author DecentraCorp
/// @notice this contract is the third contract in the CryptoPatent Blockchain
/// @dev All function calls are currently implement without side effects
////////////////////////////////////////////////////////////////////////////////////////////

/// @author Christopher Dixon
/// @dev this contract contains the cryptopatent interface for the IdeaBlock contract
contract RBLogic is IBLogic{

///@notice generateReplicationBlock is used to generate a replication block when someone sucessfully replicates an Idea
///@dev this requires the replicator has enough Notio to meet the stake amount and burns it from existence
///@dev it also adds the replicator as a member of DecentraCorp
///@dev finally, this contract calls the Proof of Replication Ownership contract and mints a PoRO token to the msg.sender
function generateReplicationBlock(uint _ideaId, address _repAdd) public  {
require(checkIfMember(msg.sender) == true);
require(NTC.balanceOf(msg.sender) >= repStake);
DCPoA.proxyNTCBurn(msg.sender, repStake);
globalRepCount++;
DCPoA.replicationBlock( _ideaId,  _repAdd, msg.sender);
DCPoA.increaseMemLev(msg.sender);
DCPoA.increaseFacilityRank(msg.sender, 1);
localMiningtimeTracker[_repAdd] = now;
emit NewReplication(_repAdd);
  }
///@notice changeStakeAmount will allow the community to change the stake amount required to stake a replication if it sees fit through a voted
///@dev this new amount must account for 18 decimals
  function changeStakeAmount(uint _newStakeAmount) external onlyOwner {
    repStake = _newStakeAmount;
  }
}
