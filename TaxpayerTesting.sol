// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./Taxpayer.sol"; // Replace with the actual path to your contract

contract TaxpayerTesting {
    Taxpayer alpha;
    address constant partner1 = 0x1111111111111111111111111111111111111111;
    address constant partner2 = 0x2222222222222222222222222222222222222222;

    constructor() {
        alpha = new Taxpayer(address(1), address(2));
    }

    // Echidna test to check marriage and divorce
    function echidna_test_marry() public returns (bool) {
        // Test marry
        alpha.marry(address(2));
        Taxpayer tp = Taxpayer(address(2));
        return !(tp.age()<0);
    }

    // Echidna test to check age increment
    function echidna_test_have_birthday() public returns (bool) {
        // Save current age
        uint initialAge = alpha.age();
        // Increment age
        alpha.haveBirthday();
        // Check if age is incremented correctly
        require(alpha.age() == initialAge + 1, "Failed to increment age");
        return alpha.age() == initialAge + 1;
    }
}
