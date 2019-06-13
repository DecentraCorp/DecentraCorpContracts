pragma solidity ^0.5.0;
import "zos-lib/contracts/Initializable.sol";
import "openzeppelin-eth/contracts/ownership/Ownable.sol";
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
}
/// DecentraCorp PoA inteface
////////////////////////////////////////////////////////////////////////////////////////////
  contract RelayedOwnedSet {
    	function addValidator(address _validator) external;
  }
/// Validator contract interface
/////////////////////////////////////////////////////////////////////////////////////////////
contract IdeaBlockLogic is Initializable, Ownable {

  DecentraCorp public DCPoA;
  RelayedOwnedSet public Validators;

  ///@param globalIdeaCount tracks amount of ideas on the CryptoPatent Blockchain
  ///@param globalBlockHalfTime used to track when the ideaBlockReward should be halved
  ///@param ideaBlockReward set to 1000 DCPoA
  ///@param repStake set to 100 DCPoA
  uint public globalIdeaCount;
  uint public globalBlockHalfTime;
  uint public ideaBlockReward;
  uint public globalIdeaPropCount;
  ///@param globalRepCount tracks the total number of replications on the CryptoPatent Blockchain
  uint public globalRepCount;
  uint public globalUseBlock;

  ///@param ideaVariables maps a token number to an ideas variables
  ///@param IdeaAddToId maps an Ideas address to its ID number
  mapping(uint => IdeaBlock) public ideaVariables;
  mapping(address => uint) public IdeaAddToId;
  mapping(uint => IdeaProposal) public ideaProposals;
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
       bool executed;
       bool proposalPassed;
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

  struct Vote {
          bool inSupport;
          address voter;
  }


  ///@struct IdeaBlock is built to store only needed variables to the blockchain, IPFS handles the rest
  struct IdeaBlock {
    uint globalUseBlockAmount;
    uint royalty;
    uint miningTime;
    uint stakeAmount;
    uint levelRequirement;
    address inventorAddress;
    address inventionAddress;
    string IPFShash;
  }
  //@struct ReplicationInfo stores replication information
  struct ReplicationInfo {
    uint BlockReward;
    uint IdeaID;
    uint Royalty;
    uint RepID;
    address InventorsAddress;
    address ReplicationAddress;
    address OwnersAddress;
    string DeviceLockHash;
  }


  ///@notice generateIdeaBlock is used to generate and ideablock after a community vote
  ///@dev this function is onlyOwner as atm the CPB is owning itself. In the future
  ///     this will likely be set to an account that will have special privlidges between this contracts and
  ///     the ethereum Based DecentraCorp contracts to facilitate crosschain communication

  function generateIdeaBlock(
    string memory _ideaIPFS,
    uint  _globalUseBlockAmount,
    uint _miningTime,
    uint _royalty,
    uint _stakeAmount,
    uint _levelRequirement,
    address _inventor,
    address _invention
    )
internal
    {
      globalIdeaCount++;
      uint _ideaId = globalIdeaCount;

      IdeaBlock memory _info = IdeaBlock({
        globalUseBlockAmount: uint(_globalUseBlockAmount),
        royalty: uint(_royalty),
        miningTime: uint(_miningTime),
        stakeAmount: uint(_stakeAmount),
        levelRequirement: uint(_levelRequirement),
        inventorAddress: address(_inventor),
        inventionAddress: address(_invention),
        IPFShash: string(_ideaIPFS)
        });

        IdeaAddToId[_invention] = _ideaId;
        ideaVariables[_ideaId] = _info;
        Validators.addValidator(_invention);
        ideaBlockTimeLord();
        DCPoA.proxyNTCMint( _inventor, ideaBlockReward);
        //mints 1000 DCPoA and sends it to the inventor
        DCPoA.increaseMemLev(_inventor);
        ideaBlocksOwned[_inventor].push(_ideaId);
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

}
