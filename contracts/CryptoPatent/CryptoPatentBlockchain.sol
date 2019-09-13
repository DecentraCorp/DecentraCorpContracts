pragma solidity ^0.5.0;

import './UseBlockLogic.sol';

contract CryptoPatentBlockchain is UseBlockLogic {


  function initialize() public initializer {
    Ownable.initialize(msg.sender);
    ideaBlockReward = 1000000000000000000000;
    globalBlockHalfTime = now;
  }

  ///@notice proposeIdea is used to allow ANYONE to petition the community for idea approval
  ///@dev the struct for this is set in interface.solidity
  ///@dev idea proposals are put up for community approval
  function proposeIdeaUpgrade(
    string memory _ideaIPFS,

    uint _globalUseBlockAmount,
    uint _miningTime,
    uint _royalty,
    uint _stakeAmount,
    uint _levelRequirement,
    address _inventor,
    address _invention
  ) public {

          uint ideaID = getHash[_ideaIPFS];

          IdeaUpgradeProposal storage p = ideaUpgradeProposals[ideaID];
          p.uIdeaIPFS = _ideaIPFS;
          p.uexecuted = false;
          p.uglobalUseBlockAmount = _globalUseBlockAmount;
          p.uroyalty = _royalty;
          p.ustakeAmount = _stakeAmount;
          p.ulevelRequirement = _levelRequirement;
          p.uminingTime = _miningTime;
          p.uinventorAddress = _inventor;
          p.uinventionAddress = _invention;
          emit IdeaProposed(_ideaIPFS);
  }


  ///@notice vote is a member only function which allows DecentraCorp members to vote on proposalPassed

   function ideaVote(
          uint _ideaProposalID,
          bool supportsProposal
      )
          public

      {
          require(DCPoA._checkIfMember(msg.sender) == true);
          IdeaUpgradeProposal storage p = ideaUpgradeProposals[_ideaProposalID];
          //makes the proposal an object, p
          require(p.uvoted[msg.sender] != true);
          //requires that the person calling the function hasnt voted yet
          require(p.uexecuted != true);
          //requires the proposal hasnt been executed yet
          uint voteID = p.uvotes.length++;
          //sets voteID to the length of the votes array for that proposal
          p.uvotes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
          //sets the individual Vote struct  properties to a voteID within votes struct array
          p.uvoted[msg.sender] = true;
          //sets the voter to true so they cant vote twice
          DCPoA.increaseMemLev(msg.sender);
          //increases the members level for voting
          emit Voted(msg.sender, supportsProposal);
          //emits Voted event
          uint maxQuorum = DCPoA.getMemberCount();
          //sets maxQuorum equal to total # of members
          bool tally = setVoteQuorum(p.uvotes.length, maxQuorum);
          //sets tally to either true of false depending if the # of members that have voted
          //must be greater than 80% of the total # of members
          if(tally) {
            ideaBlockVote(_ideaProposalID, maxQuorum);
            //fires of the vote tally function
          }
      }


  // allows members to vote on proposals
  ///@notice ideaBlockVote counts the votes and executes and Idea Proposal, adding an idea to the cryptopatent Blockchain
  ///@dev seperate but similiar structures will need to be implemented in the future to stream line voting on different subjects(beta)
  function ideaBlockVote(uint _ideaProposalID, uint maxQuorum) internal {
          IdeaProposal storage p = ideaProposals[_ideaProposalID];
               // sets p equal to the specific proposalNumbers struct
                 IdeaUpgradeProposal storage u = ideaUpgradeProposals[_ideaProposalID];
          uint yea = 0;


      for (uint i = 0; i <  p.votes.length; ++i) {
          Vote storage v = p.votes[i];

          if (v.inSupport) {
            yea += 1;
               }
            }

            bool passes = setVoteNumberQuorum(yea, maxQuorum);
        //checks if the number of yea votes is 60% or more of the total number of members

               if (passes) {
                   // Proposal passed; execute the transaction

                 u.uexecuted = true;
                p.IdeaIPFS =   u.uIdeaIPFS;
                p.globalUseBlockAmount = u.uglobalUseBlockAmount;
                p.royalty = u.uroyalty;
                p.stakeAmount = u.ustakeAmount;
                p.levelRequirement = u.ulevelRequirement;
                p.miningTime = u.uminingTime;
                p.inventorAddress = u.uinventorAddress;
                p.inventionAddress = u.uinventionAddress;

             } else {
                   // Proposal failed
                 p.executed = false;
                 p.IdeaBlock = true;
             }
        }



  ///@notice the following functions allow for easier access to info by both the front end and other contracts
  ///@dev all the following contracts allow for the retreval of token block information
function checkIfRep(address _add) external view returns(bool) {
        return replications[_add];
        }


function getID(address _ideaAdd) public view returns(uint){
        return IdeaAddToId[_ideaAdd];
        }

function setValidatorContract(address _valCon) public onlyOwner {
        Validators = RelayedOwnedSet(_valCon);
        }

function setDCPoA(DecentraCorp _dcpoa) public onlyOwner {
        DCPoA = DecentraCorp(_dcpoa);
        }



function transferRepBlock(address _newOwner, address _rep) public view {
  ReplicationInfo memory infoR = repInfo[_rep];
  require(msg.sender == infoR.OwnersAddress);
  infoR.OwnersAddress = _newOwner;
}

}
