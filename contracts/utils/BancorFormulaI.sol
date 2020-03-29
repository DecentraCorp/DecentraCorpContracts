pragma solidity ^0.5.0;

contract BancorFormulaI {
/**
@notice calculatePurchaseReturn is used to calculate the exchange rate from ether to an instances MeToken given the input parameters
@dev this function is apart of the Bancor Formula Contract inherited by the MeTokenFactory
@dev this arrangement of having calculation done by the MeTokenFactory will allow for easier upgrades of the logic used in bonding curves
      which will be useful when MeToken is upgraded to use bonding surfaces
@param _supply is the total Supply of the MeTokenInstance calling the function
@param _connectorBalance is the (ether) pool balance the MeTokenInstance holds
@param _connectorWeight is the reserve ratio of the MeTokenInstance
@param _depositAmount is the amount of ether being exchanged for MeToken
@notice this function returns a uint256 that represents the amount of MeToken the exchanged ether is worth
**/
  function calculatePurchaseReturn(
    uint256 _supply,
    uint256 _connectorBalance,
    uint32 _connectorWeight,
    uint256 _depositAmount
  )
     public
     view
     returns (uint256);

/**
@notice calculateSaleReturn is used to calculate the current exchange rate for meTokens to ether for a given MeTokenInstance
@dev this function is apart of the Bancor Formula Contract inherited by the MeTokenFactory
@dev this function is called with a different reserve ratio depending on if the msg.sender is an owner or a funder
@param _supply is the total Supply of the MeTokenInstance calling the function
@param _connectorBalance is the (ether) pool balance the MeTokenInstance holds
@param _connectorWeight is the reserve ratio of the MeTokenInstance
@param _sellAmount is the amount of meToken being exchanged for ether
@notice this function returns a uint256 that represents the amount of ether to be exchanged
**/
     function calculateSaleReturn(
       uint256 _supply,
       uint256 _connectorBalance,
       uint32 _connectorWeight,
       uint256 _sellAmount
     )
       public
       view
       returns (uint256);

}
