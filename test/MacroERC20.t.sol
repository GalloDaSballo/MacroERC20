// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MacroERC20, ERC20} from "src/MacroERC20.sol";

contract LogCaller {
  address public lastCaller;
  function setCaller(address caller) external returns (address) {
    lastCaller = caller;
    return caller;
  }
}

contract MacroERC20Test is Test {
    MacroERC20 public token;
    LogCaller public logger;

    function setUp() public {
        token = new MacroERC20("name", "NAME");
        logger = new LogCaller();
    }

    function test_caller() public {
      logger.setCaller(address(this));
      assertEq(logger.lastCaller(), address(this), "caller works");
    }

    function test_caller_with_token(address val) public {
      // Fake addy
      bytes memory encoded = abi.encodeCall(LogCaller.setCaller, (address(val)));
      token.callWithForwardedData(address(logger), encoded);
      assertEq(logger.lastCaller(), address(this), "cannot manipulate logger");
    }

    function test_caller_with_arbitraryData(bytes memory data) public {
      logger.setCaller(address(0x123));
      (bool s, ) = token.callWithForwardedData(address(logger), data);
      if(s) {
        assertEq(logger.lastCaller(), address(this), "cannot manipulate logger");
      } else {
        assertEq(logger.lastCaller(), address(0x123), "cannot manipulate logger");
      } 
    }

    function test_caller_macro(address randomTarget) public {
      bytes memory encoded = abi.encodeCall(LogCaller.setCaller, (address(randomTarget)));

      logger.setCaller(address(randomTarget));
      assertEq(logger.lastCaller(), address(randomTarget), "Properly setup");


      MacroERC20.MacroData[] memory allData = new MacroERC20.MacroData[](1);

      MacroERC20.MacroData memory data = MacroERC20.MacroData({
        target: address(logger),
        encodedData: encoded,
        requireSuccess: true
      });
      allData[0] = data;

      token.doTheMacro(allData);
      assertEq(logger.lastCaller(), address(this), "cannot manipulate logger");
    }

    // forge test --match-test test_an_approve -vvvv
    function test_an_approve(address randomTarget, uint256 allowanceFlag) public {
      vm.assume(randomTarget != address(0));
      bytes memory encoded = abi.encodeCall(ERC20.approve, (randomTarget, allowanceFlag));

      MacroERC20.MacroData[] memory allData = new MacroERC20.MacroData[](1);

      MacroERC20.MacroData memory data = MacroERC20.MacroData({
        target: address(token),
        encodedData: encoded,
        requireSuccess: true
      });
      allData[0] = data;

      token.doTheMacro(allData);
      assertEq(token.allowance(address(this), randomTarget), allowanceFlag);
    }
}
