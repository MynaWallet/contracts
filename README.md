# MynaWallet

## Overview

MynaWallet smart contract is a contract account that complies with [ERC-4337](https://eips.ethereum.org/EIPS/eip-4337). It approves operations described in `UserOperation` by verifying RSA signatures.

## Preparation

The MynaWallet smart contract is developed using [Foundry](https://book.getfoundry.sh/getting-started/installation). Please build the [Foundry](https://book.getfoundry.sh/getting-started/installation) development environment according to the procedures in the linked page.

Make a copy of `.env.sample` and name it `.env`. Then, please set the environment variables according to the comments in the file. Please do not edit `.env.sample` directly as it is a sample file.

```bash
cp .env.sample .env
# Then edit .env
```

## Development

## Compile

```bash
forge build --sizes
```

## Test

### with printing execution traces for failing tests

```bash
forge test --vvv
```

### with gas report

```bash
forge test --gas-report
```
