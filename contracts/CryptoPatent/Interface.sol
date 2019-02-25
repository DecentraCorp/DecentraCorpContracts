pragma solidity ^0.4.21;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
////////////////////////////////////////////////////////////////////////////////////////////
/// @title Interface Contract for the CryptoPatent Blockchain
/// @author DecentraCorp
/// @notice this contract is built using the Ownership contract from the zeppelin-solidity library
/// @dev All function calls are currently implement without side effects
////////////////////////////////////////////////////////////////////////////////////////////
contract DecentraCorpPoA {
  function proxyIDCMint(address _add, uint _amount) external;
  function proxyIDCBurn(address _add, uint _amount) external;
  function proxyCCMint(address _add, uint _amount) external;
  function proxyCCBurn(address _add, uint _amount) external;
  function generateIdeaBlock(string _ideaIPFS, uint _globalUseBlockAmount, uint miningTime, uint _royalty, address _inventorsAddress, address _invention) external;
  function replicationBlock(uint _ideaId, address _repAdd, address _replicatorAdd) external;
  function generateGUSBlock(address _replicationOwner) external;
  function _addMember(address _mem, address _facility) external;
  function _checkIfMember(address _member) public view returns(bool);
  function getMemberCount() public view returns(uint);
  function increaseMemLev(address _add) external;
  function increaseFacilityRank(address _facAdd, uint _amount) public;
  function setProfileHash(address _add, string _hash) public;
  function addNewInvention(address _newInvention) external ;
  function getFecilityOfMember(address _mem) public view returns(address);
}
/// DecentraCorp PoA inteface
////////////////////////////////////////////////////////////////////////////////////////////
contract IdeaCoin {
    function balanceOf(address _addr) public constant returns (uint);
    function totalSupply() public constant returns (uint);
}
/// IdeaCoin interface
/////////////////////////////////////////////////////////////////////////////////////////////
contract CryptoPatentBlockGenerator {
    function balanceOf(address _owner) public view returns (uint256);
    function getGlobalUseBlockAmount(uint _ideaId) public view returns(uint);
    function getRoyalty(uint _ideaId) public view returns(uint);
    function getInventor(uint _ideaId) public view returns(address);
    function getIdeaMiningTime(uint _ideaId) public view returns(uint);
    function getBlockReward(address _repAdd) public view returns(uint);
    function getOwnersAddress(address _repAdd) public view returns(address);
    function getIdeaID(address _repAdd) public view returns(uint);
    function getInventorsAddress(address _repAdd) public view returns(address);
    function getReplicationAddress(address _repAdd) public view returns(address);
    function getRoyalty(address _repAdd) public view returns(uint);
    function getRepID(address _repAdd) public view returns(uint);
    function checkIfRep(address _add) external view returns(bool);
    function getNumOfReps(address _add, uint _ideaId) external view returns(uint);
    function getRepTotal(uint _ideaId) external view returns(uint);
    function safeTransfer(address _from, address _to, uint _tokenId) public;
    function setRepMiningTime(address _repAdd) external;

}
/// Block Generator interface
/////////////////////////////////////////////////////////////////////////////////////////////
  contract RelayedOwnedSet {
    	function addValidator(address _validator) external;
  }
/// Validator contract interface
/////////////////////////////////////////////////////////////////////////////////////////////

/// @author Christopher Dixon
/// @notice contract Interface is the first contract in the CryptoPatent Blockchain
/// @dev this contract is ment to set up the needed global variables as well as house various membership related functions
/// @dev for whatever reason, having the membership logic in the DCPoA contract causes truffle not to deploy properly(gas) remix works fine
contract Interface is Ownable {
  IdeaCoin public IDC;
  DecentraCorpPoA public DCPoA;
  CryptoPatentBlockGenerator public CPBG;
  RelayedOwnedSet public Validators;
  ///@param above turn each interface into a useable variable

  ///@param globalIdeaCount tracks amount of ideas on the CryptoPatent Blockchain
  ///@param globalRepCount tracks the total number of replications on the CryptoPatent Blockchain
  ///@param memberCount tracks the total number of CryptoGrow members
  ///@param globalUseBlock tracks global use blocks
  ///@param globalBlockHalfTime used to track when the ideaBlockReward should be halved
  ///@param ideaBlockReward set to 1000 IDC
  ///@param repStake set to 100 IDC
  ///@param minimumQuorum used to  track quorum info
  uint public globalIdeaCount;
  uint public globalRepCount;
  uint public globalUseBlock;
  uint public globalBlockHalfTime;
  uint public buyMemWindow;
  uint public ideaBlockReward = 1000000000000000000000;
  uint public repStake = 100000000000000000000;
  uint public minimumQuorum;
  address public CrossChainInfoBridge;

  ///@param IdeaProposal array of idea proposals
  IdeaProposal[] public proposals;


  ///@param weightTracker tracks current global highest weight
  ///@param localWeightTracker maps a replications address to its replication ID and stores that replications current weight
  ///@param members tracks if an address is a member
  ///@param memberRank tracks a members rank
  ///@param getHash maps ipfs hash to its token ID
  mapping (uint => uint) weightTracker;
  mapping (address => mapping (uint => uint)) localWeightTracker;
  mapping(string => uint) getHash;
  mapping(address => uint[]) getTokens;
  mapping(address => bool) inventions;
  mapping(address => uint) localMiningtimeTracker;


  event IdeaProposed(string IdeaHash);
  event IdeaApproved(string _ideahash);
  event Voted(address _voter, bool inSupport);
  event NewMember(address member);
  event NewReplication(address _repAdd);
  event ProfileUpdated(address updatedAccount);
  event LocalUseWeight(address repAdd, uint repWeight);
  event GlobalUseBlock(address repAdd, uint ideaId);

///@struct IdeaProposal stores info of a proposal
struct IdeaProposal {
     string IdeaIPFS;
     bool executed;
     bool proposalPassed;
     uint numberOfVotes;
     Vote[] votes;
     mapping (address => bool) voted;
 }
 //@struct Vote stores an individuals vote in an array in an Idea Proposal
  struct Vote {
          bool inSupport;
          address voter;
  }




//@modifier requires that the address calling a function is a member of DecentraCorp
  modifier onlyMember() {
    require(checkIfMember(msg.sender) == true);
    _;
  }

  //@modifier requires that the address calling a function is a member of DecentraCorp
    modifier onlyCIB() {
      require(msg.sender == CrossChainInfoBridge);
      _;
    }

///@notice calculatePromo function calculates the promotion a miner receives for having multiples of the same type of replication
///@dev calculatePromo takes in a block Reward and an idea ID to retun a specific block reward
  function calculatePromo(uint _blockReward, uint _ideaId) internal view returns(uint) {
    uint numberOfReps =  CPBG.getNumOfReps( msg.sender,  _ideaId);
    uint tenthReward = (_blockReward/ 10);
    uint modulator = tenthReward * numberOfReps;
    uint blockReward = _blockReward + modulator;
    return blockReward;
  }

///@notice addMember function is an internal function for adding a member to decentracorp
///@dev addMember takes in an address _mem, sets its membership to true and increments their rank by one
  function addMember(address _mem, address _facility) internal {
    DCPoA._addMember(_mem, _facility);
  }

///@notice buyMembership function allows for the purchase of a membership for 6 months after official launch.
///@dev mints the user 10,000 IDC
  function buyMembership(address _newMem, address _facility, string _hash) public onlyCIB{
    require(now <= buyMemWindow + 15780000 seconds);
    addMember(_newMem, _facility);
    DCPoA.setProfileHash(_newMem, _hash);
    emit NewMember(_newMem);
  }

///@notice setGenerators function takes in addresses of various contracts the CryptoPatent Blockchain inteacts with
///@dev setGenerators takes in these addresses automagically through truffle migrations
  function setGenerators(
    DecentraCorpPoA _dcpoa,
    IdeaCoin _IDC,
    CryptoPatentBlockGenerator  _CPBG
    )
    public
    onlyOwner
    {
      DCPoA = DecentraCorpPoA(_dcpoa);
      IDC = IdeaCoin(_IDC);
      CPBG =(_CPBG);
    }


///@notice checkIfMember function allowsother contracts/front end to check if an address is a member
///@dev checkIfMember takes in
function checkIfMember(address _member) public view returns(bool) {
  if( DCPoA._checkIfMember( _member) == true ) {
    return true;
  }
}

function updateProfile(string _newHash) public {
    DCPoA.setProfileHash(msg.sender, _newHash);
    emit ProfileUpdated(msg.sender);
}

  ///@notice getPropID function allows one to rerieve a proposal ID by its ipfs hash
  ///@dev getPropID is made for easier front end interaction
  function getPropID(string hash) public view returns(uint){
    return getHash[hash];
  }

///@notice stakeReplicatorWallet function allows for the activation of a replication wallet by
///        burning IdeaCoin from the msg.sender
///@dev stakeReplicatorWallet costs 100 IDC and burns them from existence
  function stakeReplicatorWallet(string _hash, address _facility) public {
    require(IDC.balanceOf(msg.sender) >= 100000000000000000000);
    DCPoA.proxyIDCBurn(msg.sender, 100000000000000000000);
    DCPoA._addMember(msg.sender, _facility);
    DCPoA.setProfileHash(msg.sender, _hash);
    emit NewMember(msg.sender);
  }

///@notice getIdeasOwner function returns what tokens the msg.sender owns
///@dev getIdeasOwner returns an array of uints
  function getIdeasOwner() public view returns(uint[]){
    return getTokens[msg.sender];
  }

  function setValidatorContract(address _valCon) public onlyOwner {
        Validators = RelayedOwnedSet(_valCon);
  }

  function setCIB(address _CIB) public onlyOwner {
  CrossChainInfoBridge = _CIB;
  }

}
