pragma solidity ^0.4.21;
import "./Interface.sol";
////////////////////////////////////////////////////////////////////////////////////////////
/// @title IBLogic Contract for the CryptoPatent Blockchain
/// @author DecentraCorp
/// @notice this contract is the second contract in the CryptoPatent Blockchain
/// @dev All function calls are currently implement without side effects
////////////////////////////////////////////////////////////////////////////////////////////

/// @author Christopher Dixon
/// @dev this contract contains the cryptopatent interface for the IdeaBlock contract
contract IBLogic is Interface {


///@notice generateIdeaBlock is used to generate and ideablock after a community vote
///@dev this function is onlyOwner as atm the CPB is owning itself. In the future
///     this will likely be set to an account that will have special privlidges between this contracts and
///     the ethereum Based DecentraCorp contracts to facilitate crosschain communication

function generateIdeaBlock(
  string _ideaIPFS,
  uint  _globalUseBlockAmount,
  uint _miningTime,
  uint _royalty,
  address _inventor,
  address _invention
  )
  public
  onlyOwner
  {

    DCPoA.generateIdeaBlock( _ideaIPFS, _globalUseBlockAmount, _miningTime, _royalty,  _inventor);
//generates IdeaBlock ERC721 Token
    globalIdeaCount++;
    if(checkIfMember(_inventor) != true){
      DCPoA._addMember(_inventor);
}
inventions[_invention] = true;
Validators.addValidator(_invention);
    ideaBlockTimeLord();
    DCPoA.proxyIDCMint( _inventor, ideaBlockReward);
//mints 1000 IDC and sends it to the inventor
    DCPoA.increaseMemLev(_inventor);
    getTokens[_inventor].push(globalIdeaCount);
    DCPoA.increaseFacilityRank( _inventor, 20);
  }

///@notice ideaBlockTimeLord is called to half an ideablock reward every two years
///@dev this time may need to be adjusted to 4 years depending on predicted inflation patterns of IDC
  function ideaBlockTimeLord() internal returns(uint){
    if(now >= globalBlockHalfTime + 94670778) {
      ideaBlockReward = ideaBlockReward / 2;
      globalBlockHalfTime = now;
      return ideaBlockReward;
      }
      return ideaBlockReward;
  }
}
