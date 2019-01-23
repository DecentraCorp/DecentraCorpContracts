pragma solidity ^0.4.21;

import './DCD_Confirmation.sol';

contract DC_Depot is DCD_Confirmation {

  constructor(ProofOfPurchaseToken _pop, IdeaCoin _idc, DecentraCorpPoA _DC) public  {
      PoPT = (_pop);
      IDC = (_idc);
      decentraCorp = (_DC);
  }

    function purchase(
      bool _payedInIDC,
      uint _price,
      uint _IDC_Discount,
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
         uint IDC_Discount = _price - _IDC_Discount;

      
         if(msg.value >= totalPrice) {
           etherEarned += DCDfee;
             emit ItemBought( _price, 0, msg.sender);
         } else {
           decentraCorp.proxyIDCBurn(msg.sender, IDC_Discount);
             emit ItemBought( 0, _price, msg.sender);
         }

         createEscrow(_payedInIDC, _price, _seller, _facility, _itemipfs);
         forSale =_ipfsHash;

    }

}
