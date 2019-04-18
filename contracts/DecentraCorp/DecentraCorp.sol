pragma solidity ^0.5.0;
import "openzeppelin-eth/contracts/ownership/Ownable.sol";
import 'openzeppelin-eth/contracts/math/SafeMath.sol';
import "zos-lib/contracts/Initializable.sol";
import "openzeppelin-eth/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-eth/contracts/token/ERC20/ERC20Detailed.sol";
////////////////////////////////////////////////////////////////////////////////////////////
/// @title DecentraCorpPoA
/// @dev All function calls are currently implement without side effects
/// @author Christopher Dixon
////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////
 contract DecentraCorp is Initializable, Ownable, ERC20, ERC20Detailed {
   using SafeMath for uint256;

   uint public memberCount;
   uint public buyMemWindow;
   bool public frozen;
   address public founder;

   mapping (address =>bool) members;
   mapping(address => uint) memberLevel;
   mapping(address => string) memberProfileHash;
///@param approvedContracts is a mappiung of contracts alloud to call function on other
   mapping(address => bool) approvedContracts;
   mapping(string => uint) getHash;
   mapping(string => uint) propCode;
   mapping(address => string) profileComments;
   mapping(address => bool) frozenAccounts;
   mapping(bytes32 => address) passwords;


   Proposal[] public proposals;

   event ProposalCreated(string VoteHash, uint PropCode);
   event Voted(address _voter, bool inSupport);
   event FundingApproved(address addToFund, uint amount);
   event NewMember(address _newMem, address newMemFacility, string profHash);
   event IdeaApproved(string _ideahash);
   event ProfileUpdated(address updatedAccount);
   event IdeaProposed(string IdeaHash);
   event NewMember(address member);

   struct  Proposal {
        address Address;
        uint PropCode;
        uint Amount;
        string voteHash;
        bool executed;
        bool proposalPassed;
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


///@notice constructor sets up Notio address through truffle wizardry
   function initialize() public initializer {
     Ownable.initialize(msg.sender);
     ERC20Detailed.initialize("NotioCoin", "NTC", 18);
     members[msg.sender] = true;
     memberCount = memberCount + 1;
     memberLevel[msg.sender] += 100;
     memberProfileHash[msg.sender] = "QmSu93p6XRanSNmov4e5c8VQPBxKo2zWf1jZpvVTfwi2L9";
     passwords[0x0e46372e12408078737eee1b57870ca6632577bbd32effe3bb4f26f0e51989f9] = msg.sender;
     founder = msg.sender;
     buyMemWindow = now;
     _mint(msg.sender, 1000000000000000000000000);
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


/**
**@notice Proposal Codes are used to fire specific code. each number represents a different action
*** the following are is a list of prop codes and their actions
** 1. Funding Proposal: the address entered is the address receiving funding
** 2. MemberShip Account Freeze Proposal: the address entered is the address to be frozen
** 3. Membership Termination Proposal: the address entered is the address to be terminated
//more options will be added to allow for contract upgrades in the future
*/
   function createProposal(address _address, uint _propCode, string memory _voteHash, uint _amount) public {
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
          memberLevel[msg.sender]++;
          emit Voted(msg.sender, supportsProposal);
          bool tally = set_Quorum(voteID, memberCount);
          if(tally == true) {
            executeVote(_ProposalID);
          }
          return voteID;
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

///@notice proxyMint allows an approved address to mint Notio
   function proxyNTCMint(address _add, uint _amount) external onlyApprovedAdd {
     require(_checkIfFrozen(_add) == false);
     _mint(_add, _amount);
   }
///@notice proxyBurn allows an approved address to burn Notio
   function proxyNTCBurn(address _add,  uint _amount) external onlyApprovedAdd {
     _burn(_add, _amount);
   }


///@notice addMember function is an internal function for adding a member to decentracorp
///@dev addMember takes in an address _mem, sets its membership to true and increments their rank by one
  function _addMember(address _mem, string calldata _userId) external onlyApprovedAdd {
      require(_checkIfFrozen(_mem) == false);
      members[_mem] = true;
      memberLevel[_mem]++;
      memberCount = memberCount + 1;
      passwords[keccak256(abi.encodePacked(_userId))] = _mem;
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

    function increaseMemLevel(address _add) internal {
      require(_checkIfFrozen(_add) == false);
      memberLevel[_add]++;
    }

    function getLevel(address _add) public view returns(uint) {
      return memberLevel[_add];
    }

    function getProfileHash(address _add) public view returns(string memory) {
      return memberProfileHash[_add];
    }

    function terminateMember(address _member) internal {
      uint balance = balanceOf(_member);
       _burnFrom(_member, balance);
       members[_member] = false;
       memberLevel[_member] = 0;
       frozenAccounts[_member] = true;
       memberCount = memberCount - 1;
    }

    function getPropID(string memory hash) public view returns(uint){
      return getHash[hash];
    }

    function getPropCode(string memory hash) public view returns(uint){
      return propCode[hash];
    }

    function checkIfVoted(address _add, uint _ProposalID) public view returns(bool) {
      Proposal storage p = proposals[_ProposalID];
      return p.voted[_add];
    }

    function postComment(address _member, string memory _commentsHash) public {
       _burnFrom(msg.sender, 10);
      profileComments[_member] = _commentsHash;
    }

    function getComment(address _member) public view returns(string memory){
      return profileComments[_member];
    }
    ///@notice buyMembership function allows for the purchase of a membership for 6 months after official launch.
    ///@dev mints the user 10,000 DCPoA
      function buyMembership(address _newMem, address _facility, string memory _hash, string memory _userId) public {
        require(_checkIfFrozen(_newMem) == false);
        require(now <= buyMemWindow + 15780000 seconds);
          members[_newMem] = true;
          memberLevel[_newMem]++;
          memberCount = memberCount + 1;
          memberProfileHash[_newMem] = _hash;
          passwords[keccak256(abi.encodePacked(_userId))] = _newMem;
          _mint(msg.sender, 1000000000000000000000);
        emit NewMember(_newMem, _facility, _hash);
      }

      function updateProfile(string memory _newHash) public {
            memberProfileHash[msg.sender] = _newHash;
          emit ProfileUpdated(msg.sender);
      }

      function getAddFromPass(string memory _userId) public view returns(address) {
        return passwords[keccak256(abi.encodePacked(_userId))];
      }
 }
