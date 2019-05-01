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


  NewRound[] public rounds;

struct NewRound {
  uint NumberOfPlayers;
  uint RoundId;
  uint PoolAmount;
  uint CurrentHighest;
  address CurrentWinner;
  mapping(address => bool) InTheGame;
  mapping(address => string) PlayerHashs;
  mapping(uint => address[])  AnnihilatedPlayers;
}

///@notice constructor sets up Notio address through truffle wizardry
  function initialize() public initializer {
     Ownable.initialize(msg.sender);
   }

  function setCAdd(address _add) public onlyOwner {
    CC = ChaosCasino(_add);
  }


function joinCurrentRound() public {
  if(now >= roundTimer){
    NewRound storage r = rounds[round];
    if(r.CurrentHighest == 0){
      CC.housesCut(r.PoolAmount);
    }

    CC.proxyCCMint(r.CurrentWinner, r.PoolAmount);
    round++;
    roundTimer = now + 600;
  }
 NewRound storage r = rounds[round];
  if(r.NumberOfPlayers++ <= 200){
  CC.proxyCCBurn(msg.sender, 10000000000000000000);
  r.NumberOfPlayers++;
  r.PoolAmount += 9000000000000000000;
  CC.housesCut(1000000000000000000);
  r.InTheGame[msg.sender] = true;
}else{
  NewRound storage n = rounds[round++];
  CC.proxyCCBurn(msg.sender, 10000000000000000000);
  n.NumberOfPlayers++;
  n.PoolAmount += 9000000000000000000;
  CC.housesCut(1000000000000000000);
  n.InTheGame[msg.sender] = true;

}
}

function endGame(string memory _ipfsHash, uint _score) public {
  NewRound storage r = rounds[round];
  require(r.InTheGame[msg.sender]);
  if(_score == r.CurrentHighest){
    r.PlayerHashs[msg.sender] = _ipfsHash;
    r.CurrentHighest = 0;
    r.AnnihilatedPlayers[_score].push(msg.sender);
  }else if(_score > r.CurrentHighest){
    r.CurrentHighest = _score;
    r.CurrentWinner = msg.sender;
    r.PlayerHashs[msg.sender] = _ipfsHash;
  }else{
    r.PlayerHashs[msg.sender] = _ipfsHash;
    r.AnnihilatedPlayers[_score].push(msg.sender);
  }
}






}
/////////////////////////////////////////////////////////////////////////////////////////////
