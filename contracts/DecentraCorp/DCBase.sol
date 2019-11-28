pragma solidity ^0.5.0;
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import '@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol';
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "./DecentraDollar.sol";
import "./DecentraStockC.sol";
import "./DecentraStockP.sol";
////////////////////////////////////////////////////////////////////////////////////////////
/// @title DecentraCorp
/// @dev All function calls are currently implement without side effects
/// @author Christopher Dixon
////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////
 contract DCBase is Initializable, Ownable{
   using SafeMath for uint256;

   address public founder;
   uint public memberCount;
   bool public frozen;

   RelayedOwnedSet public Validators;
   DecentraDollar public DCD;
   DecentraStockC public DSC;
   DecentraStockP public DSP;

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



   function initialize(address _valCon, address _DCD, address _DSC, address _DSP) public initializer {
     Ownable.initialize(msg.sender);
     Validators = RelayedOwnedSet(_valCon);
     DCD = _DCD;
     DSC = _DSC;
     DSP = _DSP;

   }


      function setFounder(address _add, string memory _userID) public onlyOwner {
        userIDs[keccak256(abi.encodePacked(_userID))] = _add;
        members[_add] = true;
        memberCount = memberCount + 1;
        memberLevel[_add] += 36;
        memberProfileHash[_add] = "Qma6SaoazBAsDs6XqojWFw3LCqXtopaPoxd5FFknPWeHrr";
        founder = _add;
         DCD._MintDecentraDollar(_add, 10000000000000000000000);
      }

      //@addApprovedContract allows another contract to call functions
      ///@dev adds contract to list of approved calling contracts
        function addApprovedContract(address _newContract) public onlyOwner {
              approvedContracts[_newContract] = true;
            }

      ///@notice proxyMint allows an approved address to mint DecentraDollar
         function proxyDCDMint(address _add, uint _amount) external onlyApprovedAdd {
           require(_checkIfFrozen(_add) == false);
           DCD._MintDecentraDollar(_add, _amount);
         }
      ///@notice proxyBurn allows an approved address to burn DecentraDollar
         function proxyDCDBurn(address _add,  uint _amount) external onlyApprovedAdd {
           DCD._BurnDecentraDollar(_add, _amount);
         }

      ///@notice proxyMint allows an approved address to mint DecentraStockC
         function proxyDSCMint(address _add, uint _amount) external onlyApprovedAdd {
           require(_checkIfFrozen(_add) == false);
           DSC._IssueDecentraStockC(_add, _amount);
         }
      ///@notice proxyBurn allows an approved address to burn DecentraStockC
         function proxyDSCBurn(address _add,  uint _amount) external onlyApprovedAdd {
           DSC._BurnDecentraStockC(_add, _amount);
         }

    ///@notice proxyMint allows an approved address to mint DecentraStockP
         function proxyDSPMint(address _add, uint _amount) external onlyApprovedAdd {
           require(_checkIfFrozen(_add) == false);
           DSP._IssueDecentraStockP(_add, _amount);
         }
      ///@notice proxyBurn allows an approved address to burn DecentraStockP
         function proxyDSPBurn(address _add,  uint _amount) external onlyApprovedAdd {
           DSP._BurnDecentraStockP(_add, _amount);
         }

         function addValidatorProxy(address _newVal) external onlyApprovedAdd {
           Validators.addValidator(_newVal);
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
              return DCD.balanceOf(address(this));
            }




       }
