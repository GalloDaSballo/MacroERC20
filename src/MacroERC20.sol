// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.13;
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MacroERC20 is ERC20 {

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}
    
    /// @dev Replaces the first parameter of AbiEncodedData with the address of the caller
    function _replaceCaller(bytes memory abiEncodedData) internal view returns (bytes memory) {
      // Make a copy of the data
      bytes memory copy = abiEncodedData;

      // Edit the bytes from 5 to 37 with the msg.sender
      assembly {
        // Length + selector = 32 + 4 = 36
        mstore(add(copy, 36), caller())
      }

      return copy;
    }

    /// @notice Given a target and abi encoded data, we replace the first parameter to be the address of the caller
    ///   And we then call the target
    function callWithForwardedData(address target, bytes memory encodedData) public returns (bool, bytes memory) {
      
      bool success; 
      bytes memory returnData;

      if(target == address(this)) {
        forwardedSender = msg.sender;
        (success, returnData) = target.call(encodedData);
        forwardedSender = address(this); /// NOTE: To save more gas you need to add a dirty value to the slot above
      } else {
        bytes memory dataToCallWith = _replaceCaller(encodedData);
        (success, returnData) = target.call(encodedData);
      }      

      return (success, returnData);
    }

    struct MacroData {
      address target;
      bytes encodedData;
      bool requireSuccess;
    }

    /// @notice Given macro data perform a multicall to any target
    /// @dev We replace the first parameter with the address of the msg.sender, always
    function doTheMacro(MacroData[] memory macroData) external {
      uint256 length = macroData.length;
      for(uint256 i; i < length; ++i) {
        (bool res, ) = callWithForwardedData(macroData[i].target, macroData[i].encodedData);
        if(macroData[i].requireSuccess) {
          require(res, "Must succeed");
        }
      }
    }

    address forwardedSender;

    function _msgSender() internal view override returns (address) {
      if(forwardedSender != address(this)) {
        return forwardedSender;
      }

      return msg.sender;
    }
}
