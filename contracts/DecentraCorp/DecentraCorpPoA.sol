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
contract Notio {
    function mint(address _to, uint256 _value) external;
    function burnNTC(address _from, uint256 _value)  external;
    function balanceOf(address _addr) public constant returns (uint);
}
//Notio interface
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
    function _generateIdeaBlock(string _ideaIPFS, uint _globalUseBlockAmount, uint miningTime, uint _royalty, address _inventorsAddress, address _inventionAdd) external;
    function _replicationBlock(uint _ideaId, address _repAdd, address _replicatorAdd) external;
    function _generateGUSBlock(address _replicationOwner) external;
}
/// CryptoPatentBlockGenerator interface
/////////////////////////////////////////////////////////////////////////////////////////////

 contract DecentraCorpPoA is Ownable {
   using SafeMath for uint256;
///@param NTC is used to make calls to the Notio Contract
   Notio public NTC;
   CryptoPatentBlockGenerator public CPBG;
   ChaosCoin public CC;
   ProofOfPurchaseToken public PoPT;

   uint public memberCount;
   uint public minimumQuorum;
   uint public buyMemWindow;
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
   mapping(address => address) facilityOfMember;
   mapping(address => address[]) facilityMembers;
   mapping(address => bool) CIBvalLVL1;
   mapping(address => bool) CIBvalLVL2;

   Proposal[] public proposals;

   event ProposalCreated(string VoteHash, uint PropCode);
   event Voted(address _voter, bool inSupport);
   event FundingApproved(address addToFund, uint amount);
   event CIBLVL1(address _newVal, address _validatedBy);
   event CIBLVL2(address _newVal, address _validatedBy);
   event NewMember(address _newMem, address newMemFacility, string profHash);

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

   //@modifier requires that the address calling a function is a contract information bridge level 1
   modifier onlyCIB1() {
     require(CIBvalLVL1[msg.sender] == true);
     _;
   }

   //@modifier requires that the address calling a function is a contract information bridge level 2
     modifier onlyCIB2() {
       require(CIBvalLVL2[msg.sender] == true);
       _;
     }

///@notice constructor sets up Notio address through truffle wizardry
   constructor(Notio _NTC, CryptoPatentBlockGenerator _CPBG, ChaosCoin _CC, ProofOfPurchaseToken _PoPT) public {
     NTC=(_NTC);
     CPBG =(_CPBG);
     CC=(_CC);
     PoPT = (_PoPT);
     members[msg.sender] = true;
     memberCount++;
     memberLevel[msg.sender] += 100;
     memberProfileHash[msg.sender] = "QmSu93p6XRanSNmov4e5c8VQPBxKo2zWf1jZpvVTfwi2L9";
     facilityRank[msg.sender] += 100;
     facilityOfMember[msg.sender] = msg.sender;
     founder = msg.sender;
     buyMemWindow = now;
     CIBvalLVL1[msg.sender] = true;
     CIBvalLVL2[msg.sender] = true;
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
                      emit FundingApproved(p.Address, p.Amount);
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

///@notice setNTCadd allows the address of the Notio contract to be updated
   function setNTCadd(address _NTC) public onlyOwner {
     NTC = Notio(_NTC);
   }

///@notice proxyMint allows an approved address to mint Notio
   function proxyNTCMint(address _add, uint _amount) external onlyApprovedAdd {
     require(_checkIfFrozen(_add) == false);
     NTC.mint(_add, _amount);
   }
///@notice proxyBurn allows an approved address to burn Notio
   function proxyNTCBurn(address _add,  uint _amount) external onlyApprovedAdd {
     NTC.burnNTC(_add, _amount);
   }
///@notice proxyMint allows an approved address to mint Notio
      function proxyCCMint(address _add, uint _amount) external onlyApprovedAdd {
        CC.mint(_add, _amount);
      }
///@notice proxyBurn allows an approved address to burn Notio
      function proxyCCBurn(address _add,  uint _amount) external onlyApprovedAdd {
        CC.burnCC(_add, _amount);
      }

   function generateIdeaBlock(string _ideaIPFS, uint _globalUseBlockAmount, uint miningTime, uint _royalty, address _inventorsAddress, address _inventionAdd) external onlyApprovedAdd {
     require(_checkIfFrozen(_inventorsAddress) == false);
     CPBG._generateIdeaBlock(_ideaIPFS, _globalUseBlockAmount, miningTime, _royalty, _inventorsAddress, _inventionAdd);
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
  function _addMember(address _mem, address _facility) external onlyApprovedAdd {
    require(_checkIfFrozen(_mem) == false);
      members[_mem] = true;
      memberLevel[_mem]++;
      facilityMembers[_facility].push(_mem);
      facilityOfMember[_mem] = _facility;
      facilityRank[_facility]++;
      memberCount++;
  }

function getFecilityOfMember(address _mem) public view returns(address) {
  return facilityOfMember[_mem];
}

function getFacilitiesMembers(address _facility) public view returns(address[]) {
  return facilityMembers[_facility];
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

    function increaseFacilityRank(address _mem, uint _amount) public onlyApprovedAdd {
      address _facAdd = getFecilityOfMember(_mem);
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

    function decreaseFacilityRank(address _facility, uint _amount) public onlyApprovedAdd {
      facilityRank[_facility] -= _amount;
    }

    function terminateMember(address _member) internal {
      uint balance = NTC.balanceOf(_member);
       NTC.burnNTC(_member, balance);
       members[_member] = false;
       memberLevel[_member] = 0;
       facilityRank[_member] = 0;
       frozenAccounts[_member] = true;
       memberCount--;
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
       NTC.burnNTC(msg.sender, 10);
      profileComments[_member] = _commentsHash;
    }
    function getComment(address _member) public view returns(string){
      return profileComments[_member];
    }
    ///@notice buyMembership function allows for the purchase of a membership for 6 months after official launch.
    ///@dev mints the user 10,000 NTC
      function buyMembership(address _newMem, address _facility, string _hash) public {
        require(now <= buyMemWindow + 15780000 seconds);
          members[_newMem] = true;
          memberLevel[_newMem]++;
          facilityMembers[_facility].push(_newMem);
          facilityOfMember[_newMem] = _facility;
          facilityRank[_facility]++;
          memberCount++;
          memberProfileHash[_newMem] = _hash;
          NTC.mint(msg.sender, 1000000000000000000000);
        emit NewMember(_newMem, _facility, _hash);
      }

      function addNewCIBval(address _newVal) public onlyCIB2 {
        require(facilityRank[_newVal] >= 50);
        require(NTC.balanceOf(_newVal) >= 1000);
        NTC.burnNTC(_newVal, 1000);
        CIBvalLVL1[_newVal] = true;
        NTC.mint(msg.sender, 100000000000000000000);
        emit CIBLVL1(_newVal, msg.sender);
      }

       function addNewCIBval2(address _newVal) public onlyCIB2{
           require(facilityRank[_newVal] >= 100);
           require(NTC.balanceOf(_newVal) >= 10000);
           NTC.burnNTC(_newVal, 10000);
           CIBvalLVL2[_newVal] = true;
           NTC.mint(msg.sender, 100000000000000000000);
           emit CIBLVL1(_newVal, msg.sender);
       }
 }
