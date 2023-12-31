// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Taxpayer {
    uint256 age;
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

    // function wrap_marry(address new_spouse) public {
    //     this.marry(new_spouse);
    //     Taxpayer(address(new_spouse)).marry(address(this));
    // }

    function marry(address new_spouse) public {
        require(age > 16, "You must have at least 16 years old");
        require(
            new_spouse != address(parent1) && new_spouse != address(parent2),
            "You cannoy marry with your parents"
        ); // marriage with siblings is allowed by code
        require(new_spouse != address(this), "You cannot marry with yourself");
        require(new_spouse != getSpouse(), "Already married to this spouse");
        require(
            spouse == address(0) && getIsMarried() == false,
            "Already married"
        );
        require(new_spouse != address(0), "Invalid spouse address");
        require(
            address(Taxpayer(address(new_spouse))).code.length > 0,
            "Invalid spouse, is it already born?" //exploitable if new_spouse has another type of contract
        );
        require(
            (Taxpayer(address(new_spouse)).getSpouse() == address(0) &&
                Taxpayer(address(new_spouse)).getIsMarried() == false) ||
                (Taxpayer(address(new_spouse)).getIsMarried() == true &&
                    Taxpayer(address(new_spouse)).getSpouse() == address(this)),
            "Your partner should be single or not married with another person"
        );
        spouse = new_spouse;
        isMarried = true;
    }

    function divorce() public {
        require(
            getSpouse() != address(0) && getIsMarried(),
            "You're not already married"
        );
        Taxpayer sp = Taxpayer(address(spouse));
        require(
            sp.getSpouse() == address(this) && sp.getIsMarried(),
            "That person isn't married with you"
        );
        require(
            (getTaxAllowance() == DEFAULT_ALLOWANCE && age < 65) ||
                ((getTaxAllowance() == ALLOWANCE_OAP && age >= 65) &&
                    (sp.getTaxAllowance() == DEFAULT_ALLOWANCE && sp.getAge() < 65)) ||
                (sp.getTaxAllowance() == ALLOWANCE_OAP && sp.getAge() >= 65),
            "Before divorcing, fix your tax pool allowance"
        ); 
        /**
            if(getAge()>=65) {setTaxAllowance(ALLOWANCE_OAP);}
            else {setTaxAllowance(DEFAULT_ALLOWANCE);}
         */
        sp.setSpouse(address(0));
        spouse = address(0);
        /*
        sp.divorce(); // instead of sp.setSpouse(address(0));
        */
        isMarried = false;
    }
 

    function setSpouse(address sp) public {
        require(sp != address(this), "You cannot call setSpouse with yourself");
        require(
            (getSpouse() != address(0) && getIsMarried() && sp == address(0)),
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
        require(
            getIsMarried() && getSpouse() != address(0),
            "You have to be married before pooling tax allowance"
        );
        tax_allowance -= change;
        Taxpayer sp = Taxpayer(address(spouse));
        require(
            sp.getSpouse() == address(this) && sp.getIsMarried(),
            "You cannot change allowance of person not married with you"
        );
        sp.setTaxAllowance(sp.getTaxAllowance() + change);
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
        Taxpayer spoused = Taxpayer(address(getSpouse()));
        require(
            ((getAge() < 65 &&
                spoused.getAge() < 65 &&
                ta + spoused.getTaxAllowance() == 2 * DEFAULT_ALLOWANCE) ||
                (getAge() >= 65 &&
                    spoused.getAge() >= 65 &&
                    ta + spoused.getTaxAllowance() == 2 * ALLOWANCE_OAP) ||
                (getAge() < 65 &&
                    spoused.getAge() >= 65 &&
                    ta + spoused.getTaxAllowance() ==
                    DEFAULT_ALLOWANCE + ALLOWANCE_OAP) ||
                (getAge() >= 65 &&
                    spoused.getAge() < 65 &&
                    ta + spoused.getTaxAllowance() ==
                    DEFAULT_ALLOWANCE + ALLOWANCE_OAP)),
            "Tax pooling violation"
        );
        tax_allowance = ta;
    }

    function getTaxAllowance() public view returns (uint256) {
        return tax_allowance;
    }

    function haveBirthday() public {
        age++;
        if (age == 65 && !getIsMarried()) 
            tax_allowance += (ALLOWANCE_OAP - DEFAULT_ALLOWANCE); // added lines
        else if (age == 65 && getIsMarried()) 
            this.setTaxAllowance(this.getTaxAllowance()+(ALLOWANCE_OAP - DEFAULT_ALLOWANCE));
    }

    function getSpouse() public view returns (address) {
        return spouse;
    }
    // added getter functions for code security improvements
    function getAge() public view returns (uint256) {
        return age;
    }

    function getIsMarried() public view returns (bool) {
        return isMarried;
    }
}
