pragma solidity ^0.5.0;
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "./utils/BancorFormulaI.sol";

////////////////////////////////////////////////////////////////////////////////////////////
/**
@title DCBase
@dev All function calls are currently implement without side effects
@author Christopher Dixon

The DCBase contract serves as the base logic contract for the DecentraCorp Contract Set
**/
////////////////////////////////////////////////////////////////////////////////////////////
contract DecentraDollar is IERC20 {
   function _MintDecentraDollar(address _to, uint _amount) public;
   function _BurnDecentraDollar(address _from, uint _amount) public;
}
////////////////////////////////////////////////////////////////////////////////////////////
contract DecentraStock is IERC20 {
   function _IssueDecentraStock(address _to, uint _amount) public;
   function _BurnDecentraStock(address _from, uint _amount) public;
}

////////////////////////////////////////////////////////////////////////////////////////////
 contract DCBase is Initializable, Ownable {
   using SafeMath for uint256;

/**
@param
@param frozen is a bool representing whether of not the DAO has been frozen
@dev frozen is only to be used in an emergency
**/


   bool public frozen;
   uint256 public approvedContracts;

   mapping(uint256 => address) contractNumber;

/**
@param DCD instantiates the DecentraDollar contract as a useable variable within the DecentraCorp Contracts
@param DS instantiates the DecentraStock contract as a useable variable within the DecentraCorp Contracts
**/

   DecentraDollar public DD;
   DecentraStock public DS;
   BancorFormulaI public bancor;




/**
@notice notForzen requires DecentraCorp not to be frozen
**/

modifier notForzen() {
  require(frozen == false);
  _;
}

  function addNewToken(address _contract) public onlyOwner {
    approvedContracts++;
    contractNumber[approvedContracts] = _contract;
  }

  function removeContract(uint256 _contractNum) public onlyOwner {
    contractNumber[_contractNum] = address(this);
  }


///@notice proxyMint allows an approved address to mint DecentraDollar
         function proxyDDMint(address _add, uint _amount) internal notForzen {
           DD._MintDecentraDollar(_add, _amount);
         }
///@notice proxyBurn allows an approved address to burn DecentraDollar
         function proxyDDBurn(address _add,  uint _amount) internal notForzen {
           DD._BurnDecentraDollar(_add, _amount);
         }

///@notice proxyMint allows an approved address to mint DecentraStockC
         function proxyDSMint(address _add, uint _amount) internal notForzen {
           DS._IssueDecentraStock(_add, _amount);
         }
///@notice proxyBurn allows an approved address to burn DecentraStockC
         function proxyDSBurn(address _add,  uint _amount) internal notForzen {
           DS._BurnDecentraStock(_add, _amount);
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
