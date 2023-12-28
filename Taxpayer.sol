// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Taxpayer {
    uint age;

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
    bool public pippo;

    constructor(address p1, address p2) {
        age = 0;
        pippo = true;
        isMarried = false;
        partner1 = p1;
        partner2 = p2;
        spouse = address(0);
        income = 0;
        tax_allowance = DEFAULT_ALLOWANCE;
    }

    // We require new_spouse != address(0);
    function marry(address new_spouse) public {
        require(getSpouse() == address(0), "You're already married");
        require(new_spouse != address(0), "Invalid spouse address");
        spouse = new_spouse;
        isMarried = true;
    }

    function divorce() public {
        require(getSpouse() != address(0), "Not married");
        Taxpayer sp = Taxpayer(address(spouse));
        sp.setSpouse(address(0));
        spouse = address(0);
        isMarried = false;
    }

    /* Transfer part of tax allowance to own spouse */
    function transferAllowance(uint change) public {
        require(isMarried, "Not married");
        require(tax_allowance >= change, "Insufficient tax allowance");
        tax_allowance -= change;
        Taxpayer sp = Taxpayer(address(spouse));
        sp.setTaxAllowance(sp.getTaxAllowance() + change);
    }

    function haveBirthday() public {
        age++;
    }

    function setSpouse(address sp) public {
        require(isMarried, "You have to divorce before another marriage");
        spouse = sp;
    }

    function getSpouse() public view returns (address) {
        return spouse;
    }

    function setTaxAllowance(uint ta) public {
        tax_allowance = ta;
    }

    function getTaxAllowance() public view returns (uint) {
        return tax_allowance;
    }
}
