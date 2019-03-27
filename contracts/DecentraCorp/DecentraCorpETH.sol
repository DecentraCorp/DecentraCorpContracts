pragma solidity ^0.4.21;
////////////////////////////////////////////////////////////////////////////////////////////
/// @title DecentraCorpPoA
/// @author DecentraCorp
/// @notice this contract will serve as a bridge between the main ethereum
///   network and the DecntraCorp PoA allowing DecentraCorp to hold ETH
/// @dev All function calls are currently implement without side effects
////////////////////////////////////////////////////////////////////////////////////////////
/// @author Christopher Dixon
/////////////////////////////////////////////////////////////////////////////////////////////
contract DecentraCorpETH  {

///@param NTC is used to make calls to the Notio Contract

  uint public buyMemWindow;
  mapping(address => bool) CIBvalLVL1E;
  mapping(address => bool) CIBvalLVL2E;


  event NewMemberE(address _newMem, address newMemFacility, string profHash);
  event AddressFundedE(address _AddFunded);
  event CIBLVL1E(address _newVal, address _validatedBy);
  event CIBLVL2E(address _newVal, address _validatedBy);
    //@modifier requires that the address calling a function is a contract information bridge level 1
    modifier onlyCIB1E() {
      require(CIBvalLVL1E[msg.sender] == true);
      _;
    }

    //@modifier requires that the address calling a function is a contract information bridge level 2
      modifier onlyCIB2E() {
        require(CIBvalLVL2E[msg.sender] == true);
        _;
      }


  constructor() public {
    buyMemWindow = now;
    CIBvalLVL1E[msg.sender] = true;
    CIBvalLVL2E[msg.sender] = true;
  }



  function buyMembershipE(string _hash, address _facility) public payable{
    require(now <= buyMemWindow + 15780000 seconds);
    require(msg.value >= 1 ether);
    emit NewMemberE(msg.sender, _facility, _hash);
    }

    function sendFunds(address addToFund, uint amount) public onlyCIB2E {
      addToFund.transfer(amount);
      emit AddressFundedE(addToFund);
    }

    function addNewCIBvalE(address _newVal) public onlyCIB2E {
      CIBvalLVL1E[_newVal] = true;
      emit CIBLVL1E(_newVal, msg.sender);
    }

     function addNewCIBval2E(address _newVal) public onlyCIB2E {
         CIBvalLVL2E[_newVal] = true;
         emit CIBLVL1E(_newVal, msg.sender);
     }

}
