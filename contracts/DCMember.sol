pragma solidity ^0.5.0;

import './DCBank.sol';
////////////////////////////////////////////////////////////////////////////////////////////
/**
@title DecentraCorp
@dev All function calls are currently implement without side effects
@author Christopher Dixon

The DCMember contract handles membership related functions for the DecentraCorp Contracts
**/
////////////////////////////////////////////////////////////////////////////////////////////
 contract DCMember is DCBank {
uint public minimumPrice;
uint public memberCount;

mapping(address => bool) isMember;

event NewMember(address _newMem);

   modifier onlyMember() {
     require(isMember[msg.sender]);
     _;
   }

  function _checkIfMember(address _member) public view returns(bool) {
    if(isMember[_member]){
      return true;
    }
  }


      function buyMembership() public {
        uint256 ts = DS.totalSupply();
        uint membershipPrice = bancor.calculateSaleReturn(ts, DecentraEarnings, 500000, minimumPrice);
        proxyDDBurn(address(this), membershipPrice);
        DecentraEarnings = DecentraEarnings.add(membershipPrice);
        memberCount++;
        isMember[msg.sender] = true;
        emit NewMember(msg.sender);
      }


function setPrice(uint _amount) internal {
  minimumPrice = _amount;
}

function addMember(address _newMem) internal {
  memberCount++;
  isMember[_newMem] = true;
}


}
