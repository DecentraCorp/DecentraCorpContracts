pragma solidity ^0.5.0;
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import '@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol';
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Detailed.sol";
////////////////////////////////////////////////////////////////////////////////////////////
/// @title DecentraCorp
/// @dev All function calls are currently implement without side effects
/// @author Christopher Dixon
////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////
 contract DCBase is Initializable, Ownable, ERC20, ERC20Detailed {
   using SafeMath for uint256;

   address public founder;
   uint public memberCount;
   bool public frozen;


   mapping(address => string) profileComments;
   mapping(address => bool) frozenAccounts;
   mapping(address => bool) approvedContracts;
   mapping(bytes32 => address) userIDs;
   mapping(address =>bool) members;
   mapping(address => uint) memberLevel;
   mapping(address => string) memberProfileHash;



   modifier onlyApprovedAdd() {
     require(approvedContracts[msg.sender] == true);
     _;
   }


///@notice constructor sets up NotioCoin address through truffle wizardry
   function initialize() public initializer {
     Ownable.initialize(msg.sender);
     ERC20Detailed.initialize("NotioCoin", "NTC", 18);
   }


      function setFounder(address _add, string memory _userID) public onlyOwner {
        userIDs[keccak256(abi.encodePacked(_userID))] = _add;
        members[_add] = true;
        memberCount = memberCount + 1;
        memberLevel[_add] += 100;
        memberProfileHash[_add] = "Qma6SaoazBAsDs6XqojWFw3LCqXtopaPoxd5FFknPWeHrr";
        founder = _add;
         _mint(_add, 1000000000000000000000000);
      }

      //@addApprovedContract allows another contract to call functions
      ///@dev adds contract to list of approved calling contracts
        function addApprovedContract(address _newContract) public onlyOwner {
              approvedContracts[_newContract] = true;
            }

      ///@notice proxyMint allows an approved address to mint NotioCoin
         function proxyNTCMint(address _add, uint _amount) external onlyApprovedAdd {
           require(_checkIfFrozen(_add) == false);
           _mint(_add, _amount);
         }
      ///@notice proxyBurn allows an approved address to burn NotioCoin
         function proxyNTCBurn(address _add,  uint _amount) external onlyApprovedAdd {
           _burn(_add, _amount);
         }

         function _checkIfFrozen(address _member) public view returns(bool) {
           if(frozenAccounts[_member] == true){
             return true;
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

            function getDCbalance() public view returns(uint) {
              return balanceOf(address(this));
            }

  


       }
