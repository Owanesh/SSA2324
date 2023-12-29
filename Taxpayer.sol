// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Taxpayer {
    uint256 public age;

    bool isMarried;
    /* Reference to spouse if person is married, address(0) otherwise */
    address spouse;
    address parent1;
    address parent2;
    /* Constant default income tax allowance */
    uint256 constant DEFAULT_ALLOWANCE = 5000;
    /* Constant income tax allowance for Older Taxpayers over 65 */
    uint256 constant ALLOWANCE_OAP = 7000;
    /* Income tax allowance */
    uint256 tax_allowance;

    uint256 income;

    constructor(address p1, address p2) {
        age = 0;
        isMarried = false;
        parent1 = p1;
        parent2 = p2;
        spouse = (address(0));
        income = 0;
        tax_allowance = DEFAULT_ALLOWANCE;
    }

    // Invariants are conditions that must always be true at the end of any function execution within the contract
    // Invariant 1: If person x is married to person y, then person y should also be married to person x.
    // Invariant 2: If person x is married, then the spouse's reference should point back to person x.
    // function invariantMarriage() internal view returns (bool) {
    //     if (isMarried && getSpouse() != address(0)) {
    //         Taxpayer sp = Taxpayer(address(getSpouse()));
    //         return (sp.getSpouse() == address(this));
    //     }
    //     return true;
    // }

    // function invariantTaxAllowance() internal view returns (bool) {
    //     return tax_allowance >= 0;
    // }

    // function invariantTaxAllowanceAge() internal view returns (bool) {
    //     if (age >= 65) {
    //         return tax_allowance == ALLOWANCE_OAP;
    //     }
    //     return true; // No violation if age < 65
    // }

    // function invariantSumTaxAllowances() internal view returns (bool) {
    //     if (isMarried) {
    //         Taxpayer spouseContract = Taxpayer(address(spouse));
    //         return
    //             tax_allowance + spouseContract.getTaxAllowance() ==
    //             DEFAULT_ALLOWANCE;
    //     }
    //     return true; // No violation if not married
    // }

    // modifier invariants() {
    //     _; // do the normal code, then execute my variants
    //     invariantMarriage();
    //     invariantTaxAllowance();
    //     invariantSumTaxAllowances();
    //     invariantTaxAllowanceAge();
    // }

    function marry(address new_spouse) public {
        require(new_spouse!=address(this),"You cannot marry with yourself");
        require(new_spouse != spouse, "Already married to this spouse");
        require(spouse == address(0) && !isMarried, "Already married");
        require(new_spouse != address(0), "Invalid spouse address");
        Taxpayer sp = Taxpayer(address(new_spouse));
        require(
            address(sp).code.length >0,
            "Invalid spouse, is it already born?"
        );
        require(
            sp.getSpouse() == address(0) || sp.getSpouse() == address(this),
            "Your partner should be single or not married with another person"
        );
        spouse = new_spouse;
        isMarried = true;
    }

    function divorce() public {
        require(spouse != address(0),"You're not already married");
        Taxpayer sp = Taxpayer(address(spouse));
        sp.setSpouse(address(0));
        spouse = address(0);
        isMarried = false;
    }
    
    function setSpouse(address sp) public {
        require(sp!=address(this),"You cannot call setSpouse with yourself");
        bool want_to_divorce = sp==address(0);
        require(
            (isMarried && want_to_divorce),
            "You are already married, you can call this function only for divorce purpose now"
        );
        spouse = (address(sp));
    }

 
    /* Transfer part of tax allowance to own spouse */
    function transferAllowance(uint256 change) public {
        require(isMarried, "Not married");
        require(tax_allowance >= change, "Insufficient tax allowance");
        tax_allowance -= change;
        Taxpayer sp = Taxpayer(address(spouse));
        sp.setTaxAllowance(sp.getTaxAllowance() + change);
    }

    function haveBirthday() public {
        age++;
    }

    function getSpouse() public view returns (address) {
        return spouse;
    }

    function setTaxAllowance(uint256 ta) public {
        tax_allowance = ta;
    }

    function getTaxAllowance() public view returns (uint256) {
        return tax_allowance;
    }
}
