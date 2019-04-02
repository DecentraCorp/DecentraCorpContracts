pragma solidity ^0.5.0;
import './UseBlockLogic.sol';

contract CryptoPatentBlockchain is UseBlockLogic {


  function initialize() public initializer {
    Ownable.initialize(msg.sender);
    ideaBlockReward = 1000000000000000000000;
    repStake = 100000000000000000000;
    globalBlockHalfTime = now;
  }


  ///@notice proposeIdea is used to allow ANYONE to petition the community for idea approval
  ///@dev the struct for this is set in interface.solidity
  ///@dev idea proposals are put up for community approval
  function proposeIdea(string memory _ideaIPFS) public {
          globalIdeaPropCount++;
          uint IdeaProposalID = globalIdeaPropCount;
          getHash[_ideaIPFS] = IdeaProposalID;
          IdeaProposal storage p = ideaProposals[IdeaProposalID];
          p.IdeaIPFS = _ideaIPFS;
          p.executed = false;
          p.proposalPassed = false;
          emit IdeaProposed(_ideaIPFS);
  }



  ///@notice vote is a member only function which allows DecentraCorp members to vote on proposalPassed

   function ideaVote(
          uint _ideaProposalID,
          bool supportsProposal,
          uint _globalUseBlockAmount,
          uint _miningTime,
          uint _royalty,
          address _inventor,
          address _invention
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
          bool tally = set_Quorum(voteID, maxQuorum);
          //sets tally to either true of false depending if the # of votes is
          //greater than 60% of the total # of members
          if(tally) {
            ideaBlockVote(_ideaProposalID, _globalUseBlockAmount,_miningTime, _royalty, _inventor, _invention);
            //fires of the vote tally function
          }
      }


  // allows members to vote on proposals
  ///@notice ideaBlockVote counts the votes and executes and Idea Proposal, adding an idea to the cryptopatent Blockchain
  ///@dev seperate but similiar structures will need to be implemented in the future to stream line voting on different subjects(beta)
  function ideaBlockVote(uint _ideaProposalID, uint _globalUseBlockAmount,uint _miningTime, uint _royalty, address _inventor, address _invention) internal {
          IdeaProposal storage p = ideaProposals[_ideaProposalID];
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

        ///@notice stakeReplicatorWallet function allows for the activation of a replication wallet by
        ///        burning Notio from the msg.sender
        ///@dev stakeReplicatorWallet costs 100 DCPoA and burns them from existence
          function stakeReplicatorWallet(string memory _hash) public {
            DCPoA.proxyNTCBurn(msg.sender, 100000000000000000000);
            DCPoA._addMember(msg.sender);
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
          ///@notice changeStakeAmount will allow the community to change the stake amount required to stake a replication if it sees fit through a voted
          ///@dev this new amount must account for 18 decimals
              function changeStakeAmount(uint _newStakeAmount) external onlyOwner {
                repStake = _newStakeAmount;
              }

              function setValidatorContract(address _valCon) public onlyOwner {
                    Validators = RelayedOwnedSet(_valCon);
              }

              function setDCPoA(DecentraCorpPoA _dcpoa) public onlyOwner {
                DCPoA = DecentraCorpPoA(_dcpoa);
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


}
