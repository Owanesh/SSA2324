// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./Taxpayer.sol"; 

contract TaxpayerTesting is Taxpayer {
    uint constant ADULT_AGE = 18;
    uint constant ADULT_OLD_AGE = 65;
    Taxpayer alpha;
    Taxpayer bravo;

    constructor() Taxpayer(address(0), address(0)) {
        alpha = new Taxpayer(address(0), address(0));
        bravo = new Taxpayer(address(0), address(0));
        for (uint i = 0; i < ADULT_AGE; i++) {
            alpha.haveBirthday();
            bravo.haveBirthday();
        }
        bravo.marry(address(alpha));
        alpha.marry(address(bravo));
    }

    function be_old(Taxpayer tp) internal returns (Taxpayer) {
        for (uint i = 0; i < ADULT_OLD_AGE; i++) {
            tp.haveBirthday();
        }
        return tp;
    }

    function be_adult(Taxpayer tp) internal returns (Taxpayer) {
        for (uint i = 0; i < ADULT_AGE; i++) {
            tp.haveBirthday();
        }
        return tp;
    }

    function echidna_couple_make_a_baby() public returns (bool) {
        try new Taxpayer(address(alpha), address(bravo)) {
            return true;
        } catch {
            return false;
        }
    }

    function echidna_couple_make_a_baby_and_alpha_wants_marry_parents()
        public
        returns (bool)
    {
        try new Taxpayer(address(alpha), address(bravo)) returns (
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

    function echidna_simple_marry() public view returns (bool) {
        bool alpha_to_bravo = alpha.getSpouse() == address(bravo) &&
            alpha.getSpouse() != address(0);
        return alpha_to_bravo;
    }

    function echidna_both_married() public view returns (bool) {
        bool alpha_to_bravo = alpha.getSpouse() == address(bravo) &&
            alpha.getSpouse() != address(0);
        bool bravo_to_alpha = bravo.getSpouse() == address(alpha) &&
            bravo.getSpouse() != address(0);
        return alpha_to_bravo && bravo_to_alpha;
    }

    function echidna_divorce() public returns (bool) {
        bravo.divorce();
        bool alpha_is_divorced = alpha.getSpouse() == address(0) &&
            alpha.getIsMarried();
        bool bravo_is_divorced = bravo.getSpouse() == address(0) &&
            !bravo.getIsMarried();
        return alpha_is_divorced && bravo_is_divorced;
    }

    function echidna_block_spawn_of_orphan() public returns (bool) {
        try new Taxpayer(address(1), address(2)) returns (Taxpayer) {
            return false;
        } catch {
            return true;
        }
    }

    function echidna_have_birthday() public returns (bool) {
        require(alpha.getAge() == ADULT_AGE, "Failed to spawn as adult");
        alpha.haveBirthday();
        return alpha.getAge() == ADULT_AGE + 1;
    }

    function echidna_cannot_marry_until_sixteen() public returns (bool) {
        alpha.divorce();
        Taxpayer delta = new Taxpayer(address(0), address(0));
        try delta.marry(address(alpha)) {
            return false;
        } catch {
            for (int i = 0; i < 17; i++) {
                delta.haveBirthday();
            }
            delta.marry(address(alpha));
            return delta.getSpouse() == address(alpha);
        }
    }

    function echidna_cannot_divorce_if_tax_pooling() public returns (bool) {
        uint256 TAX_ALLOWANCE_TRANFERRED = 500;
        alpha.transferAllowance(TAX_ALLOWANCE_TRANFERRED);
        try alpha.divorce() {
            return false;
        } catch {
            bravo.transferAllowance(TAX_ALLOWANCE_TRANFERRED);
            return alpha.getTaxAllowance() == DEFAULT_ALLOWANCE;
        }
    }

    function echidna_transfer_huge_amount_of_allowance() public returns (bool) {
        try alpha.transferAllowance(40000) {
            return false;
        } catch {
            return true;
        }
    }

    function echidna_transfer_allowance() public returns (bool) {
        alpha.transferAllowance(4000);
        return
            bravo.getTaxAllowance() + alpha.getTaxAllowance() ==
            2 * DEFAULT_ALLOWANCE;
    }

    function echidna_allowance_older_than_sixtyfive_for_both()
        public
        returns (bool)
    {
        be_old(bravo);
        be_old(alpha);
        alpha.transferAllowance(2000);
        return
            bravo.getTaxAllowance() + alpha.getTaxAllowance() ==
            ALLOWANCE_OAP + ALLOWANCE_OAP;
    }

    function echidna_allowance_older_than_sixtyfive_for_only_one()
        public
        returns (bool)
    {
        be_old(bravo);
        alpha.transferAllowance(2000);
        return
            bravo.getTaxAllowance() + alpha.getTaxAllowance() ==
            DEFAULT_ALLOWANCE + ALLOWANCE_OAP;
    }
}
