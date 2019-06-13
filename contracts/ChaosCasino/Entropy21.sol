pragma solidity ^0.5.0;
import "zos-lib/contracts/Initializable.sol";
import "openzeppelin-eth/contracts/ownership/Ownable.sol";
import 'openzeppelin-eth/contracts/math/SafeMath.sol';
import './ChaosCasino.sol';


contract Entropy21 is Initializable, Ownable {

  using SafeMath for uint256;
///@params below are used to import the contracts as usable objects
  ChaosCasino public CC;


  uint public round;
  uint public roundTimer;
  mapping(uint => NewRound) public rounds;
  mapping(address => bool) inTheGame;
  mapping(address => string) playerHashs;

struct NewRound {
  uint NumberOfPlayers;
  uint PoolAmount;
  uint CurrentHighest;
  address CurrentWinner;
}

///@notice constructor sets up Notio address through truffle wizardry
  function initialize() public initializer {
     Ownable.initialize(msg.sender);
     round++;
     roundTimer = now.add(600);
   }

  function setCAdd(address _add) public onlyOwner {
    CC = ChaosCasino(_add);
  }


function joinCurrentRound() public {
  uint roundId = round;
  NewRound storage r = rounds[roundId];

  if(now >= roundTimer && r.NumberOfPlayers >= 2 ){
    CC.proxyCCMint(r.CurrentWinner, r.PoolAmount);
    round++;
    roundTimer = now.add(600);
  }

  CC.proxyCCBurn(msg.sender, 10000000000000000000);
  r.NumberOfPlayers++;
  r.PoolAmount += 9000000000000000000;
  CC.housesCut(1000000000000000000);
  inTheGame[msg.sender] = true;
}


function endGame(string memory _ipfsHash, uint _score) public {
    uint roundId = round;
  NewRound storage r = rounds[roundId];

  require(inTheGame[msg.sender]);

  if(_score == r.CurrentHighest){
    playerHashs[msg.sender] = _ipfsHash;
    r.CurrentHighest = 0;
  }else if(_score > r.CurrentHighest){
    r.CurrentHighest = _score;
    r.CurrentWinner = msg.sender;
    playerHashs[msg.sender] = _ipfsHash;
  }else{
    playerHashs[msg.sender] = _ipfsHash;
  }

  inTheGame[msg.sender] = false;
}


function timeLeft() public view returns(uint) {
  return roundTimer - now;
}



}
/////////////////////////////////////////////////////////////////////////////////////////////
