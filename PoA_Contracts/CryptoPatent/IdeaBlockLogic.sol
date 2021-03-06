pragma solidity ^0.5.0;
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
////////////////////////////////////////////////////////////////////////////////////////////
/// @title Interface Contract for the CryptoPatent Blockchain
/// @author DecentraCorp
/// @notice this contract is built using the Ownership contract from the zeppelin-solidity library
/// @dev All function calls are currently implement without side effects
////////////////////////////////////////////////////////////////////////////////////////////
contract DecentraCorp {
  function proxyNTCMint(address _add, uint _amount) external;
  function proxyNTCBurn(address _add, uint _amount) external;
  function _addMember(address _mem, string calldata _userId) external;
  function _checkIfMember(address _member) public view returns(bool);
  function increaseMemLev(address _add) external;
  function setProfileHash(address _add, string memory _hash) public;
  function getMemberCount() public view returns(uint);
  function getAddFromPass(string memory _userId) public view returns(address);
  function getLevel(address _add) public view returns(uint);
  function addValidatorProxy(address _newVal) external;
}
/// DecentraCorp PoA inteface
////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////
contract IdeaBlockLogic is Initializable, Ownable {

  DecentraCorp public DCPoA;
  RelayedOwnedSet public Validators;


  ///@param globalBlockHalfTime used to track when the ideaBlockReward should be halved
  ///@param ideaBlockReward set to 1000 DCPoA
  ///@param repStake set to 100 DCPoA

  uint public globalBlockHalfTime;
  uint public ideaBlockReward;
  uint public globalIdeaPropCount;
  uint public globalUseBlock;

  ///@param ideaVariables maps a token number to an ideas variables
  ///@param IdeaAddToId maps an Ideas address to its ID number

  mapping(address => uint) public IdeaAddToId;
  mapping(uint => IdeaProposal) public ideaProposals;
  mapping(uint => IdeaUpgradeProposal) public ideaUpgradeProposals;
  mapping(uint => uint) public weightTracker;
  mapping(address => uint) public localWeightTracker;

  ///@param ideaRepCounter tracks the total number of replications for a specific idea
  ///@param repInfo maps a reps address to its information
  ///@param repOwnes tracks how many of a specific type of replication a replicator owns(this is for pool mining)
  mapping(uint => uint) public ideaRepCounter;
  mapping(address => uint) public localMiningtimeTracker;
  mapping(address => bool) public replications;
  mapping(address => ReplicationInfo) public repInfo;
  mapping(address => mapping(uint => uint)) public repOwnes;
  mapping(string => uint) getHash;
  mapping(address => uint[]) ideaBlocksOwned;


  event IdeaProposed(string IPFS);
  event NewMember(address member);
  event IdeaApproved(string IPFS, address Inventor);
  event Voted(address _voter, bool inSupport);
  event NewReplication(address _repAdd, address repOwner);
  event LocalUseWeight(address repAdd, address reOwner, uint repWeight);
  event GlobalUseBlock(address repAdd, address reOwner, uint ideaId);


  ///@struct IdeaProposal stores info of a proposal
  struct IdeaProposal {
       string IdeaIPFS;
       bool IdeaBlock;
       bool executed;
       uint globalUseBlockAmount;
       uint royalty;
       uint miningTime;
       uint stakeAmount;
       uint levelRequirement;
       address inventorAddress;
       address inventionAddress;
       Vote[] votes;
       mapping (address => bool) voted;
   }


   struct IdeaUpgradeProposal {
        string uIdeaIPFS;
        bool uexecuted;
        uint uglobalUseBlockAmount;
        uint uroyalty;
        uint uminingTime;
        uint ustakeAmount;
        uint ulevelRequirement;
        address uinventorAddress;
        address uinventionAddress;
        Vote[] uvotes;
        mapping (address => bool) uvoted;
    }


  struct Vote {
          bool inSupport;
          address voter;
  }



  //@struct ReplicationInfo stores replication information
  struct ReplicationInfo {
    uint BlockReward;
    uint IdeaID;
    uint Royalty;
    address InventorsAddress;
    address ReplicationAddress;
    address ReplicationMember;
    address OwnersAddress;
    string DeviceLockHash;
  }


  ///@notice proposeIdea is used to allow ANYONE to petition the community for idea approval
  ///@dev the struct for this is set in interface.solidity
  ///@dev idea proposals are put up for community approval
  function proposeIdea(
    string memory _ideaIPFS,
    uint _globalUseBlockAmount,
    uint _miningTime,
    uint _royalty,
    uint _stakeAmount,
    uint _levelRequirement,
    address _inventor,
    address _invention
  ) public {
          globalIdeaPropCount++;

          getHash[_ideaIPFS] = globalIdeaPropCount;

          uint royalty = _globalUseBlockAmount * _royalty / 100;

          IdeaProposal storage p = ideaProposals[globalIdeaPropCount];
          p.IdeaIPFS = _ideaIPFS;
          p.IdeaBlock = false;
          p.executed = false;
          p.globalUseBlockAmount = _globalUseBlockAmount;
          p.royalty = royalty;
          p.stakeAmount = _stakeAmount;
          p.levelRequirement = _levelRequirement;
          p.miningTime = _miningTime;
          p.inventorAddress = _inventor;
          p.inventionAddress = _invention;
          emit IdeaProposed(_ideaIPFS);
  }

  ///@notice ideaBlockTimeLord is called to half an ideablock reward every two years
  ///@dev this time may need to be adjusted to 4 years depending on predicted inflation patterns of DCPoA
    function ideaBlockTimeLord() internal returns(uint){
      if(now >= globalBlockHalfTime + 94670778) {
        ideaBlockReward = ideaBlockReward / 2;
        globalBlockHalfTime = now;
        return ideaBlockReward;
        }else{
        return ideaBlockReward;
      }
    }
    ///@notice set_Quorum is an internal function used by proposal vote counts to see if the community approves
    ///@dev quorum is set to 60%
        function percent(uint numerator, uint denominator, uint precision) public pure returns(uint quotient) {
               // caution, check safe-to-multiply here
                uint _numerator  = numerator * 10 ** (precision+1);
              // with rounding of last digit
                uint _quotient =  ((_numerator / denominator) + 5) / 10;
                return ( _quotient);
              }

        function setVoteQuorum(uint numOfvotes, uint numOfmem) public pure returns(bool) {
                  uint percOfMemVoted = percent(numOfvotes, numOfmem, 2 );
                   if(percOfMemVoted >= 80) {
                       return true;
                   } else {
                       return false;
                   }
                }

        function setVoteNumberQuorum(uint numOfvotes, uint numOfmem) public pure returns(bool) {
                  uint percOfMemVoted = percent(numOfvotes, numOfmem, 2 );
                     if(percOfMemVoted >= 60) {
                           return true;
                       } else {
                           return false;
                           }
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
                                       DCPoA.addValidatorProxy(p.inventionAddress);
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

        function transferIdeaBlock(address _newOwner, uint _ideaProposalID) public  {
                IdeaProposal storage p = ideaProposals[_ideaProposalID];
                require(msg.sender == p.inventorAddress);
                p.inventorAddress = _newOwner;
              }
}
