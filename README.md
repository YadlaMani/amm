# AMM (Automated Market Maker)

This repository contains a simple Automated Market Maker (AMM) implementation and accompanying tests using Foundry.

Goals:

- Provide a minimal, well-tested AMM contract set.
- Use Foundry for fast local development and testing.

Requirements

- Foundry (forge, anvil, cast) installed and available on your PATH.

Quick start

- Clone the repo and run the following from the project root:

```bash
git clone https://github.com/YadlaMani/amm
cd amm
forge build
forge test
```

Common commands

- `forge build` — compile contracts
- `forge test` — run the test suite
- `forge fmt` — format Solidity sources
- `anvil` — run a local node for manual testing

Project layout

- `src/` — Solidity contracts (AMM, tokens, utilities)
- `test/` — Foundry tests
- `script/` — deployment and helper scripts
- `lib/` — external libraries and dependencies
- `foundry.toml` — Foundry configuration

Testing

- Tests are written for Foundry. Run `forge test` to execute them locally.

Contributing

- Run the test suite and ensure formatting before opening a PR:

```bash
forge fmt
forge test
```
# amm
