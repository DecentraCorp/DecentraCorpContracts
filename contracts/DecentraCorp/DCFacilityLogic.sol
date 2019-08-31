pragma solidity ^0.5.0;

import './DCMember.sol';

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


 /**
 **@notice Proposal Codes are used to fire specific code. each number represents a different action
 *** the following are is a list of prop codes and their actions
 ** 1. Transfer Funds: Amount entered is amount to be transfered to address entered
 ** 2. Add Member to Facility; address entered is new facility member
 ** 3. Upgrade Facility: Amount represents the upgradeID
 ** 4. Remove Member: Removes a member from a Facility
 */
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


 ///@notice ideaBlockVote counts the votes and executes and Idea Proposal, adding an idea to the cryptopatent Blockchain
 ///@dev seperate but similiar structures will need to be implemented in the future to stream line voting on different subjects(beta)
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




//////////////////////////////////////////////////////////////////////
contract DCFacility {

address public owner;
bool public created;

address[] public facilityMembers;
mapping(address => bool) isFacilityMember;
mapping(uint => bool) isUpgradedFor;
mapping(address =>bool) isOwner;



   struct  Proposal {
        address Address;
        uint PropCode;
        uint Amount;
        string voteHash;
        bool executed;
        bool proposalPassed;
        Vote[] votes;
        mapping (address => bool) voted;
    }


    struct Vote {
            bool inSupport;
            address voter;
    }


function addFirstMember(address _newMember) public {
  require(isOwner);
  facilityMembers.push(_newMember);
  isFacilityMember[_newMember] = true;
}

function addMember(address _newMember) public {
  require(msg.sender == address(this));
  facilityMembers.push(_newMember);
  isFacilityMember[_newMember] = true;
}

function setOwner(address _owner) public {
  require(!created);
  owner = _owner;
  created = true;
}

function getFacilityMembers() public view returns(address[]) {
  return facilityMembers;
}

function  checkIfMember(address _mem) public view returns(bool) {
  return isFacilityMember[_mem];
}

function checkIfUpgraded(
  uint _upgradeID
)
 public
  view
  returns(bool) {
  return isUpgradedFor[_upgradeID];
}

function getFacilityNTCbal() public view returns(uint) {
  return facility.balanceOf(address(this));
}

///@notice set_Quorum is an internal function used by proposal vote counts to see if the community approves
///@dev quorum is set to 60%
  function percent(uint numerator, uint denominator, uint precision) internal pure returns(uint quotient) {
         // caution, check safe-to-multiply here
          uint _numerator  = numerator * 10 ** (precision+1);
        // with rounding of last digit
          uint _quotient =  ((_numerator / denominator) + 5) / 10;
          return ( _quotient);
        }

  function set_Quorum(uint numOfvotes, uint numOfmem) internal pure returns(bool) {
            uint percOfMemVoted = percent(numOfvotes, numOfmem, 2 );
             if(percOfMemVoted >= 60) {
                 return true;
             } else {
                 return false;
             }
          }


/**
**@notice Proposal Codes are used to fire specific code. each number represents a different action
*** the following are is a list of prop codes and their actions
** 1. Transfer Funds: Amount entered is amount to be transfered to address entered
** 2. Add Member to Facility; address entered is new facility member
** 3. Upgrade Facility: Amount represents the upgradeID
** 4. Remove Member: Removes a member from a Facility
*/
function createProposal(address _address, uint _propCode, string memory _voteHash, uint _amount) public {
  uint ProposalID = proposals.length++;
  Proposal storage p = proposals[ProposalID];
  p.Address = _address;
  p.PropCode = _propCode;
  p.voteHash = _voteHash;
  getHash[_voteHash] = ProposalID;
  propCode[_voteHash] = _propCode;
  p.Amount = _amount;
  p.executed = false;
  p.proposalPassed = false;
  emit ProposalCreated(_voteHash, _propCode);
}


function vote(
 uint _ProposalID,
 bool supportsProposal
)
 public
 returns (uint voteID)
{

 Proposal storage p = proposals[_ProposalID];
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
   executeVote(_ProposalID);
 }
 return voteID;
}


///@notice ideaBlockVote counts the votes and executes and Idea Proposal, adding an idea to the cryptopatent Blockchain
///@dev seperate but similiar structures will need to be implemented in the future to stream line voting on different subjects(beta)
function executeVote(uint _ProposalID) internal {
     Proposal storage p = proposals[_ProposalID];
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
            if(p.PropCode == 1) {
              transfer(p.Address, p.Amount);
             emit FundingApproved(p.Address, p.Amount);
            }
            if(p.PropCode == 2) {
              frozenAccounts[p.Address] = true;
            }
            if(p.PropCode == 3) {
              terminateMember(p.Address);
            }
            if(p.PropCode == 4) {
              addApprovedContract(p.Address);
            }
        } else {
              // Proposal failed
            p.proposalPassed = false;
        }

   }





function getPropID(string memory hash) public view returns(uint){
return getHash[hash];
}

function getPropCode(string memory hash) public view returns(uint){
return propCode[hash];
}

function checkIfVoted(address _add, uint _ProposalID) public view returns(bool) {
Proposal storage p = proposals[_ProposalID];
return p.voted[_add];
}
}
