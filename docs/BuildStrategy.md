# BSD Bridge C Build Strategy

## North Star

This package does not prove BSD.  It maps the open BSD socket into a
typed Lean DAG.

The contribution is:

```text
opaque gap
  → named structures
  → visible fields
  → conditional composition theorems
```

The hard higher-rank region remains visible as:

```lean
HigherRankSocket E r := Nonempty (HigherRankArithmeticBridge E r)
```

For `r ≥ 2`, this socket is never proved in the scaffold.

## Current Levels

| Level | File | Status |
| --- | --- | --- |
| D0 | `BSDBridgeC/Basic.lean` | abstract objects and rank names |
| D1 | `Specialization/RankOne.lean` | rank-one bridge from explicit Heegner witness |
| D2 | `Freezing/Parity.lean` | root number `-1` forces central vanishing |
| D3 | `Socket/HigherRank.lean` | Euler/Kolyvagin/derivative socket genealogy |
| D4 | `HigherRankSocket` | open for `r ≥ 2`, by design |

## Non-Claims

This package does not claim:

* Sha finiteness,
* computation of Sha,
* BSD,
* higher Euler-system existence in rank at least two,
* modularity from first principles,
* equality of analytic rank and algebraic rank.

All of these appear, when needed, as named fields or hypotheses.
