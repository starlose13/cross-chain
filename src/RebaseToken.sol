// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/*
 * @title Rebase Token for Deposit Token by Nethermind
 * @author Pouya Nasehi
 * @notice This is the Rebase Token for Deposit Token and the users will gain interest
 * @notice Only Admin can decrease the interest rate
 */

contract RebaseToken is ERC20, AccessControl {
    event RebaseToken__InterestRateUpdated(uint256 newInterestRate);
    error RebaseToken__InterestRateCanOnlyDecrease();

    uint256 private s_interestRate = 5e10;

    bytes32 private ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 private MINT_BURN_ACCESS = keccak256("MINT_BURN_ACCESS");

    constructor() ERC20("RebaseToken", "RBT") {
        _grantRole(MINT_BURN_ACCESS, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    /*
     * @notic manupulate the Interest Rate of the Rebase Token
     * @params newInterestRate is the new interest rate
     * @dev Admin can only decrease the interest rate
     */

    function setInterestRate(uint256 newInterestRate) external {
        if (newInterestRate >= s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease();
        }
        s_interestRate = newInterestRate;
        emit RebaseToken__InterestRateUpdated(newInterestRate);
    }
}
