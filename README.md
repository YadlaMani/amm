# AMM (Automated Market Maker) — Technical Overview

Purpose

- Minimal AMM implementation with a focus on the core mathematical models used for swaps and liquidity.

Math Overview

- Invariant: Constant-product (Uniswap-style)

  - Let reserves be x (token A) and y (token B). The pool maintains x \* y = k (constant), modulo fees.

- Swap (exact-in) formula

  - fee: f (fraction, e.g. 0.003 for 0.3%).
  - amountInWithFee = amountIn \* (1 - f)
  - amountOut = (amountInWithFee \* reserveOut) / (reserveIn + amountInWithFee)
  - Equivalent algebra follows from preserving the invariant when accounting for the retained fee.

- Swap (exact-out) formula (solve for amountIn)

  - amountIn = (reserveIn \* amountOut) / (reserveOut - amountOut)
  - then adjust for fee: amountIn = amountIn / (1 - f) (rounding handled by integer arithmetic).

- Liquidity provisioning

  - When totalSupply == 0: liquidity = sqrt(amountA \* amountB) (minus any minimum liquidity constant).
  - Otherwise: liquidityMinted = min(amountA _ totalSupply / reserveA, amountB _ totalSupply / reserveB)

- Price and slippage
  - instantaneous price (A in terms of B): p = reserveB / reserveA
  - after a trade the new price p' = (reserveB - amountOut) / (reserveA + amountInWithFee)
  - price impact (relative) ≈ |p' / p - 1|

Numerical & precision details

- All arithmetic is integer (Solidity). The code assumes token amounts use 18-decimal precision (1e18 fixed-point). Implementations use scaled integers and explicit rounding rules to avoid floating-point.
- Square root is implemented via an integer Babylonian method (common for LP minting calculations).

Supported contract-level functions (conceptual)

- `getReserves() -> (reserveA, reserveB)` : read current pool reserves.
- `getAmountOut(amountIn, reserveIn, reserveOut, fee) -> amountOut` : compute exact-out for an exact-in swap.
- `getAmountIn(amountOut, reserveIn, reserveOut, fee) -> amountIn` : compute required amountIn to receive amountOut.
- `swapExactIn(amountIn, minAmountOut)` : perform swap using `getAmountOut` and enforce `minAmountOut`.
- `swapExactOut(amountOut, maxAmountIn)` : perform swap by computing `getAmountIn` and enforcing `maxAmountIn`.
- `addLiquidity(amountA, amountB) -> liquidityMinted` : deposit assets and mint LP tokens proportional to provided amounts.
- `removeLiquidity(liquidity) -> (amountA, amountB)` : burn LP tokens and withdraw proportional reserves.
- `price() -> (pAinB, pBinA)` : convenience accessor for current pool price(s).

Implementation notes

- Integer math only: avoid floating-point. The code uses scaled integers (1e18) and careful rounding.
- Fee is applied on input amount prior to updating reserves.
- Use of `min()` and `sqrt()` is required for correct LP accounting.
- Edge cases: zero-reserve bootstrapping, tiny swaps that round to zero, and division-by-zero protections are handled explicitly in the contract.

Repository layout (short)

- `src/` — Solidity contracts (AMM, Token)
- `test/` — unit tests (see repository tests for coverage)
