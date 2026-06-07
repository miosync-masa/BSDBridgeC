# BSDBridgeC

`BSDBridgeC` is a Lean 4 / Mathlib scaffold for reading the
Birch--Swinnerton-Dyer conjecture through the same **Bridge C**
methodology developed in the companion `GaussianWhoWhere` project.

The project does **not** prove BSD.  Its purpose is to make the
dependency structure of a BSD-shaped statement inspectable as typed
Lean data: Who-data, Where-data, compatibility sockets, higher-rank
arithmetic sockets, leaf-localization registries, and audit registries.

## What This Repository Claims

The central methodological claim is:

> BSD is not treated here as a solved theorem, but as a typed
> dependency DAG whose remaining open content can be localized,
> audited, and queried by leaf identifier.

The scaffold records:

- heterogeneous BSD Who-data: torsion, Sha, Tamagawa factors,
  regulator, and period;
- central Where-data: an L-function-like object, root number, and
  central Taylor data at `s = 1`;
- Bridge A / A' / B / C socket genealogy;
- higher Euler / Kolyvagin / derivative socket structure;
- rank-one witness routing into the higher-rank socket;
- parity-freezing wrappers for root number `-1`;
- typed leaf identifiers, audit coverage, closeability coverage, and
  typed-to-string registry consistency.

## What This Repository Does Not Claim

This repository deliberately does **not** prove:

- BSD;
- Sha finiteness;
- modularity / Wiles / Taylor-Wiles / BCDT;
- Gross--Zagier or Kolyvagin;
- Iwasawa main conjectures;
- higher Euler-system existence in rank at least two;
- analytic rank equals algebraic rank;
- RH or any zeta zero-location theorem.

Open mathematical content is kept visible as a named `structure` field,
typed socket, or hypothesis.  It is not hidden behind `sorry`,
`admit`, or `axiom`.

## Current V4/V5 Shape

The current development contains:

- a BSD branch with a fully refined typed leaf registry:
  `BSDLeafId`;
- branch-level registries for HP, zeta, BSD, and freezing:
  `BridgeCAnyLeafId`;
- typed coverage from audit entries to leaves:
  `AuditCoverage`;
- typed closeability coverage:
  `CloseabilityCoverage`;
- lookup functions from a typed leaf to its audit status:
  `BSDLeafId.partialClosureAuditStatus`;
- lookup functions from a typed leaf to its closeability status:
  `BSDLeafId.closeabilityStatus`;
- a typed-to-string bridge:
  `BSDLeafId.toRefinementLeaf`;
- a public theorem/definition index in `BSDBridgeC/TheoremMap.lean`
  containing 400+ `#check` entries.

The key slogan is:

> Leaf localization tells us where the boundary lies; closeability
> audit tells us what kind of boundary it is.

## Repository Layout

```text
BSDBridgeC/
  Basic.lean
  WhoWhere/Basic.lean
  Bridges/Basic.lean
  Socket/HigherRank.lean
  Specialization/RankOne.lean
  Freezing/
    Parity.lean
    ProfileParity.lean
  Profile/
    Basic.lean
    Generality.lean
    LeafLocalization.lean
    PartialClosureAudit.lean
    CloseabilityAudit.lean
    BranchLeafRegistry.lean
  TheoremMap.lean
docs/
  BSDSerializationEngine.md
  BranchLeafRegistry.md
  BridgeCGenerality.md
  BuildStrategy.md
  CloseabilityAudit.md
  LeafLocalization.md
  LeanDAG.md
  PartialClosureAudit.md
```

## Important Documents

- [`docs/LeanDAG.md`](docs/LeanDAG.md): file-by-file Lean DAG map.
- [`docs/BridgeCGenerality.md`](docs/BridgeCGenerality.md): HP / zeta /
  BSD / freezing as a common Bridge C methodology.
- [`docs/LeafLocalization.md`](docs/LeafLocalization.md): open/closed
  leaf localization and typed leaf identifiers.
- [`docs/PartialClosureAudit.md`](docs/PartialClosureAudit.md):
  partial closure audit, typed audit coverage, pending audit, and
  lookup functions.
- [`docs/CloseabilityAudit.md`](docs/CloseabilityAudit.md): why selected
  leaves are not currently closed.
- [`docs/BSDSerializationEngine.md`](docs/BSDSerializationEngine.md):
  the "serialization engine" joke corrected into a heterogeneous
  constraint-satisfaction interpretation.
- [`docs/paper.md`](docs/paper.md): working JAR paper draft, expanded
  section by section.

## Building

The project uses Lean `v4.30.0-rc2` and Mathlib at the matching
revision.

```bash
lake update
lake build BSDBridgeC
```

During active development, targeted checks are preferred:

```bash
lake env lean BSDBridgeC/Profile/LeafLocalization.lean
lake env lean BSDBridgeC/Profile/PartialClosureAudit.lean
lake env lean BSDBridgeC/Profile/CloseabilityAudit.lean
lake env lean BSDBridgeC/TheoremMap.lean
```

## Hygiene Checks

```bash
grep -rnE "\bsorry\b|\badmit\b" BSDBridgeC --include="*.lean"
grep -rn "^axiom" BSDBridgeC --include="*.lean"
```

Both should return no Lean-code occurrences.

## Relationship to GaussianWhoWhere

This repository follows the design discipline developed in
`GaussianWhoWhere`, but it does not import that package.  HP and zeta
branches are represented in this package only as reference-only typed
registry leaves.  This keeps the BSD methodology scaffold independent
while preserving a common Bridge C vocabulary.
