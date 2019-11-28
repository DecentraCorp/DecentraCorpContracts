pragma solidity ^0.5.0;
import "@openzeppelin/contracts-ethereum-package/contracts/ownership/Ownable.sol";
import '@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol';
import "@openzeppelin/upgrades/contracts/Initializable.sol";
import './DecentraCorp.sol';
import "./DecentraDollar.sol";
import "./DecentraStockP.sol";
import './utils/BamcorFormula.sol';

contract DC_Bank is Initializable, Ownable, IERC20, BamcorFormula {
  using SafeMath for uint256;

  uint public idCDP;

  DecentraDollar public DCD;
  DecentraStockP public DSP;
  DecentraCorp public DC;

DecentraStockCDP[] public CDPs;

  struct DecentraStockCDP{
    address CDPowner; //owner of the CDP
    uint DSPamountLocked; //Amount of Preffered Stock locked in CDP
    uint DCDvalueOfCDP; //value Amount When Locked
    uint DCDvalueOfLoan; //value of loan given
    bool isPayedOff; //whether or not a loan has been payed back
  }

     function initialize(address _DC, address _DCD, address _DSP) public initializer {
       Ownable.initialize(_DC);
       BamcorFormula.initialize();
       DC = _DC;
       DCD = _DCD;
       DSP = _DSP;
     }


     function buyPrefferedStock(uint _DCDamount) public {
         uint256 ts = DSP.totalSupply();
         uint poolBalance = DC.getDCbalance();
         uint amountOfStock = calculatePurchaseReturn(ts, poolBalance, 500000, _DCDamount);
         DC.proxyDCDBurn(msg.sender, _DCDamount);
         DC.proxyDCDMint(owner() , _DCDamount);
         DC.proxyDSPMint(msg.sender, amountOfStock);
     }

     function sellPrefferedStock(uint _DSPamount) public {
       uint256 ts = DSP.totalSupply();
       uint poolBalance = DC.getDCbalance();
       uint amountOfDCD = calculateSaleReturn(ts, poolBalance, 400000, _DSPamount);
       DC.proxyDSPBurn(msg.sender, _DSPamount);
       DC.proxyDCDBurn(owner() , amountOfDCD);
       DC.proxyDCDMint(msg.sender , amountOfDCD);
     }

     function stakeDSPintoCDP(uint _DSPamount) public returns(uint){
       uint256 ts = DSP.totalSupply();
       uint poolBalance = DC.getDCbalance();
       uint DCDvalueOfDSP = calculateSaleReturn(ts, poolBalance, 500000, _DSPamount);
       uint loanAmountOfDCD = (loanAmountOfDCD.div(3)).mul(2);

       idCDP++;

       DecentraStockCDP storage c = CDPs[idCDP];

       c.CDPowner = msg.sender;
       c.DSPamountLocked = _DSPamount;
       c.DCDvalueOfCDP = DCDvalueOfDSP;
       c.DCDvalueOfLoan = loanAmountOfDCD;
       c.isPayedOff = false;

       DC.proxyDSPBurn(msg.sender, _DSPamount);
       DC.proxyDSPMint(owner(), _DSPamount);
       DC.proxyDCDMint(msg.sender , loanAmountOfDCD);
       return(idCDP);
     }

     function checkForDefault() public {
         for (uint i = 0; i <  p.votes.length; ++i) {
           DecentraStockCDP storage c = CDPs[i];
              if(!c.isPayedOff) {
                uint256 ts = DSP.totalSupply();
                uint poolBalance = DC.getDCbalance();
                uint DCDvalueOfDSP = calculateSaleReturn(ts, poolBalance, 500000, c.DSPamountLocked);
                if(c.DCDvalueOfCDP <= DCDvalueOfDSP) {
                  c.isPayedOff = true;
                }
              }
            }
          }

      function payBackLoan(uint _idCDP) public {

        DecentraStockCDP storage c = CDPs[_idCDP];
        c.isPayedOff = true;
        DC.proxyDCDBurn(msg.sender, c.DCDvalueOfLoan);
        DC.proxyDSPBurn(owner(), c.DSPamountLocked);
        DC.proxyDSPMint(CDPowner, c.DSPamountLocked);

      }

      function addToCDP(uint _DSPamount, uint _idCDP) public {
        DecentraStockCDP storage c = CDPs[_idCDP];

        DC.proxyDSPBurn(msg.sender, _DSPamount);
        DC.proxyDSPMint(owner(), _DSPamount);
        c.DSPamountLocked += _DSPamount;
      }

  }
