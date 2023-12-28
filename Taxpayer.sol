// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Taxpayer {
    uint public age;

    bool isMarried;
    /* Reference to spouse if person is married, address(0) otherwise */
    address spouse;
    address partner1;
    address partner2;
    /* Constant default income tax allowance */
    uint constant DEFAULT_ALLOWANCE = 5000;
    /* Constant income tax allowance for Older Taxpayers over 65 */
    uint constant ALLOWANCE_OAP = 7000;
    /* Income tax allowance */
    uint tax_allowance;

    uint income;

    constructor(address p1, address p2) {
        age = 0;
        isMarried = false;
        partner1 = p1;
        partner2 = p2;
        spouse = (address(0));
        income = 0;
        tax_allowance = DEFAULT_ALLOWANCE;
    }

    // Invariants are conditions that must always be true at the end of any function execution within the contract
    // Invariant 1: If person x is married to person y, then person y should also be married to person x.
    // Invariant 2: If person x is married, then the spouse's reference should point back to person x.
    function invariantMarriage() internal view returns (bool) {
        if (isMarried && getSpouse() != address(0)) {
            Taxpayer sp = Taxpayer(address(getSpouse()));
            return (sp.getSpouse() == address(this));
        }
        return true;
    }

    function invariantPartners() internal view returns (bool) {
        if (isMarried && getSpouse() != address(0)) {
            Taxpayer p1 = Taxpayer(address(partner1));
            Taxpayer p2 = Taxpayer(address(partner2));
            require(
                p1.getSpouse() != address(0) && p2.getSpouse() != address(0),
                "Both partners should be married"
            );
        }
        return true;
    }

    function invariantTaxAllowance() internal view returns (bool) {
        return tax_allowance >= 0;
    }

    function invariantTaxAllowanceAge() internal view returns (bool) {
        if (age >= 65) {
            return tax_allowance == ALLOWANCE_OAP;
        }
        return true; // No violation if age < 65
    }

    function invariantSumTaxAllowances() internal view returns (bool) {
        if (isMarried) {
            Taxpayer spouseContract = Taxpayer(address(spouse));
            return
                tax_allowance + spouseContract.getTaxAllowance() ==
                DEFAULT_ALLOWANCE;
        }
        return true; // No violation if not married
    }

    modifier invariants() {
        _; // do the normal code, then execute my variants
        invariantMarriage();
        invariantPartners();
        invariantTaxAllowance();
        invariantSumTaxAllowances();
        invariantTaxAllowanceAge();
    }

    function marry(address new_spouse) public returns (bool) {
        require(
            new_spouse != getSpouse(),
            "We know your love, but you're already married with this spouse"
        );
        require(
            getSpouse() == address(0) && !isMarried,
            "You're already married"
        );
        require(new_spouse != address(0), "Invalid spouse address");
        setSpouse(address(new_spouse));
        // i prefer to use setter instead of direct assignation, it's safer
        Taxpayer nspouse = Taxpayer(address(getSpouse()));

        nspouse.marry(address(this)); // TODO: fix this line
        isMarried = true;
        return isMarried;
    }

    function setSpouse(address sp) public invariants {
        require(
            (isMarried && sp == address(0)) ||
                (!isMarried && getSpouse() == address(0)),
            "You are already married, you can call this function only for divorce purpose now"
        );
        spouse = (address(sp));
    }

    function divorce() public invariants {
        require(getSpouse() != address(0), "Not married");
        Taxpayer sp = Taxpayer(address(spouse));
        sp.divorce();
        isMarried = false;
        setSpouse((address(0)));
    }

    /* Transfer part of tax allowance to own spouse */
    function transferAllowance(uint change) public invariants {
        require(isMarried, "Not married");
        require(tax_allowance >= change, "Insufficient tax allowance");
        tax_allowance -= change;
        Taxpayer sp = Taxpayer(address(spouse));
        sp.setTaxAllowance(sp.getTaxAllowance() + change);
    }

    function haveBirthday() public invariants {
        age++;
    }

    function getSpouse() public view returns (address) {
        return spouse;
    }

    function setTaxAllowance(uint ta) public invariants {
        tax_allowance = ta;
    }

    function getTaxAllowance() public view returns (uint) {
        return tax_allowance;
    }
}
