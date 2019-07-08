pragma solidity ^0.5.0;

import './UseBlockLogic.sol';

contract CryptoPatentBlockchain is UseBlockLogic {


  function initialize() public initializer {
    Ownable.initialize(msg.sender);
    ideaBlockReward = 1000000000000000000000;
    globalBlockHalfTime = now;
  }


  ///@notice vote is a member only function which allows DecentraCorp members to vote on proposalPassed

   function ideaVote(
          uint _ideaProposalID,
          bool supportsProposal
      )
          public

      {
          require(DCPoA._checkIfMember(msg.sender) == true);
          IdeaProposal storage p = ideaProposals[_ideaProposalID];
          //makes the proposal an object, p
          require(p.voted[msg.sender] != true);
          //requires that the person calling the function hasnt voted yet
          require(p.executed != true);
          //requires the proposal hasnt been executed yet
          uint voteID = p.votes.length++;
          //sets voteID to the length of the votes array for that proposal
          p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
          //sets the individual Vote struct  properties to a voteID within votes struct array
          p.voted[msg.sender] = true;
          //sets the voter to true so they cant vote twice
          DCPoA.increaseMemLev(msg.sender);
          //increases the members level for voting
          emit Voted(msg.sender, supportsProposal);
          //emits Voted event
          uint maxQuorum = DCPoA.getMemberCount();
          //sets maxQuorum equal to total # of members
          bool tally = setVoteQuorum(p.votes.length, maxQuorum);
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
                 p.IdeaBlock = true;
                 p.executed = true;
                 IdeaAddToId[p.inventionAddress] = _ideaProposalID;
                 ideaBlockTimeLord();
                 Validators.addValidator(p.inventionAddress);
                 DCPoA.proxyNTCMint( p.inventorAddress, ideaBlockReward);
                 DCPoA.increaseMemLev(p.inventorAddress);
                 ideaBlocksOwned[p.inventorAddress].push(_ideaProposalID);
                 emit IdeaApproved( p.IdeaIPFS, p.inventorAddress);
             } else {
                   // Proposal failed
                 p.executed = false;
                 p.IdeaBlock = true;
             }
        }

  ///@notice stakeReplicatorWallet function allows for the activation of a replication wallet by
  ///        burning Notio from the msg.sender
  ///@dev stakeReplicatorWallet costs 100 DCPoA and burns them from existence
function stakeReplicatorWallet(string memory _hash, string memory _userId) public {
        DCPoA.proxyNTCBurn(msg.sender, 100000000000000000000);
        DCPoA._addMember(msg.sender, _userId);
        DCPoA.setProfileHash(msg.sender, _hash);
        emit NewMember(msg.sender);
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

function checkIfVotedIdea(address _add, uint _ideaProposalID) public view returns(bool) {
        IdeaProposal storage p = ideaProposals[_ideaProposalID];
        return p.voted[_add];
        }

              ///@notice getPropID function allows one to rerieve a proposal ID by its ipfs hash
///@dev getPropID is made for easier front end interaction
function getPropID(string memory hash) public view returns(uint){
  return getHash[hash];
}

function getOwnedIB(address _mem) public view returns(uint[] memory){
  return ideaBlocksOwned[_mem];
}

function transferRepBlock(address _newOwner, address _rep) public view {
  ReplicationInfo memory infoR = repInfo[_rep];
  require(msg.sender == infoR.OwnersAddress);
  infoR.OwnersAddress = _newOwner;
}
function addV(address _add) public {
    Validators.addValidator(_add);
}
}
