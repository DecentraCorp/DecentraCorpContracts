pragma solidity ^0.5.0;

import './DCD_Escrow.sol';

contract DCD_Confirmation is DCD_Escrow  {

function ConfirmItemReciept(uint _escrowId,   string memory _itemIPFSHash) public  {
  require(DCPoA.getLevel(msg.sender) >= 100);
  require(approvedProcessingFacility[msg.sender] == true);

Escrow memory escrow = itemInEscrow[_escrowId];


  bool _payedInNTC = escrow.PayedInNTC;
  address payable _buyer = escrow.buyer;
  address payable _seller = escrow.seller;
  uint _price = escrow.Price;
  address _facility = escrow.facility;
  uint _NTCSellerMultiplier = PoPTokens[_seller];
  uint _NTCBuyerMultiplier = PoPTokens[_buyer];

  require(msg.sender == _facility);
if(_NTCSellerMultiplier == 0) {
    _NTCSellerMultiplier = 1;
}
if(_NTCBuyerMultiplier == 0) {
    _NTCBuyerMultiplier = 1;
}

_NTCSellerMultiplier = _NTCSellerMultiplier * 5000000000000000000;
_NTCBuyerMultiplier = _NTCBuyerMultiplier * 5000000000000000000;

if(!_payedInNTC) {
  _seller.transfer(_price);
} else {
  DCPoA.proxyNTCMint(_seller, _price);
}

  _mintItemToken(_itemIPFSHash);
  PoPTokens[_seller]++;
  PoPTokens[_buyer]++;
  DCPoA.proxyNTCMint(_buyer, _NTCBuyerMultiplier);
  DCPoA.proxyNTCMint(_seller, _NTCSellerMultiplier);
  DCPoA.proxyNTCMint(msg.sender, 10000000000000000000);

}

function releaseFundsBackToBuyer(uint _escrowId) public  {
  require(DCPoA.getLevel(msg.sender) >= 100);
  require(approvedProcessingFacility[msg.sender] == true);

  Escrow memory escrow = itemInEscrow[ _escrowId];
  bool _payedInNTC = escrow.PayedInNTC;
  address payable _buyer = escrow.buyer;
    uint _price = escrow.Price;
    if(!_payedInNTC) {
      _buyer.transfer(_price);
    } else {
      DCPoA.proxyNTCMint(_buyer, _price);
    }
    DCPoA.proxyNTCMint(msg.sender, 10000000000000000000);
  }

}
