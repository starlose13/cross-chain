// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {IRebaseToken} from "../src/interface/IRebaseToken.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {Vault} from "../src/Vault.sol";

contract RebaseTokenTest is Test {
    uint256 private INITIAL_PRECISION_FACTOR = 1e18;
    uint256 private INITIAL_INTEREST_RATE =
        (5 * INITIAL_PRECISION_FACTOR) / 1e8;
    uint256 private DECERESES_AMOUNT_OF_INTEREST_RATE =
        (5 * INITIAL_PRECISION_FACTOR) / 1e10;

    RebaseToken rebaseToken;
    Vault vault;

    address public owner = makeAddr("owner");
    address public user = makeAddr("user");

    function setUp() public returns (address, address) {
        vm.startPrank(owner);
        rebaseToken = new RebaseToken();
        vault = new Vault(IRebaseToken(address(rebaseToken)));
        rebaseToken.grantMintAndBurnRole(address(vault));
        (bool success, ) = payable(address(vault)).call{value: 100e18}("");
        success;
        vm.stopPrank();
        return (address(rebaseToken), address(vault));
    }

    function testDepositLinear(uint256 _amount) public {
        _amount = bound(_amount, 1e10, type(uint96).max);
        vm.startPrank(user);
        vm.deal(user, _amount);
        // something to do
        vault.deposit{value: _amount}();
        uint256 startBalance = rebaseToken.balanceOf(user);
        console.log("Start Balance is: ", startBalance);
        assertEq(startBalance, _amount);
        vm.warp(block.timestamp + 1 hours);
        uint256 middleBalance = rebaseToken.balanceOf(user);
        assertGt(middleBalance, startBalance);
        vm.warp(block.timestamp + 1 hours);
        uint256 endBalance = rebaseToken.balanceOf(user);
        assertGt(endBalance, middleBalance);
        assertApproxEqAbs(
            endBalance - middleBalance,
            middleBalance - startBalance,
            2
        );
        vm.stopPrank();
    }

    function testRedeemStarightAway(uint256 amount) external {
        amount = bound(amount, 1e5, type(uint96).max);
        vm.startPrank(user);
        vm.deal(user, amount);
        vault.deposit{value: amount}();
        uint256 startingBalance = rebaseToken.balanceOf(user);
        console.log("startingBalance is : ", startingBalance);
        assertEq(startingBalance, amount);
        vault.redeem(amount);
        uint256 endingBalance = rebaseToken.balanceOf(user);
        assertEq(endingBalance, 0);
        vm.stopPrank();
    }

    function testRedeemAfterTimePassed(uint amount, uint256 time) external {
        time = bound(time, 1000, type(uint96).max);
        amount = bound(amount, 1e5, type(uint96).max);
        vm.startPrank(user);
        vm.deal(user, amount);
        vault.deposit{value: amount}();
        uint256 startingBalance = rebaseToken.balanceOf(user);
        assertEq(startingBalance, amount);
        vm.warp(block.timestamp + time);
        vault.redeem(amount);
        uint256 ethBalance = address(user).balance;
        assertEq(ethBalance, startingBalance);
        vm.stopPrank();
    }

    function testTransfer(uint256 amount, uint256 amountToSend) external {
        amount = bound(amount, 1e5 + 1e5, type(uint96).max);
        amountToSend = bound(amountToSend, 1e5, amount - 1e5);
        vm.deal(user, amount);
        vm.prank(user);
        vault.deposit{value: amount}();
        address user2 = makeAddr("user2");
        uint256 userBalance = rebaseToken.balanceOf(user);
        uint256 user2Balance = rebaseToken.balanceOf(user2);
        assertEq(userBalance, amount);
        assertEq(user2Balance, 0);
        vm.prank(user);
        rebaseToken.transfer(user2, amountToSend);
        vm.prank(owner);
        rebaseToken.setInterestRate(DECERESES_AMOUNT_OF_INTEREST_RATE);
        uint256 user2BalanceAfterTransfer = rebaseToken.balanceOf(user2);
        uint256 userBalanceAfterTransfer = rebaseToken.balanceOf(user);
        assertEq(user2BalanceAfterTransfer, amountToSend);
        assertEq(userBalanceAfterTransfer, amount - amountToSend);
        assertEq(rebaseToken.getUserInterestRate(user2), INITIAL_INTEREST_RATE);
    }
}
