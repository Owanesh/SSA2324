# Security in Software Application
![echidna](https://github.com/Owanesh/SSA2324/actions/workflows/main.yml/badge.svg?branch=main)

## Testing with echidna
According to bestpractices of Echidna, we have a new contract that "wrap" `Taxpayer` in order to do assertions and testing.
### How tests are made
```c
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
...
```
Some tests needs to operate on `require(<condition>,<reason>)` then our approach is to use `try{}catch{}` statement.
```c
function echidna_block_spawn_of_orphan() public returns (bool) {
    try new Taxpayer(address(1), address(2)) returns (Taxpayer) {
        return false;
    } catch {
        return true;
    }
}
```
In this case, we want to test that a new `Taxpayer` cannot be created from two addresses that are not already deployed on blockchain. The condition we are going to test is this 
```c
// taxpayer.sol
constructor(address p1, address p2) {
    require(
        (p1 == address(0) && p2 == address(0)) ||
            (Taxpayer(p1).getSpouse() == p2 &&
                Taxpayer(p2).getSpouse() == p1),
        "A new born is allowed only form init and married couple"
    );
    ...
}
```
So in the test we try to create by passing parent arguments such as `address(1), address(2)`.
### Run Echidna
```sh
# using brew
brew install echidna
echidna . --contract TaxpayerTesting --config echidna.conf.yaml
```

---
![solidity](https://img.shields.io/badge/Solidity-e6e6e6?style=for-the-badge&logo=solidity&logoColor=black) ![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)