pragma solidity ^0.5.0;

import "./DecentraControlled.sol";


contract DCD_Escrow is DecentraControlled {

event ItemBought(
  uint pricePayedEther,
  uint pricePayedNTC,
  address buyer
  );


struct Escrow {
  bool PayedInNTC;
  uint Price;
  address payable buyer;
  address payable seller;
  address facility;
  string ItemIPFS;
  }

  mapping (uint => Escrow) public itemInEscrow;

function createEscrow(
  bool _payedInNTC,
  uint _price,
  address payable _seller,
  address _facility,
  string memory _itemipfs
  )
  internal
  {
  address payable _buyer = msg.sender;

    Escrow memory _escrow = Escrow({
       PayedInNTC: bool(_payedInNTC),
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
