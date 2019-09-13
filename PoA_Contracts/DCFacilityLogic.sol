pragma solidity ^0.5.0;

import './DCMember.sol';
import './DCFacility.sol';

 contract DCFacilityLogic is DCMember{
   using SafeMath for uint256;

   address[] public facilities;
   uint public upgradeCount;

   mapping(string => address) facilityNames;
   mapping(address => bool) isFacility;
   mapping(uint => FacilityUpgradeProps) upgrades;

   struct FacilityUpgradeProps {
     uint upgradeAmount;
     uint mineAmount;
     address upgradeContract;
     bool proposalPassed;
     Vote[] votes;
     mapping (address => bool) voted;
   }

   modifier onlyFacility() {
     require(isFacility[msg.sender] == true);
     _;
   }

 function getFacilityCount()
   public
   pure
   returns(uint)
 {
   return facilities.length;
 }



 function newFacility(string _name)
   public
   returns(address)
 {
   require(members[msg.sender] == true);
   DCFacility f = new DCFacility();
   facilities.push(f);
   facilityNames[_name] = f;
   isFacility[f] = true;
   f.setOwner(address(this));
   f.addFirstMember(msg.sender);
   return f;
 }

 function proposeUpgrade(
   uint _upgradeAmount,
   uint _mineAmount,
   address _upgradeContract
 ) public {
   upgradeCount++;

   FacilityUpgradeProps storage p = upgrades[upgradeCount];
   p.upgradeAmount = _upgradeAmount;
   p.upgradeContract = _upgradeContract;
   p.mineAmount = _mineAmount;
   p.executed = false;
   p.proposalPassed = false;
   emit ProposalCreated(_voteHash, _propCode);
 }


 function vote(
  uint _upgradeID,
  bool supportsProposal
 )
  public
  returns (uint voteID)
 {

   FacilityUpgradeProps storage p = upgrades[_upgradeID];
  require(p.voted[msg.sender] != true);
  require(members[msg.sender] == true);
  voteID = p.votes.length++;
  p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
  p.voted[msg.sender] = true;
  memberLevel[msg.sender]++;
  emit Voted(msg.sender, supportsProposal);
  if(memberCount >= 3){
  bool tally = set_Quorum(voteID, memberCount);
 }else{
  bool tally = true;
 }
  if(tally) {
    executeVote(_upgradeID);
  }
  return voteID;
 }



 function executeUpgradeVote(uint _upgradeID) internal {
      FacilityUpgradeProps storage p = upgrades[_upgradeID];
           // sets p equal to the specific proposalNumber
      require(!p.executed);
      uint quorum = 0;
      uint yea = 0;
      uint nay = 0;



  for (uint i = 0; i <  p.votes.length; ++i) {
      Vote storage v = p.votes[i];
      uint voteWeight = 1;
      quorum += voteWeight;
      if (v.inSupport) {
        yea += voteWeight;
           } else {
         nay += voteWeight;
               }
           }


           if (yea > nay ) {
               // Proposal passed; execute the transaction
             p.executed = true;
             p.proposalPassed = true;
             newFacilityUpgrade(p.upgradeAmount, p.upgradeContract, p.mineAmount);
         } else {
               // Proposal failed
             p.proposalPassed = false;
         }

    }
