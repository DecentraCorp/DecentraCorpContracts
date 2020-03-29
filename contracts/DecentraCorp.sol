pragma solidity ^0.5.0;

import './DCMember.sol';
////////////////////////////////////////////////////////////////////////////////////////////
/// @title DecentraCorp
/// @dev All function calls are currently implement without side effects
/// @author Christopher Dixon
////////////////////////////////////////////////////////////////////////////////////////////
 contract DecentraCorp is DCMember{


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
        uint proposedInterest;
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



    function initialize(address _DD, address _DS, address _bancor) public initializer {
      Ownable.initialize(msg.sender);
      addNewToken(_DD);
      DD = DecentraDollar(_DD);
      DS = DecentraStock(_DS);
      bancor = BancorFormulaI(_bancor);
    }

    function setUp() public onlyOwner {
      percentFee = 25;
      divisor = 10000;
      minimumPrice = 10000000000000000000;
      addMember(msg.sender);
      proxyDDMint(msg.sender, 10000000000000000000000);
    }


/**
**@notice Proposal Codes are used to fire specific code. each number represents a different action
*** the following are is a list of prop codes and their actions
** 1. Funding Proposal: the address entered is the address receiving funding
** 2. Add Member: Allows the community to grant membership to someone who cant afford it
** 3. Set Membership Price: Allows the community to set the price of a membership
** 4. Set Fee: Allows the community to set the fee taken when using other tokens to purchase/sell DecentraStock

//more options will be added to allow for contract upgrades in the future
*/
   function createProposal(
     address _address,
     uint _propCode,
     string memory _voteHash,
     uint _amount,
     uint _interest
   )
   public
   {
           uint ProposalID = proposals.length++;
           Proposal storage p = proposals[ProposalID];
           p.Address = _address;
           p.PropCode = _propCode;
           p.voteHash = _voteHash;
           p.proposedInterest = _interest;
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
          onlyMember
          returns (uint voteID)
      {

          Proposal storage p = proposals[_ProposalID];
          require(p.voted[msg.sender] != true);
          voteID = p.votes.length++;
          p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
          p.voted[msg.sender] = true;
          emit Voted(msg.sender, supportsProposal);
          bool tally = false;

           tally = set_Quorum(voteID, memberCount);

           tally = true;

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


              quorum.add(1);
              if (v.inSupport) {
                yea.add(1);
                   } else {
                 nay.add(1);
                       }
                   }


                   if (yea > nay ) {
                       // Proposal passed; execute the transaction
                     p.executed = true;
                     p.proposalPassed = true;
                     if(p.PropCode == 1) {
                       proxyDDBurn(address(this),  p.Amount);
                       proxyDDMint(p.Address, p.Amount);
                       DecentraEarnings = DecentraEarnings.sub(p.Amount);
                      emit FundingApproved(p.Address, p.Amount);
                     }
                     if(p.PropCode == 2) {
                       addMember(p.Address);
                     }
                     if(p.PropCode == 3) {
                       setPrice(p.Amount);
                     }
                     if(p.PropCode == 4) {
                       setFee(p.Amount);
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
