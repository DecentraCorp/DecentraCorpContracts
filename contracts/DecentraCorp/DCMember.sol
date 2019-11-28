pragma solidity ^0.5.0;

import './DecentraStock.sol';

 contract DCMember is DCBase {
   using SafeMath for uint256;

event NewMember(address _newMem, address newMemFacility, string profHash);
event ProfileUpdated(address updatedAccount);


///@notice addMember function is an internal function for adding a member to decentracorp
///@dev addMember takes in an address _mem, sets its membership to true and increments their rank by one
  function _addMember(address _mem, string calldata _userId) external onlyApprovedAdd {
      require(_checkIfFrozen(_mem) == false);
      members[_mem] = true;
      memberLevel[_mem]++;
      memberCount = memberCount + 1;
      userIDs[keccak256(abi.encodePacked(_userId))] = _mem;
  }


  function _checkIfMember(address _member) public view returns(bool) {
    if(members[_member] == true){
      return true;
    }
  }



  ///@notice getMemberCount function returns total membercount
  ///@dev getMemberCount is for front end and internal use
    function getMemberCount() public view returns(uint) {
      return memberCount;
    }

    function increaseMemLev(address _add) external onlyApprovedAdd {
      require(_checkIfFrozen(_add) == false);
      memberLevel[_add]++;
    }

    function decreaseMemLev(address _add) external onlyApprovedAdd {
      memberLevel[_add]--;
    }

    function getLevel(address _add) public view returns(uint) {
      return memberLevel[_add];
    }

    function getProfileHash(address _add) public view returns(string memory) {
      return memberProfileHash[_add];
    }

    function terminateMember(address _member) internal {
      uint balance = balanceOf(_member);
       DecentraDollar._BurnDecentraDollar(_member, balance);
       members[_member] = false;
       memberLevel[_member] = 0;
       frozenAccounts[_member] = true;
       memberCount = memberCount - 1;
    }


    ///@notice buyMembership function allows for the purchase of a membership for 6 months after official launch.
    ///@dev mints the user 1000 NTC if member is one of the first 100
      function buyMembership(
        address _newMem,
        address _facility,
        string memory _hash,
        string memory _userId
      ) public {
        require(_checkIfFrozen(_newMem) == false);

        if(memberCount > 50) {
          members[_newMem] = true;
          memberLevel[_newMem]++;
          memberCount = memberCount + 1;
          memberProfileHash[_newMem] = _hash;
          userIDs[keccak256(abi.encodePacked(_userId))] = _newMem;
          _mint(msg.sender, 100000000000000000000);
          DecentraStockC.issueCommonStock(msg.sender, 1);
        emit NewMember(_newMem, _facility, _hash);
        }
          DecentraDollar._BurnDecentraDollar(msg.sender, commonStockPrice);
          DecentraDollar._MintDecentraDollar(address(this), commonStockPrice);

          members[_newMem] = true;
          memberLevel[_newMem]++;
          memberCount = memberCount + 1;
          memberProfileHash[_newMem] = _hash;
          userIDs[keccak256(abi.encodePacked(_userId))] = _newMem;
        emit NewMember(_newMem, _facility, _hash);
      }

      function updateProfile(string memory _newHash) public {
            memberProfileHash[msg.sender] = _newHash;
          emit ProfileUpdated(msg.sender);
      }

      function getAddFromPass(string memory _userId) public view returns(address) {
        return userIDs[keccak256(abi.encodePacked(_userId))];
      }


}
