pragma solidity ^0.4.24;
import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
/////////////////////////////////////////////////////////////////////////////////////////////
/// @title Notio Contract
/// @author DecentraCorp
/// @notice this contract is built from contracts from the zeppelin-solidity library
/// @dev All function calls are currently implement without side effects
contract Notio is MintableToken {
  /// @author Christopher Dixon
  /// @notice constructor is run only once when the contract is deployed
  /// @dev sets total supply to 1 million Notio and transfers is to msg.sender
  constructor() public {
    totalSupply_ = 1000000000000000000000000;
    balances[msg.sender] = totalSupply_;
  }
  ///@param name, symbol, decimals set ERC20 compatable names and conventions
  string public constant name = "Notio";
  string public constant symbol = "NTC";
  uint8 public constant decimals = 18;

  function burnNTC(address _from, uint256 _value) external onlyOwner {
    balances[_from] = balances[_from] - _value;
    totalSupply_ = totalSupply_ - _value;
  }
}
