 pragma solidity 0.8.4;
//SPDX-License-Identifier: MIT

import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  event Stake(address, uint256);

  ExampleExternalContract public exampleExternalContract;
  mapping(address => uint256) public balances;
  uint256 public deadline = block.timestamp + 30 seconds;
  uint256 public constant threshold = 1 ether;
  bool public openForWithdraw = true;

  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // TODO: Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() public payable {
    balances[msg.sender] = msg.value + balances[msg.sender];
    emit Stake(msg.sender, msg.value);
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance / 1 ether;
  }

  // TODO: After some `deadline` allow anyone to call an `execute()` function
  //  It should call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public {
    if (address(this).balance >= threshold && block.timestamp > deadline) {
      openForWithdraw = false;
      exampleExternalContract.complete{value: address(this).balance}();
    }
  }

  // TODO: if the `threshold` was not met, allow everyone to call a `withdraw()` function

  function withdraw() public {
    (bool sent, ) = msg.sender.call{value: balances[msg.sender]}('');
    require(sent, 'Failed To Send');
  }

  // TODO: Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  // TODO: Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }
}