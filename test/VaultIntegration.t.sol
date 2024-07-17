// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MacroERC20, ERC20} from "src/MacroERC20.sol";

contract MintableMockToken is MacroERC20 {
  constructor() MacroERC20("n", "N") {

  }

  function mint(address to, uint256 amt) external {
    _mint(to, amt);
  }
}

contract SampleVault {
  mapping (address => uint256) public deposits;

  MacroERC20 immutable token;

  constructor(address _token) {
    token = MacroERC20(_token);
  }

  function deposit(address from, uint256 amt) external {
    deposits[from] += amt;
    if(msg.sender == address(token)) {
      token.transferFrom(from, address(this), amt);
    } else {
      token.transferFrom(msg.sender, address(this), amt);
    }
    
  }
}

contract MacroERC20Test is Test {
    MintableMockToken public token;
    SampleVault public vault;


    function setUp() public {
        token = new MintableMockToken();
        vault = new SampleVault(address(token));
    }



    // forge test --match-test test_approve_and_deposit -vvvv
    function test_approve_and_deposit(uint256 amount) public {

      bytes memory encodedMint = abi.encodeCall(MintableMockToken.mint, (address(this), amount));
      bytes memory encodedApprove = abi.encodeCall(ERC20.approve, (address(vault), amount));
      bytes memory encodedDeposit = abi.encodeCall(SampleVault.deposit, (address(0x123123), amount));

      MacroERC20.MacroData[] memory allData = new MacroERC20.MacroData[](3);

      allData[0] = MacroERC20.MacroData({
        target: address(token),
        encodedData: encodedMint,
        requireSuccess: true
      });

      allData[1] = MacroERC20.MacroData({
        target: address(token),
        encodedData: encodedApprove,
        requireSuccess: true
      });

      allData[2] = MacroERC20.MacroData({
        target: address(vault),
        encodedData: encodedDeposit,
        requireSuccess: true
      });

      token.doTheMacro(allData);
      assertEq(vault.deposits(address(this)), amount, "Depoist matches");
    }
}
