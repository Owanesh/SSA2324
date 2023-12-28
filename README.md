# Security in Software Application

## Testing with echidna
According to bestpractices of Echidna, we have a new contract that "wrap" `Taxpayer` in order to do assertions and testing.

```sh
# using brew
brew install echidna
echidna . --contract TaxpayerTesting --config echidna.conf.yaml
```
---
![solidity](https://img.shields.io/badge/Solidity-e6e6e6?style=for-the-badge&logo=solidity&logoColor=black)