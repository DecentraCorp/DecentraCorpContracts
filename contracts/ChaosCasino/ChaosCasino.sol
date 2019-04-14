pragma solidity ^0.5.0;
import "zos-lib/contracts/Initializable.sol";
import "openzeppelin-eth/contracts/ownership/Ownable.sol";
import 'openzeppelin-eth/contracts/math/SafeMath.sol';
import "openzeppelin-eth/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-eth/contracts/token/ERC20/ERC20Detailed.sol";
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


contract ChaosCasino is Initializable, Ownable, ERC20, ERC20Detailed {

  using SafeMath for uint256;
///@params below are used to import the contracts as usable objects

  CryptoPatentBlockchain public CPB;
///@param randNum is set by ChaosMiners, preset for testing
  uint randNum;
///@param bets stores the bets of an address
///@dev this will need to be updated for multiple games
  mapping(address => uint) bets;
///@param _number is used by front end games and Chaos Miners
  event RandomNumberSet(uint _number);


///@notice modifier requires that the address calling a function is a replication
///@dev this imports function from replication block generator
  modifier onlyReplication() {
    require(CPB.checkIfRep(msg.sender) == true);
    _;
  }

  ///@notice constructor sets up Notio address through truffle wizardry
     function initialize() public initializer {
     Ownable.initialize(msg.sender);
     ERC20Detailed.initialize("ChaosCoin", "CCC", 18);
     randNum = 8675309;
     }



///@notice folowing three function allow for contract upgrades
  function setCPBAdd(address _add) public onlyOwner {
    CPB = CryptoPatentBlockchain(_add);
  }

///@notice buyChaosCoin allows anyone to exchange ether for ChaosCoin
  function buyChaosCoin() public payable {
    uint amount = msg.value;
    uint _amount = amount.mul(1000);
    _mint(msg.sender, _amount);
  }

///@notice cahsOut allows ChaosCoin to be cashed out into ether
  function cashOut(uint _amount) public {
    require(balanceOf(msg.sender) >= _amount);
    _burnFrom(msg.sender, _amount);
    uint amount = _amount.div(1000);
    msg.sender.transfer(amount);
  }

///@notice setRandomNum allows a replication to set a random number in the ChaosCasino
  function setRandomNum(uint _randNum) external onlyReplication {
      randNum = _randNum;
      emit RandomNumberSet(randNum);
  }

///@notice getRandomNum is used by the front end to get a random Number
  function getRandomNum() public view returns(uint) {
      return randNum;
  }

///@notice placeBet Allows a User to place a bet
  function placeBet(uint _bet) public {
    require(balanceOf(msg.sender) >= _bet);
    _burnFrom(msg.sender, _bet);
    bets[msg.sender] = _bet;
  }

///@notice updateUserBalance allows a front end game to update a users balance
///@dev this function will need to change, or the chaos casino,s front end structure will
  function updateUserBalance( bool _won) public {
    uint currentBalance = bets[msg.sender];
    if(_won == true){
      _mint(msg.sender, currentBalance * 2);
    }else{
      bets[msg.sender] = 0;
    }
  }

}
/////////////////////////////////////////////////////////////////////////////////////////////
