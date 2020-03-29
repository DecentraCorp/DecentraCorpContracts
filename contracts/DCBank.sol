pragma solidity ^0.5.0;

import './DCBase.sol';

////////////////////////////////////////////////////////////////////////////////////////////
/// @title DecentraCorp
/// @dev All function calls are currently implement without side effects
/// @author Christopher Dixon
////////////////////////////////////////////////////////////////////////////////////////////
contract DCBank is DCBase {


  uint public collateralPoolBalance;
  uint public DecentraEarnings;
  uint256 public percentFee; //used in calculating fees
  uint256 public divisor; //used in calculating fees

  /**
  @notice calculateFee is used to calculate the fee earned by the StakeOnMe Development Team whenever a MeToken Purchase or sale occurs throught contract
  @param _payedAmount is a uint representing the full amount of ETH payed for an amount of meToken OR returned for the sale of meToken through the contract
  **/
  function calculateFee(uint256 _payedAmount) public view returns(uint) {
    uint256 fee = _payedAmount.mul(percentFee).div(divisor);
    return fee;
  }


     function buyPrefferedStock(uint _tokenAmount, uint _contractNum) public {
         uint256 ts = DS.totalSupply();
         uint amountOfStock = bancor.calculatePurchaseReturn(ts, collateralPoolBalance, 500000, _tokenAmount);
        address tokenAdd = contractNumber[_contractNum];
               IERC20 token = IERC20(tokenAdd);
          collateralPoolBalance = collateralPoolBalance.add(_tokenAmount);

         if(_contractNum != 1) {
           uint fee = calculateFee(_tokenAmount);
           _tokenAmount = _tokenAmount.add(fee);
           DecentraEarnings = DecentraEarnings.add(fee);
         }

         token.transferFrom(msg.sender, address(this), _tokenAmount);
         DS._IssueDecentraStock(msg.sender, amountOfStock);
}




     function sellPrefferedStock(uint _DSamount, uint _contractNum) public {
       require(_contractNum <= approvedContracts);
       address tokenAdd = contractNumber[_contractNum];
       require(tokenAdd != address(this));
       uint256 ts = DS.totalSupply();
       uint amountOfToken = bancor.calculateSaleReturn(ts, collateralPoolBalance, 450000, _DSamount);
       uint fullPrice = bancor.calculateSaleReturn(ts, collateralPoolBalance, 500000, _DSamount);
       uint earned = fullPrice.sub(amountOfToken);
       DecentraEarnings = DecentraEarnings.add(earned);
       IERC20 token = IERC20(tokenAdd);

       proxyDSBurn(msg.sender, _DSamount);
       uint tokenBal = token.balanceOf(address(this));

       if(_contractNum != 1) {
         uint fee = calculateFee(amountOfToken);
         amountOfToken = amountOfToken.sub(fee);
          DecentraEarnings = DecentraEarnings.add(fee);
       }

       if(tokenBal < amountOfToken) {
         proxyDDMint(msg.sender, amountOfToken);
       } else {
         token.transfer(msg.sender, amountOfToken);
         collateralPoolBalance = collateralPoolBalance.sub(amountOfToken);
       }

     }

function setFee(uint _feePercent) internal {
  percentFee = _feePercent;
}


  }
