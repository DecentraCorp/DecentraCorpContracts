pragma solidity ^0.4.21;

import "./DecentraControlled.sol";


contract DCD_Escrow is DecentraControlled {

event ItemBought(
  uint pricePayedEther,
  uint pricePayedIDC,
  address buyer
  );


struct Escrow {
  bool PayedInIDC;
  uint Price;
  address buyer;
  address seller;
  address facility;
  string ItemIPFS;
  }

  mapping (uint => Escrow) public itemInEscrow;

function createEscrow(
  bool _payedInIDC,
  uint _price,
  address _seller,
  address _facility,
  string _itemipfs
  )
  internal
  {
  address _buyer = msg.sender;

    Escrow memory _escrow = Escrow({
       PayedInIDC: bool(_payedInIDC),
       Price: uint(_price),
       buyer: address(_buyer),
       seller: address(_seller),
       facility: address(_facility),
       ItemIPFS: string(_itemipfs)
      });

globalEscrowCount++;
itemInEscrow[globalEscrowCount] = _escrow;
emit ItemInEscrow(globalEscrowCount, _facility, _itemipfs);
  }

}
