pragma solidity ^0.4.21;

import './DCD_Confirmation.sol';

contract DC_Depot is DCD_Confirmation {

  constructor(ProofOfPurchaseToken _pop, Notio _NTC, DecentraCorpPoA _DC) public  {
      PoPT = (_pop);
      NTC = (_NTC);
      decentraCorp = (_DC);
  }

    function purchase(
      bool _payedInNTC,
      uint _price,
      uint _NTC_Discount,
      string _ipfsHash,
      address _seller,
      address _facility,
      string _itemipfs
      )
       public
       payable
       {

         uint DCDfee = .001 ether;
         uint totalPrice = _price + DCDfee;
         uint NTC_Discount = _price - _NTC_Discount;


         if(msg.value >= totalPrice) {
           etherEarned += DCDfee;
             emit ItemBought( _price, 0, msg.sender);
         } else {
           decentraCorp.proxyNTCBurn(msg.sender, NTC_Discount);
             emit ItemBought( 0, _price, msg.sender);
         }

         createEscrow(_payedInNTC, _price, _seller, _facility, _itemipfs);
         forSale =_ipfsHash;

    }

}
