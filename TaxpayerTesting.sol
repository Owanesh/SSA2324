// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./Taxpayer.sol"; // Replace with the actual path to your contract

contract TaxpayerTesting  is Taxpayer{
    Taxpayer bravo;
    constructor() Taxpayer(address(0), address(0)) {}

    function echidna_test_one_way_marriage() public returns (bool) {
        bravo = new Taxpayer(address(0), address(0));
        this.marry(address(bravo));
        bool this_to_bravo =  this.getSpouse()==address(bravo)&& this.getSpouse()!=address(0);
        return this_to_bravo;
    }


    function echidna_test_both_married() public returns (bool) {
        bravo = new Taxpayer(address(1), address(1));
        this.marry(address(bravo));
        bravo.marry(address(this));
        bool this_to_bravo =  this.getSpouse()==address(bravo)&& this.getSpouse()!=address(0);
        bool bravo_to_this =  bravo.getSpouse()==address(this)&& bravo.getSpouse()!=address(0);
        return this_to_bravo&&bravo_to_this;
    }


    // Echidna test to check age increment
    function echidna_test_have_birthday() public returns (bool) {
        uint initialAge = this.age();
        this.haveBirthday();
        require(this.age() == initialAge + 1, "Failed to increment age");
        return this.age() == initialAge + 1;
    }
}
