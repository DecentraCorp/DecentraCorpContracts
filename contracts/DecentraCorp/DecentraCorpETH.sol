pragma solidity ^0.4.21;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";

////////////////////////////////////////////////////////////////////////////////////////////
/// @title DecentraCorpPoA
/// @author DecentraCorp
/// @notice this contract will serve as an information portal between the main ethereum
///   network and the CryptoPatent Blockchain
/// @dev All function calls are currently implement without side effects
////////////////////////////////////////////////////////////////////////////////////////////
/// @author Christopher Dixon
////////////////////////////////////////////////////////////////////////////////////////////
contract IdeaCoinETH {
    function mint(address _to, uint256 _value) external;
}
//IdeaCoin interface
/////////////////////////////////////////////////////////////////////////////////////////////
contract DecentraCorpETH is Ownable {
  using SafeMath for uint256;
///@param IDC is used to make calls to the IdeaCoin Contract
  IdeaCoinETH public IDC;

  uint public buyMemWindow;
  address public CrossChainInfoBridge;

  event NewMember(address _newMem, address newMemFacility, string profHash);

  //@modifier requires that the address calling a function is a member of DecentraCorp
    modifier onlyCIB() {
      require(msg.sender == CrossChainInfoBridge);
      _;
    }


  constructor(IdeaCoinETH _IDC) {
    IDC=(_IDC);
    buyMemWindow = now;
  }

  function setCIB(address _CIB) public onlyOwner {
  CrossChainInfoBridge = _CIB;
  }

  function buyMembership(string _hash, address _facility) public payable{
    require(now <= buyMemWindow + 15780000 seconds);
    require(msg.value >= 1 ether);
    IDC.mint(msg.sender, 1000000000000000000000);
    emit NewMember(msg.sender, _facility, _hash);
    }

    function sendFunds(address addToFund, uint amount) public onlyCIB {
      addToFund.transfer(amount);
    }

}
