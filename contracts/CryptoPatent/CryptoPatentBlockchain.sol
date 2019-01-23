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
  constructor(address _dcpoa, address _IDC, address _CPBG) public {
    globalBlockHalfTime = now;
    DCPoA = DecentraCorpPoA(_dcpoa);
    IDC = IdeaCoin(_IDC);
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
function set_Quorum() internal  {
        uint maxQuorum = DCPoA.getMemberCount();
        uint tenthQuorum = (maxQuorum / 10);
        uint  halfQuorum = (maxQuorum / 2);
        minimumQuorum = (halfQuorum + tenthQuorum);
  }

///@notice ideaBlockVote counts the votes and executes and Idea Proposal, adding an idea to the cryptopatent Blockchain
///@dev seperate but similiar structures will need to be implemented in the future to stream line voting on different subjects(beta)
function ideaBlockVote(uint _ideaProposalID, uint _globalUseBlockAmount,uint _miningTime, uint _royalty, address _inventor, address _invention) internal {
        IdeaProposal storage p = proposals[_ideaProposalID];
             // sets p equal to the specific proposalNumber
        require(!p.executed);
        string memory _ideahash = p.IdeaIPFS;
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

             require(quorum >= minimumQuorum); // Check if a minimum quorum has been reached

             if (yea > nay ) {
                 // Proposal passed; execute the transaction
               p.executed = true;
               p.proposalPassed = true;
               generateIdeaBlock( _ideahash,  _globalUseBlockAmount, _miningTime, _royalty, _inventor, _invention);
               emit IdeaApproved( _ideahash);
           } else {
                 // Proposal failed
               p.proposalPassed = false;
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
        returns (uint voteID)
    {

        IdeaProposal storage p = proposals[_ideaProposalID];
        require(p.voted[msg.sender] != true);

        voteID = p.votes.length++;
        p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
        p.voted[msg.sender] = true;
        p.numberOfVotes = voteID++;
        DCPoA.increaseMemLev(msg.sender);
        emit Voted(msg.sender, supportsProposal);
        set_Quorum();
        if(p.numberOfVotes >= minimumQuorum) {
          ideaBlockVote(_ideaProposalID, _globalUseBlockAmount,_miningTime, _royalty, _inventor, _invention);
        }
        return voteID;
    }
// allows members to vote on proposals

function checkIfVoted(address _add, uint _ideaProposalID) public view returns(bool) {
  IdeaProposal storage p = proposals[_ideaProposalID];
  return p.voted[_add];
}

}
