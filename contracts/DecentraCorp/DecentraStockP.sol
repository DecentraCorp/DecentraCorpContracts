pragma solidity ^0.5.0;

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import '@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol';
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Detailed.sol";

contract DecentraStockP is Initializable, Ownable, ERC20, ERC20Detailed  {



    ///@notice constructor sets up DecentraDollar address through truffle wizardry
       function initialize() public initializer {
         Ownable.initialize(msg.sender);
         ERC20Detailed.initialize("DecentraStockP", "DSP", 18);
       }

       function _IssueDecentraStockP(address _to, uint _amount) onlyOwner {
         _mint(_to, _amount);
       }

       function _BurnDecentraStockP(address _from, uint _amount) onlyOwner {
           _burn(_from, _amount);
       }

}
