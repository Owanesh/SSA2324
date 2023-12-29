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
        require(
            (p1 == address(0) && p2 == address(0)) ||
                (Taxpayer(p1).getSpouse() == p2 &&
                    Taxpayer(p2).getSpouse() == p1),
            "A new born is allowed only form init and married couple"
        );
        age = 0;
        isMarried = false;
        parent1 = p1;
        parent2 = p2;
        spouse = (address(0));
        income = 0;
        tax_allowance = DEFAULT_ALLOWANCE;
    }

    function marry(address new_spouse) public {
        require(age > 16, "You must have at least 16 years old");
        require(new_spouse != address(this), "You cannot marry with yourself");
        require(new_spouse != spouse, "Already married to this spouse");
        require(spouse == address(0) && !isMarried, "Already married");
        require(new_spouse != address(0), "Invalid spouse address");
        require(
            address(Taxpayer(address(new_spouse))).code.length > 0,
            "Invalid spouse, is it already born?" //exploitable if new_spouse has another type of contract
        );
        require(
            Taxpayer(address(new_spouse)).getSpouse() == address(0) ||
                Taxpayer(address(new_spouse)).getSpouse() == address(this),
            "Your partner should be single or not married with another person"
        );
        spouse = new_spouse;
        isMarried = true;
    }

    function divorce() public {
        require(getSpouse() != address(0), "You're not already married");
        Taxpayer sp = Taxpayer(address(spouse));
        require(
            sp.getSpouse() == address(this) && getSpouse() == address(sp),
            "That person isn't married with you"
        );
        require(
            (getTaxAllowance() == DEFAULT_ALLOWANCE && age < 65) ||
                (getTaxAllowance() == ALLOWANCE_OAP && age >= 65),
            "Before divorcing, fix your tax pool allowance"
        );
        sp.setSpouse(address(0));
        spouse = address(0);
        isMarried = false;
        // We should ensure that sp.isMarried become false
        // alpha.marry(bravo)
        // alpha.divorce() :: sets null on both
        // bravo.divorce() :: overrides alpha spouse -- what if alpha in the meanwhile has married another person?
    }

    function setSpouse(address sp) public {
        require(sp != address(this), "You cannot call setSpouse with yourself");
        bool want_to_divorce = sp == address(0);
        require(
            (isMarried && want_to_divorce),
            "You are already married, you can call this function only for divorce purpose now"
        );
        spouse = (address(sp));
    }

    /* Transfer part of tax allowance to own spouse */
    function transferAllowance(uint256 change) public {
        require(
            change > 0,
            "Don't waste gas, save the world, use proper change value"
        );
        require(tax_allowance >= change, "Insufficient tax allowance");
        tax_allowance -= change;
        Taxpayer sp = Taxpayer(address(spouse));
        require(
            sp.getSpouse() == address(this) && getSpouse() == address(sp),
            "You cannot change allowance of person not married with you"
        );
        sp.setTaxAllowance(sp.getTaxAllowance() + change);

        require(
            ((sp.getTaxAllowance() + getTaxAllowance()) ==
                (2 * DEFAULT_ALLOWANCE) &&
                (age < 65 && sp.age() < 65)) ||
                ((sp.getTaxAllowance() + getTaxAllowance()) ==
                    (2 * ALLOWANCE_OAP) &&
                    (age >= 65 && sp.age() >= 65)) ||
                ((sp.getTaxAllowance() + getTaxAllowance()) ==
                    (DEFAULT_ALLOWANCE + ALLOWANCE_OAP) &&
                    (age >= 65 || sp.age() >= 65)),
            "Someone tries to decrease illegally your tax allowance"
        );
    }

    function setTaxAllowance(uint256 ta) public {
        require(
            ta > 0,
            "Don't waste gas, save the world, use proper change value"
        );
        require(
            getSpouse() != address(0),
            "Someone that isn't married with you, tried to change your tax allowance"
        );
        require(
            ta > getTaxAllowance(),
            "Someone tries to decrease illegally your tax allowance"
        );
        require(
            ta <= 2 * DEFAULT_ALLOWANCE ||
                ta <= 2 * ALLOWANCE_OAP ||
                ta <= DEFAULT_ALLOWANCE + ALLOWANCE_OAP,
            "Tax pooling violation"
        );
        tax_allowance = ta;
    }

    function getTaxAllowance() public view returns (uint256) {
        return tax_allowance;
    }

    function haveBirthday() public {
        if(age==64)tax_allowance+=(ALLOWANCE_OAP-DEFAULT_ALLOWANCE); // added line
        age++;
    }

    function getSpouse() public view returns (address) {
        return spouse;
    }

     
}
