pragma solidity ^0.5.0;

import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Detailed.sol";
////////////////////////////////////////////////////////////////////////////////////////////
/// @title DecentraCorp
/// @dev All function calls are currently implement without side effects
/// @author Christopher Dixon
////////////////////////////////////////////////////////////////////////////////////////////
contract DecentraDollar is Initializable, Ownable, ERC20, ERC20Detailed {



  ///@notice constructor sets up DecentraDollar address through truffle wizardry
     function initialize() public initializer {
       Ownable.initialize(msg.sender);
       ERC20Detailed.initialize("DecentraDollar", "DCD", 18);
     }

     function _MintDecentraDollar(address _to, uint _amount) public onlyOwner {
       _mint(_to, _amount);
     }

     function _BurnDecentraDollar(address _from, uint _amount) public onlyOwner {
         _burn(_from, _amount);
     }


}
