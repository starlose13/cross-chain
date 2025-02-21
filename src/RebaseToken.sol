// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
 * @title Rebase Token for Deposit Token by Nethermind
 * @author Pouya Nasehi
 * @notice This is the Rebase Token for Deposit Token and the users will gain interest
 * @notice Only Admin can decrease the interest rate
 */

contract RebaseToken is ERC20 {
    event RebaseToken__InterestRateUpdated(uint256 newInterestRate);
    error RebaseToken__InterestRateCanOnlyDecrease();

    uint256 private s_interestRate = 5e10;

    constructor() ERC20("RebaseToken", "RBT") {}

    function setInterestRate(uint256 newInterestRate) public {
        if (newInterestRate >= s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease();
        }
        s_interestRate = newInterestRate;
        emit RebaseToken__InterestRateUpdated(newInterestRate);
    }
}
