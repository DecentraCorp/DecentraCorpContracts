pragma solidity ^0.4.21;

import './DCD_Escrow.sol';

contract DCD_Confirmation is DCD_Escrow  {

function ConfirmItemReciept(uint _escrowId,   string _itemIPFSHash) public  {
  require(decentraCorp.getRank(msg.sender) >= 100);
  require(decentraCorp.getLevel(msg.sender) >= 100);
  require(approvedProcessingFacility[msg.sender] == true);

Escrow memory escrow = itemInEscrow[_escrowId];


  bool _payedInNTC = escrow.PayedInNTC;
  address _buyer = escrow.buyer;
  address _seller = escrow.seller;
  uint _price = escrow.Price;
  address _facility = escrow.facility;
  uint _NTCSellerMultiplier = PoPT.balanceOf(_seller);
  uint _NTCBuyerMultiplier = PoPT.balanceOf(_buyer);

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
  decentraCorp.proxyNTCMint(_seller, _price);
}

  decentraCorp.mintItemToken(_itemIPFSHash);
  uint _tokenId = PoPT.ipfsLookUp(_itemIPFSHash);
  PoPT.safeTransferFrom(this, _buyer, _tokenId);
  decentraCorp.proxyNTCMint(_buyer, _NTCBuyerMultiplier);
  decentraCorp.proxyNTCMint(_seller, _NTCSellerMultiplier);
  decentraCorp.proxyNTCMint(msg.sender, 10000000000000000000);

}

function releaseFundsBackToBuyer(uint _escrowId) public  {
  require(decentraCorp.getRank(msg.sender) >= 100);
  require(decentraCorp.getLevel(msg.sender) >= 100);
  require(approvedProcessingFacility[msg.sender] == true);

  Escrow memory escrow = itemInEscrow[ _escrowId];
  bool _payedInNTC = escrow.PayedInNTC;
  address _buyer = escrow.buyer;
    uint _price = escrow.Price;
    if(!_payedInNTC) {
      _buyer.transfer(_price);
    } else {
      decentraCorp.proxyNTCMint(_buyer, _price);
    }
    decentraCorp.proxyNTCMint(msg.sender, 10000000000000000000);
  }

}
