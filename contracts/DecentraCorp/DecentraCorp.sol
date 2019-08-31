pragma solidity ^0.5.0;

import './DCMember.sol';

 contract DecentraCorp is DCMember{
   using SafeMath for uint256;

   mapping(string => uint) getHash;
   mapping(string => uint) propCode;


   Proposal[] public proposals;

   event ProposalCreated(string VoteHash, uint PropCode);
   event Voted(address _voter, bool inSupport);
   event FundingApproved(address addToFund, uint amount);





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




/**
**@notice Proposal Codes are used to fire specific code. each number represents a different action
*** the following are is a list of prop codes and their actions
** 1. Funding Proposal: the address entered is the address receiving funding
** 2. MemberShip Account Freeze Proposal: the address entered is the address to be frozen
** 3. Membership Termination Proposal: the address entered is the address to be terminated
** 4. Add new Approved Contract: the address entered will be approved to mint/burn NotioCoin
//more options will be added to allow for contract upgrades in the future
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
