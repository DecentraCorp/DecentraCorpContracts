pragma solidity ^0.5.0;

import './DCBase.sol';

contract DecentraStock is DCBase {


     uint public commonStockPrice;
     uint public preferedStockPrice;
     uint public stakeNumber;
     uint public commonStocksHeldByDC;
     uint public preferedStocksHeldByDC;
     uint public totalCstock;
     uint public totalPstock;
     address public oracle;

    mapping(address => DecentraStocks) stocks;
    mapping(uint => StockStakes) stakedStocks;

  struct DecentraStocks {
    uint commonStocks;
    uint preferedStocks;
    uint stakedCommonStock;
    uint stakedPreferedStock;
  }

struct StockStakes {
  uint NTCValue;
  uint numberOfStocks;
  uint stockValueAtPurchase;
  uint stockType;
  address staker;
  bool payedOff;
}


  modifier onlyOracle() {
    require(msg.sender == oracle);
    _;
  }

  function issueCommonStock(address _stockOwner, uint _amount) internal  {
     DecentraStocks storage s = stocks[_stockOwner];
     s.commonStocks += _amount;
     totalCstock++;
  }

  function issuePreferedStock(address _stockOwner, uint _amount) internal  {
    DecentraStocks storage s = stocks[_stockOwner];
    s.preferedStocks += _amount;
    totalPstock++;
  }



  function setStockPrices(
    uint _commonStockPrice,
    uint _preferedStockPrice
  )
  public
  onlyOracle {
    commonStockPrice = _commonStockPrice;
    preferedStockPrice = _preferedStockPrice;

      for (uint i = 0; i <= stakeNumber; ++i) {
          StockStakes storage ss = stakedStocks[i];
          if(ss.payedOff == false ) {
            if(ss.stockType == 1) {
              if(ss.NTCValue <= commonStockPrice) {
                ss.payedOff = true;
                commonStocksHeldByDC += ss.numberOfStocks;
              }
            }
            if(ss.NTCValue <= preferedStockPrice) {
              ss.payedOff = true;
              preferedStocksHeldByDC += ss.numberOfStocks;
            }

            }
          }
      }




  function purchasePreferedStock(uint _amount) public {
    uint purchasePrice = _amount.mul(preferedStockPrice);
    require(balanceOf(msg.sender) >= purchasePrice);
    _burn(msg.sender, purchasePrice);
    _mint(address(this), purchasePrice);
    if(preferedStocksHeldByDC <= _amount){
      issuePreferedStock(msg.sender, _amount);
    }
    preferedStocksHeldByDC -= _amount;
    DecentraStocks storage s = stocks[msg.sender];
      s.preferedStocks += 1;
  }

  function purchaseCommonStock(uint _amount) public {
    uint purchasePrice = _amount.mul(commonStockPrice);
    require(balanceOf(msg.sender) >= purchasePrice);
    _burn(msg.sender, purchasePrice);
    _mint(address(this), purchasePrice);
    if(commonStocksHeldByDC <= _amount){
      issuePreferedStock(msg.sender, _amount);
    } else{
    commonStocksHeldByDC -= _amount;
    DecentraStocks storage s = stocks[msg.sender];
      s.commonStocks += 1;
    }
  }


  function transferCommonStock(address _to, uint _amount) public {
      DecentraStocks storage s = stocks[msg.sender];
      require(s.commonStocks >= _amount);
      s.commonStocks = s.commonStocks.sub(_amount);

      DecentraStocks storage b = stocks[_to];
      b.commonStocks += _amount;
  }

  function transferPreferedStock(address _to, uint _amount) public {
      DecentraStocks storage s = stocks[msg.sender];
      require(s.preferedStocks >= _amount);
      s.preferedStocks = s.preferedStocks.sub(_amount);

      DecentraStocks storage b = stocks[_to];
      b.preferedStocks =   b.preferedStocks.add(_amount);
  }

  function stakeCommonStock(uint _amount) public {
    DecentraStocks storage s = stocks[msg.sender];
    require(s.commonStocks >= _amount);
    s.commonStocks = s.commonStocks.sub(_amount);
    s.stakedCommonStock = s.stakedCommonStock.add(_amount);
    stakeNumber++;
    uint stakeValue =  commonStockPrice.div(2);

      StockStakes storage ss = stakedStocks[stakeNumber];

      ss.NTCValue = stakeValue;
      ss.staker = msg.sender;
      ss.numberOfStocks = _amount;
      ss.stockValueAtPurchase = commonStockPrice;
      ss.stockType = 1;

      uint _DCNTC = getDCbalance();

  if(_DCNTC >= stakeValue){
    _burn(address(this), stakeValue);
    _mint(msg.sender, stakeValue);
  } else {
    _mint(msg.sender, stakeValue);
  }
}

  function stakePreferedStock(uint _amount) public {
    DecentraStocks storage s = stocks[msg.sender];
    require(s.preferedStocks >= _amount);
    s.preferedStocks = s.preferedStocks.sub(_amount);
    s.stakedPreferedStock = s.stakedPreferedStock.add(_amount);
    stakeNumber++;
    uint stakeValue =  preferedStockPrice.div(2);

    StockStakes storage ss = stakedStocks[stakeNumber];

      ss.NTCValue = stakeValue;
      ss.staker = msg.sender;
      ss.numberOfStocks = _amount;
      ss.stockValueAtPurchase = preferedStockPrice;
      ss.stockType = 2;

      uint _DCNTC = getDCbalance();

      if(_DCNTC >= stakeValue){
        _burn(address(this), stakeValue);
        _mint(msg.sender, stakeValue);
      } else {
        _mint(msg.sender, stakeValue);
      }
    }


  function payOffStake(uint _stakeNumber) public {
    StockStakes storage ss = stakedStocks[_stakeNumber];
    require(ss.payedOff == false);
    uint interest = ss.NTCValue * 3 / 100;
    uint stakePrice = ss.NTCValue + interest;
    require(msg.sender == ss.staker);
    require(balanceOf(msg.sender) >= stakePrice);
    _burn(msg.sender, stakePrice);
    _mint(address(this), stakePrice);

      DecentraStocks storage s = stocks[msg.sender];

      if(ss.stockType == 1){
        s.commonStocks = s.commonStocks.add(ss.numberOfStocks);
        s.stakedCommonStock = s.stakedCommonStock.sub(ss.numberOfStocks);
      }

      if(ss.stockType == 2){
        s.preferedStocks = s.preferedStocks.add(ss.numberOfStocks);
        s.stakedPreferedStock = s.stakedPreferedStock.sub(ss.numberOfStocks);
      }
  }

  function paySomeStake(uint _amount, uint _stakeNumber) public {
    StockStakes storage ss = stakedStocks[_stakeNumber];

  require(ss.payedOff == false);
  require(msg.sender == ss.staker);
  require(balanceOf(msg.sender) >= _amount);
  if(_amount >= ss.NTCValue){
    payOffStake(_stakeNumber);
  } else {
  _burn(msg.sender, _amount);
  _mint(address(this), _amount);

  uint newNTCvalue = ss.NTCValue - _amount;

  ss.NTCValue = newNTCvalue;

}

  }

  function addAdditionalStock(uint _amount, uint _stakeNumber) public {
    DecentraStocks storage s = stocks[msg.sender];
    StockStakes storage ss = stakedStocks[_stakeNumber];

    require(ss.payedOff == false);
    require(msg.sender == ss.staker);

    if(ss.stockType == 1){
      require(s.commonStocks >= _amount);
      s.commonStocks = s.commonStocks.sub(_amount);
      s.stakedCommonStock = s.stakedCommonStock.add(_amount);
      ss.numberOfStocks += _amount;
    }

    if(ss.stockType == 2){
      require(s.preferedStocks >= _amount);
      s.preferedStocks = s.preferedStocks.sub(_amount);
      s.stakedPreferedStock = s.stakedPreferedStock.add(_amount);
      ss.numberOfStocks += _amount;
    }


  }

}
