pragma solidity ^0.5.0;

contract DecentraCorp {
  function proxyNTCMint(address _add, uint _amount) external;
  function proxyNTCBurn(address _add, uint _amount) external;
  function balanceOf(address owner) public view returns (uint256);
  function _checkIfMember(address _member) public view returns(bool);
  function getLevel(address _add) public view returns(uint);
  function transfer(address to, uint256 value) public returns (bool);
}
/// DecentraCorp PoA inteface
////////////////////////////////////////////////////////////////////////////////////////////

contract DCFacility {

address public owner;
bool public created;

  DecentraCorp public DCPoA;

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
  DCPoA = _owner;
  created = true;
}

function getFacilityMembers() public view returns(address[]) {
  return facilityMembers;
}

function checkIfMember(address _mem) public view returns(bool) {
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
  return DCPoA.balanceOf(address(this));
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

function payFacilityMembers() internal {
  uint share = balanceOf(address(this)) * facilityMembers.length / 100;


  for (uint i = 0; i <  facilityMembers.length; ++i) {
      DCPoA.transfer(facilityMembers[i], share);
}


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
              payFacilityMembers();
            }
            if(p.PropCode == 3) {
              
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
