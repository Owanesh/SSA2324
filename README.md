# Security in Software Application
![echidna](https://github.com/Owanesh/SSA2324/actions/workflows/main.yml/badge.svg?branch=main)

## Testing with echidna
According to bestpractices of Echidna, we have a new contract that "wrap" `Taxpayer` in order to do assertions and testing.
### How tests are made
```c
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./Taxpayer.sol"; // Replace with the actual path to your contract

contract TaxpayerTesting is Taxpayer {
    constructor() Taxpayer(address(0), address(0)) {
        for (int i = 0; i < 18; i++) {
            haveBirthday();
        }
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
In this case, we want to test that a new `Taxpayer` cannot be created from two addresses that are not on the blockchain. The condition we are going to test is this 
```c
require(
    (p1 == address(0) && p2 == address(0)) ||
        (Taxpayer(p1).getSpouse() == p2 &&
            Taxpayer(p2).getSpouse() == p1),
    "A new born is allowed only form init and married couple"
);
```
So in the test we try to create by passing parent arguments such as `address(1), address(2)`.
### Run Echidna
```sh
# using brew
brew install echidna
echidna . --contract TaxpayerTesting --config echidna.conf.yaml
```

---
![solidity](https://img.shields.io/badge/Solidity-e6e6e6?style=for-the-badge&logo=solidity&logoColor=black)