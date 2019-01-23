pragma solidity ^0.4.21;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

////////////////////////////////////////////////////////////////////////////////////////////
/// @title DecentraCorpPoA
/// @author DecentraCorp
/// @notice this contract will serve as an information portal between the main ethereum
///   network and the CryptoPatent Blockchain
/// @dev All function calls are currently implement without side effects
////////////////////////////////////////////////////////////////////////////////////////////
/// @author Christopher Dixon
////////////////////////////////////////////////////////////////////////////////////////////
contract IdeaCoin {
    function mint(address _to, uint256 _value) external;
    function burnIDC(address _from, uint256 _value)  external;
    function balanceOf(address _addr) public constant returns (uint);
}
//IdeaCoin interface
/////////////////////////////////////////////////////////////////////////////////////////////
contract ProofOfPurchaseToken{
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function _mintItemToken( string _itemIPFSHash) external;
}
////////////////////////////////////////////////////////////////////////////////////////////
contract ChaosCoin {
    function mint(address _to, uint256 _value) external;
    function burnCC(address _from, uint256 _value)  external;

}
//ChaosCoin interface
/////////////////////////////////////////////////////////////////////////////////////////////
contract CryptoPatentBlockGenerator {
    function _generateIdeaBlock(string _ideaIPFS, uint _globalUseBlockAmount, uint miningTime, uint _royalty, address _inventorsAddress) external;
    function _replicationBlock(uint _ideaId, address _repAdd, address _replicatorAdd) external;
    function _generateGUSBlock(address _replicationOwner) external;
}
/// CryptoPatentBlockGenerator interface
/////////////////////////////////////////////////////////////////////////////////////////////

 contract DecentraCorpPoA is Ownable {
   using SafeMath for uint256;
///@param IDC is used to make calls to the IdeaCoin Contract
   IdeaCoin public IDC;
   CryptoPatentBlockGenerator public CPBG;
   ChaosCoin public CC;
   ProofOfPurchaseToken public PoPT;

   uint public memberCount;
   uint public minimumQuorum;
   bool public frozen;
   address public founder;
   mapping (address =>bool) members;
   mapping(address => uint) memberLevel;
   mapping(address => uint) facilityRank;
   mapping(address => string) memberProfileHash;
   mapping(address => bool) frozenAccounts;
///@param approvedContracts is a mappiung of contracts alloud to call function on other
   mapping(address => bool) approvedContracts;
   mapping(string => uint) getHash;
   mapping(string => uint) propCode;
   mapping(address => string) profileComments;
   Proposal[] public proposals;

   event ProposalCreated(string VoteHash, uint PropCode);
   event Voted(address _voter, bool inSupport);


   struct Proposal {
        address Address;
        uint PropCode;
        uint Amount;
        string voteHash;
        bool executed;
        bool proposalPassed;
        uint numberOfVotes;
        Vote[] votes;
        mapping (address => bool) voted;
    }

    struct Vote {
            bool inSupport;
            address voter;
    }


   modifier onlyApprovedAdd() {
     require(approvedContracts[msg.sender] == true);
     _;
   }





///@notice constructor sets up IdeaCoin address through truffle wizardry
   constructor(IdeaCoin _IDC, CryptoPatentBlockGenerator _CPBG, ChaosCoin _CC, ProofOfPurchaseToken _PoPT) public {
     IDC=(_IDC);
     CPBG =(_CPBG);
     CC=(_CC);
     PoPT = (_PoPT);
     members[msg.sender] = true;
     memberCount++;
     memberLevel[msg.sender] += 100;
     memberProfileHash[msg.sender] = "QmSu93p6XRanSNmov4e5c8VQPBxKo2zWf1jZpvVTfwi2L9";
     facilityRank[msg.sender] += 100;
     founder = msg.sender;
   }
/**
**@notice Proposal Codes are used to fire specific code. each number represents a different action
*** the following are is a list of prop codes and their actions
** 1. Funding Proposal: the address entered is the address receiving funding
** 2. MemberShip Account Freeze Proposal: the address entered is the address to be frozen
** 3. Membership Termination Proposal: the address entered is the address to be terminated
//more options will be added to allow for contract upgrades in the future
*/
   function createProposal(address _address, uint _propCode, string _voteHash, uint _amount) public {
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
           p.numberOfVotes = 0;
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
          p.numberOfVotes = voteID++;
          memberLevel[msg.sender]++;
          emit Voted(msg.sender, supportsProposal);
          set_Quorum();
          if(p.numberOfVotes >= minimumQuorum) {
            executeVote(_ProposalID);
          }
          return voteID;
      }

      function set_Quorum() internal  {
              uint maxQuorum = getMemberCount();
              uint tenthQuorum = (maxQuorum / 10);
              uint  halfQuorum = (maxQuorum / 2);
              minimumQuorum = (halfQuorum + tenthQuorum);
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

                   require(quorum >= minimumQuorum); // Check if a minimum quorum has been reached

                   if (yea > nay ) {
                       // Proposal passed; execute the transaction
                     p.executed = true;
                     p.proposalPassed = true;
                     if(p.PropCode == 1) {
                       p.Address.transfer(p.Amount);
                     }
                     if(p.PropCode == 2) {
                       frozenAccounts[p.Address] = true;
                     }
                     if(p.PropCode == 3) {
                       terminateMember(p.Address);
                     }
                 } else {
                       // Proposal failed
                     p.proposalPassed = false;
                 }
            }


//@addApprovedContract allows another contract to call functions
///@dev adds contract to list of approved calling contracts
  function addApprovedContract(address _newContract) public onlyOwner {
        approvedContracts[_newContract] = true;
      }

///@notice setIDCadd allows the address of the IdeaCoin contract to be updated
   function setIDCadd(address _IDC) public onlyOwner {
     IDC = IdeaCoin(_IDC);
   }

///@notice proxyMint allows an approved address to mint IdeaCoin
   function proxyIDCMint(address _add, uint _amount) external onlyApprovedAdd {
     require(_checkIfFrozen(_add) == false);
     IDC.mint(_add, _amount);
   }
///@notice proxyBurn allows an approved address to burn IdeaCoin
   function proxyIDCBurn(address _add,  uint _amount) external onlyApprovedAdd {
     IDC.burnIDC(_add, _amount);
   }
///@notice proxyMint allows an approved address to mint IdeaCoin
      function proxyCCMint(address _add, uint _amount) external onlyApprovedAdd {
        CC.mint(_add, _amount);
      }
///@notice proxyBurn allows an approved address to burn IdeaCoin
      function proxyCCBurn(address _add,  uint _amount) external onlyApprovedAdd {
        CC.burnCC(_add, _amount);
      }

   function generateIdeaBlock(string _ideaIPFS, uint _globalUseBlockAmount, uint miningTime, uint _royalty, address _inventorsAddress) external onlyApprovedAdd {
     require(_checkIfFrozen(_inventorsAddress) == false);
     CPBG._generateIdeaBlock(_ideaIPFS, _globalUseBlockAmount, miningTime, _royalty, _inventorsAddress);
   }
   function replicationBlock(uint _ideaId, address _repAdd, address _replicatorAdd) external onlyApprovedAdd {
     require(_checkIfFrozen(_replicatorAdd) == false);
     CPBG._replicationBlock( _ideaId, _repAdd, _replicatorAdd);
   }
   function generateGUSBlock(address _replicationOwner) external onlyApprovedAdd {
     require(_checkIfFrozen(_replicationOwner) == false);
   CPBG._generateGUSBlock( _replicationOwner);
 }
function mintItemToken( string _itemIPFSHash) external onlyApprovedAdd {
  PoPT._mintItemToken( _itemIPFSHash);
}

///@notice addMember function is an internal function for adding a member to decentracorp
///@dev addMember takes in an address _mem, sets its membership to true and increments their rank by one
  function _addMember(address _mem) external onlyApprovedAdd {
    require(_checkIfFrozen(_mem) == false);
      members[_mem] = true;
      memberLevel[_mem]++;
      facilityRank[_mem]++;
      memberCount++;
  }
  function _checkIfMember(address _member) public view returns(bool) {
    if(members[_member] == true){
      return true;
    }
  }

  function _checkIfFrozen(address _member) public view returns(bool) {
    if(frozenAccounts[_member] == true){
      return true;
    }
  }

  ///@notice getMemberCount function returns total membercount
  ///@dev getMemberCount is for front end and internal use
    function getMemberCount() public view returns(uint) {
      return memberCount;
    }

    function increaseMemLev(address _add) external onlyApprovedAdd {
      require(_checkIfFrozen(_add) == false);
      memberLevel[_add]++;
    }

    function increaseFacilityRank(address _facAdd, uint _amount) public onlyApprovedAdd {
      require(_checkIfFrozen(_facAdd) == false);
      facilityRank[_facAdd] += _amount;
    }

    function getLevel(address _add) public view returns(uint) {
      return memberLevel[_add];
    }

    function getRank(address _add) public view returns(uint) {
      return facilityRank[_add];
    }

    function setProfileHash(address _add, string _hash) public onlyApprovedAdd {
      require(_checkIfFrozen(_add) == false);
      memberProfileHash[_add] = _hash;
    }

    function getProfileHash(address _add) public view returns(string) {
      return memberProfileHash[_add];
    }
//@notice this function is a quick freeze triggered by the founder used only in emergency situations
// this freeze only lasts for a maximum of two days to limit the founders ability to go rogue


    function decreaseFacilityRank(address _facility, uint _amount) public onlyApprovedAdd {
      facilityRank[_facility] -= _amount;
    }

    function terminateMember(address _member) internal {
      uint balance = IDC.balanceOf(_member);
       IDC.burnIDC(_member, balance);
       members[_member] = false;
       memberLevel[_member] = 0;
       facilityRank[_member] = 0;
       frozenAccounts[_member] = true;
    }

    function getPropID(string hash) public view returns(uint){
      return getHash[hash];
    }

    function getPropCode(string hash) public view returns(uint){
      return propCode[hash];
    }

    function checkIfVoted(address _add, uint _ProposalID) public view returns(bool) {
      Proposal storage p = proposals[_ProposalID];
      return p.voted[_add];
    }

    function postComment(address _member, string _commentsHash) public {
       IDC.burnIDC(msg.sender, 10);
      profileComments[_member] = _commentsHash;
    }
    function getComment(address _member) public view returns(string){
      return profileComments[_member];
    }

 }
