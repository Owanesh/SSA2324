// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./Taxpayer.sol"; // Replace with the actual path to your contract

contract TaxpayerTesting is Taxpayer {
    constructor() Taxpayer(address(0), address(0)) {
        for (int i = 0; i < 20; i++) {
            haveBirthday();
        }
    }

    function be_adult(Taxpayer tp) internal returns (Taxpayer) {
        for (int i = 0; i < 18; i++) {
            tp.haveBirthday();
        }
        return tp;
    }

    function spawn_a_person(bool adult) internal returns (Taxpayer) {
        Taxpayer bravo = new Taxpayer(address(0), address(0));
        if (adult) {
            bravo = be_adult(bravo);
        }
        return bravo;
    }

    function marry_two_person(Taxpayer p1, Taxpayer p2) internal {
        require(
            p1.age() > 16 && p2.age() > 16,
            "To get married you must have at least 16 years old"
        );
        p1.marry(address(p2));
        p2.marry(address(p1));
    }

    function echidna_couple_make_a_baby() public returns (bool) {
        Taxpayer bravo = spawn_a_person(true);
        marry_two_person(bravo, this);
        try new Taxpayer(address(this), address(bravo)) {
            return true;
        } catch {
            return false;
        }
    }

    function echidna_couple_make_a_baby_and_this_wants_marry_parents()
        public
        returns (bool)
    {
        Taxpayer bravo = spawn_a_person(true);
        marry_two_person(bravo, this);
        try new Taxpayer(address(this), address(bravo)) returns (
            Taxpayer result
        ) {
            result = be_adult(result);
            try result.marry(address(bravo)) {
                return false;
            } catch {
                return true;
            }
        } catch {
            return false;
        }
    }

    function echidna_one_way_marriage() public returns (bool) {
        Taxpayer bravo = spawn_a_person(true);
        this.marry(address(bravo));
        bool this_to_bravo = this.getSpouse() == address(bravo) &&
            this.getSpouse() != address(0);
        return this_to_bravo;
    }

    function echidna_both_married() public returns (bool) {
        Taxpayer bravo = spawn_a_person(true);
        this.marry(address(bravo));
        bravo.marry(address(this));
        bool this_to_bravo = this.getSpouse() == address(bravo) &&
            this.getSpouse() != address(0);
        bool bravo_to_this = bravo.getSpouse() == address(this) &&
            bravo.getSpouse() != address(0);
        return this_to_bravo && bravo_to_this;
    }

    function echidna_divorce() public returns (bool) {
        Taxpayer bravo = spawn_a_person(true);
        this.marry(address(bravo));
        bravo.marry(address(this));
        bravo.divorce();
        bool this_divorced = this.getSpouse() == address(0);
        bool bravo_divorced = bravo.getSpouse() == address(0);
        return this_divorced && bravo_divorced;
    }

    function echidna_block_spawn_of_orphan() public returns (bool) {
        try new Taxpayer(address(1), address(2)) returns (Taxpayer) {
            return false;
        } catch {
            return true;
        }
    }

    function echidna_have_birthday() public returns (bool) {
        uint initialAge = this.age();
        this.haveBirthday();
        require(this.age() == initialAge + 1, "Failed to increment age");
        return this.age() == initialAge + 1;
    }

    function echidna_cannot_marry_until_sixteen() public returns (bool) {
        Taxpayer delta = spawn_a_person(false);
        this.marry(address(delta));
        try delta.marry(address(this)) {
            return false;
        } catch {
            for (int i = 1; i < 16; i++) {
                delta.haveBirthday();
            }
            return this.getSpouse() == address(delta);
        }
    }

    function echidna_cannot_divorce_if_tax_pooling() public returns (bool) {
        Taxpayer bravo = spawn_a_person(true);
        this.marry(address(bravo));
        bravo.marry(address(this));
        uint256 TAX_ALLOWANCE_TRANFERRED = 500;
        this.transferAllowance(TAX_ALLOWANCE_TRANFERRED);
        try this.divorce() {
            return false;
        } catch {
            bravo.transferAllowance(TAX_ALLOWANCE_TRANFERRED);
            return this.getTaxAllowance() == DEFAULT_ALLOWANCE;
        }
    }

    function echidna_transferallowance() public returns (bool) {
        Taxpayer bravo = spawn_a_person(true);
        this.marry(address(bravo));
        bravo.marry(address(this));
        this.transferAllowance(400);
        return
            bravo.getTaxAllowance() + this.getTaxAllowance() ==
            2 * DEFAULT_ALLOWANCE;
    }
}
