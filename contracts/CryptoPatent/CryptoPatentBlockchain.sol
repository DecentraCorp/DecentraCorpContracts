pragma solidity ^0.4.21;
import "./UseLogic.sol";
////////////////////////////////////////////////////////////////////////////////////////////
/// @title UseLogic Contract for the CryptoPatent Blockchain
/// @author DecentraCorp
/// @notice this contract is the fouth contract in the CryptoPatent Blockchain
/// @dev All function calls are currently implement without side effects
////////////////////////////////////////////////////////////////////////////////////////////
/// @author Christopher Dixon

contract CryptoPatentBlockchain is UseLogic {

///@notice constructor is used to set up the CryptoPatent Blockchain
///@dev this contract is fed the addresses of the other contracts through truffle magic
///@dev the address that launches the contracts is set as the first DecentraCorp Member
  constructor(address _dcpoa, address _NTC, address _CPBG) public {
    globalBlockHalfTime = now;
    DCPoA = DecentraCorpPoA(_dcpoa);
    NTC = Notio(_NTC);
    CPBG = CryptoPatentBlockGenerator(_CPBG);
  }

///@notice proposeIdea is used to allow ANYONE to petition the community for idea approval
///@dev the struct for this is set in interface.solidity
///@dev idea proposals are put up for community approval
  function proposeIdea(string _ideaIPFS) public {
          uint IdeaProposalID = proposals.length++;
          IdeaProposal storage p = proposals[IdeaProposalID];
          getHash[_ideaIPFS] = IdeaProposalID;
          p.IdeaIPFS = _ideaIPFS;
          p.executed = false;
          p.proposalPassed = false;
          p.numberOfVotes = 0;
          emit IdeaProposed(_ideaIPFS);
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

///@notice ideaBlockVote counts the votes and executes and Idea Proposal, adding an idea to the cryptopatent Blockchain
///@dev seperate but similiar structures will need to be implemented in the future to stream line voting on different subjects(beta)
function ideaBlockVote(uint _ideaProposalID, uint _globalUseBlockAmount,uint _miningTime, uint _royalty, address _inventor, address _invention) internal {
        IdeaProposal storage p = proposals[_ideaProposalID];
             // sets p equal to the specific proposalNumbers struct
        string memory _ideahash = p.IdeaIPFS;
        uint yea = 0;
        uint nay = 0;

    for (uint i = 0; i <  p.votes.length; ++i) {
        Vote storage v = p.votes[i];
        uint voteWeight = 1;
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
               generateIdeaBlock( _ideahash,  _globalUseBlockAmount, _miningTime, _royalty, _inventor, _invention);
               emit IdeaApproved( _ideahash);
           } else {
                 // Proposal failed
               p.proposalPassed = false;
               p.executed = true;
           }
      }
///@notice vote is a member only function which allows DecentraCorp members to vote on proposalPassed
///@dev onlyMember modifier ensures votes are only cast by DC Members
 function vote(
        uint _ideaProposalID,
        bool supportsProposal,
        uint _globalUseBlockAmount,
        uint _miningTime,
        uint _royalty,
        address _inventor,
        address _invention
    )
        public
        onlyMember
    {

        IdeaProposal storage p = proposals[_ideaProposalID];
        //makes the proposal an object, p
        require(p.voted[msg.sender] != true);
        //requires that the person calling the function hasnt voted yet
        require(p.executed != true);
        //requires the proposal hasnt been executed yet
        uint voteID = p.votes.length++;
        //sets voteID to the length of the votes array for that proposal
        p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
        //sets the individual votes properties to a voteID
        p.voted[msg.sender] = true;
        //sets the voter to true so they cant vote twice
        p.numberOfVotes++;
        //number of votes is set to the length of votes array
        DCPoA.increaseMemLev(msg.sender);
        //increases the members level for voting
        emit Voted(msg.sender, supportsProposal);
        //emits Voted event
        uint maxQuorum = DCPoA.getMemberCount();
        //sets maxQuorum equal to total # of members
        bool tally = set_Quorum(voteID, maxQuorum);
        //sets tally to either true of false depending if the # of votes is
        //greater than 60% of the total # of members
        if(tally == true) {
          ideaBlockVote(_ideaProposalID, _globalUseBlockAmount,_miningTime, _royalty, _inventor, _invention);
          //fires of the vote tally function
        }
    }
// allows members to vote on proposals

function checkIfVoted(address _add, uint _ideaProposalID) public view returns(bool) {
  IdeaProposal storage p = proposals[_ideaProposalID];
  return p.voted[_add];
}

}
