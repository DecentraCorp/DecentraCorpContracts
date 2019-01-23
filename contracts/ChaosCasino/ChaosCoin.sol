pragma solidity ^0.4.24;
import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
////////////////////////////////////////////////////////////////////////////////////////////
/// @title ChaosCoin Contract for the ChaosCasino
/// @author DecentraCorp
/// @notice this contract is intended to be used as in-game currency for the ChaosCasino
/// @dev All function calls are currently implement without side effects
////////////////////////////////////////////////////////////////////////////////////////////
/// @author Christopher Dixon
/// @notice This contract is built using the mintable and burnable token contracts from the Open-Zepplin library
contract ChaosCoin is MintableToken{
///@param name sets the tokens name
///@param symbol sets the tokens symbol
///@param sets the number of decimals for a token
  string public constant name = "ChaosCoin";
  string public constant symbol = "CCC";
  uint8 public constant decimals = 18;

  function burnCC(address _from, uint256 _value) external onlyOwner {
    balances[_from] = balances[_from] - _value;
    totalSupply_ = totalSupply_ - _value;
  }
}
