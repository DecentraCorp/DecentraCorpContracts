pragma solidity ^0.5.0;

import './DCD_Confirmation.sol';

contract DC_Depot is DCD_Confirmation {



    function purchase(
      bool _payedInNTC,
      uint _price,
      uint _NTC_Discount,
      string memory _ipfsHash,
      address payable _seller,
      address _facility,
      string memory _itemipfs
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
           DCPoA.proxyNTCBurn(msg.sender, NTC_Discount);
             emit ItemBought( 0, _price, msg.sender);
         }

         createEscrow(_payedInNTC, _price, _seller, _facility, _itemipfs);
         forSale =_ipfsHash;

    }

}
