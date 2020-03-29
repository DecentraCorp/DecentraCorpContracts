pragma solidity ^0.5.0;
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import '@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol';
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/ERC20Detailed.sol";
////////////////////////////////////////////////////////////////////////////////////////////
/// @title ChaosCasino
/// @author DecentraCorp
/// @notice this contract is used in conjunction with the CryptoPatent Blockchain
/// @dev All function calls are currently implement without side effects
////////////////////////////////////////////////////////////////////////////////////////////
/// @author Christopher Dixon

contract CryptoPatentBlockchain {
  function checkIfRep(address _add) external returns(bool);
}
//CryptoPatentBlockchain interface
/////////////////////////////////////////////////////////////////////////////////////////////
contract DecentraCorp {
  function proxyNTCMint(address _add, uint _amount) external;
  function proxyNTCBurn(address _add, uint _amount) external;
}
/// DecentraCorp PoA inteface
/////////////////////////////////////////////////////////////////////////////////////////////


contract ChaosCasino is Initializable, Ownable, ERC20, ERC20Detailed {

  using SafeMath for uint256;

///@params below are used to import the contracts as usable objects
  DecentraCorp public DCPoA;
  CryptoPatentBlockchain public CPB;
///@param randNum is set by ChaosMiners, preset for testing
  uint public randNum;
  address public dcAdd;
  mapping(address => bool) approvedGameContracts;

///@notice modifier requires that the address calling a function is a replication
///@dev this imports function from replication block generator
  modifier onlyReplication() {
    require(CPB.checkIfRep(msg.sender));
    _;
  }

  modifier onlyApprovedAdd() {
    require(approvedGameContracts[msg.sender]);
    _;
  }
  ///@notice constructor sets up DecentraDollar address through truffle wizardry
  function initialize() public initializer {
   Ownable.initialize(msg.sender);
   ERC20Detailed.initialize("ChaosCoin", "CCC", 18);
   randNum = 8675309;
  }

///@notice folowing three function allow for contract upgrades
  function setCPBAdd(address _add) public onlyOwner {
    CPB = CryptoPatentBlockchain(_add);
  }

  ///@notice folowing three function allow for contract upgrades
  function setDCPoAAdd(address _add) public onlyOwner {
    DCPoA = DecentraCorp(_add);
    dcAdd = _add;
  }

///@notice setRandomNum allows a replication to set a random number in the ChaosCasino
  function setRandomNum(uint _randNum) public onlyReplication {
      randNum = _randNum;
  }

///@notice getRandomNum is used by the front end to get a random Number
  function getRandomNum() public view returns(uint) {
      return randNum;
  }

  function addApprovedGame(address _newGame) public onlyOwner {
    approvedGameContracts[_newGame] = true;
  }
  ///@notice proxyMint allows an approved address to mint DecentraDollar
 function proxyCCMint(address _add, uint _amount) external onlyApprovedAdd {
   _mint(_add, _amount);
 }
  ///@notice proxyBurn allows an approved address to burn DecentraDollar
 function proxyCCBurn(address _add,  uint _amount) external onlyApprovedAdd {
   _burn(_add, _amount);
 }

 function housesCut(uint _amount) external onlyApprovedAdd {
   DCPoA.proxyNTCMint(dcAdd, _amount);
 }
///@notice buyChaosCoin allows anyone to exchange ether for ChaosCoin
  function buyChaosCoin(uint _amount) public {
    DCPoA.proxyNTCBurn(msg.sender, _amount);
    uint _amountCC = _amount.mul(1000);
    _mint(msg.sender, _amountCC);
  }

///@notice cahsOut allows ChaosCoin to be cashed out into ether
  function cashOut(uint _amount) public {
    require(balanceOf(msg.sender) >= _amount);
    _burn(msg.sender, _amount);
    uint amount = _amount.div(1000);
    DCPoA.proxyNTCMint(msg.sender, amount);
  }


}
/////////////////////////////////////////////////////////////////////////////////////////////
