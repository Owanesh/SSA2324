// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./Taxpayer.sol";

contract TaxpayerTesting {
    function echidna_createTaxpayerAndCheckMarriage() public returns (bool) {
        address partner1 = 0x1111111111111111111111111111111111111111;
        address partner2 = 0x2222222222222222222222222222222222222222;
        Taxpayer alpha = new Taxpayer(partner1, partner2);
        alpha.marry(partner2);
        bool result = alpha.getSpouse() != address(0);
        require(result, "You've married");
        return result;
    }

    function echidna_createTaxpayerAndCheckChosenOne() public returns (bool) {
        address partner1 = 0x1111111111111111111111111111111111111111;
        address partner2 = 0x2222222222222222222222222222222222222222;
        Taxpayer alpha = new Taxpayer(partner1, partner2);
        alpha.marry(partner2);
        bool result = alpha.getSpouse() == partner2;
        require(result, "You've married your partner");
        return result;
    }

    function echidna_TestBothMarriedEachOther() public returns (bool){
        address partner1 = 0x1111111111111111111111111111111111111111;
        address partner2 = 0x2222222222222222222222222222222222222222;
        Taxpayer alpha = new Taxpayer(partner1, partner2);
        alpha.marry(address(partner2));
        address result = Taxpayer(partner1).getSpouse();
        require(result==address(partner2), "Mutual marriage condition not satisfied");
        return result==address(partner2);
    }
}
