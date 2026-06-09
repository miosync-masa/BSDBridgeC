# Branch-Leaf Registry

This note records the V5 lift of the BSD-side typed leaf-identifier
discipline (`BSDLeafId`) to all four currently documented Bridge C
branches. It is the methodology-paper-facing form of the slogan

> Bridge C is not three (or four) disconnected theorem attempts. It
> is one typed leaf-localization language applied to several
> objects.

The four branches are:

- **C-HP** — Hermite–Pochhammer rigidity (substantive Lean content
  in `GaussianWhoWhere`),
- **C-zeta** — Mathlib zeta scaffold (substantive Lean content in
  `GaussianWhoWhere/ZetaBridge`),
- **C-BSD** — the present package's BSD constraint-node branch,
- **C-freezing** — the first-order algebraic / response branch,
  shared between HP/ζ and BSD via the parity-freezing wrapper.

Companion files:

- `BSDBridgeC/Profile/BranchLeafRegistry.lean` — the Lean
  registry implementing the typed branch leaves.
- `BSDBridgeC/Profile/LeafLocalization.lean` — the underlying
  `LeafStatus` / `RefinementLeaf` / `BSDLeafId` machinery.
- `docs/BridgeCGenerality.md` — the three-branch generality
  argument that motivates this lift.

---

## 1. Why HP / ζ / BSD / freezing need a common leaf vocabulary

The V3 / V4 phases produced a powerful leaf-localization vocabulary
for the BSD branch:

- `BSDLeafId` typed identifier,
- partition into `bsd_closedLeafIds` / `bsd_openLeafIds`,
- typed coverage relations (audit, closeability),
- leaf-indexed lookup functions,
- string-registry bridge `BSDLeafId.toRefinementLeaf`.

If the methodology paper claims that Bridge C is a **reusable
typed leaf-localization language**, the language has to apply to
HP and ζ as well — not just BSD. Without a parallel registry on
the other branches, the discipline reduces to a one-off scaffold
for BSD.

V5 Task 1 adds the parallel registry. It does **not** add any
mathematical claim, and in particular does **not** import
`GaussianWhoWhere`. The HP and ζ leaves are recorded as
reference-only labels at the methodology level.

---

## 2. Branch identifiers

The Lean inductive

```
inductive BridgeCMethodBranch where
  | hermitePochhammer
  | zeta
  | bsd
  | freezing
deriving DecidableEq, Repr
```

names the four branches. A generic record

```
structure BranchLeaf where
  branch : BridgeCMethodBranch
  name : String
  status : LeafStatus
  description : String
```

is the common image of all four typed leaf-identifier inductives
below, via four `toBranchLeaf` constructors.

---

## 3. C-HP leaf registry

```
inductive HPLeafId where
  | finitePolynomialRigidity
  | finiteGeneralUniqueness
  | finiteHermitePochhammerReflection
  | finiteP2nRecurrence
  | finiteExponentialTypeClosure
  | logSampleDensity
  | kroneckerDensity
  | realAxisToGlobal
  | logDerivReconstruction
  | functionWhereLift
  | jensenCartwrightLinearZeroBound
```

Status: only `jensenCartwrightLinearZeroBound` is `«open»`. The
other ten constructors are tagged `closed`.

Count theorems (`rfl`):

- `hp_closedLeafIds_count = 10`,
- `hp_openLeafIds_count = 1`,
- `hp_allLeafIds_count = 11`.

The status assignment reflects the `GaussianWhoWhere`
development: every C-HP leaf except the named Jensen socket is
internalized as a closed Lean theorem there. The substantive
content is **not** re-imported here; only the label classification
is recorded.

---

## 4. C-zeta leaf registry

```
inductive ZetaLeafId where
  | dirichletBridgeConcrete
  | completedWherePredicate
  | eulerProductInterface
  | logDerivativeInterface
  | analyticContinuationNotClaimed
  | zeroLocationNotClaimed
```

Status (post-promotion): `dirichletBridgeConcrete`,
`completedWherePredicate`, `eulerProductInterface`, and
`logDerivativeInterface` are `closed`; the two remaining
constructors are `«open»` (explicit non-claims).

The Euler-product and log-derivative leaves were promoted from
`«open»` to `closed` after `GaussianWhoWhere` supplied concrete
Mathlib-backed typed witnesses
(`riemannZeta_eulerProductBridge`,
`riemannZeta_logDerivativeBridge`). `BSDBridgeC` does **not**
import `GaussianWhoWhere`; the status update is a
classification-only change justified by the external repo state
and documented here.

**Important warning.** In this branch, `«open»` is overloaded
relative to the BSD branch's leaf-localization convention.
Here it means *explicit non-claim* (i.e.
`analyticContinuationNotClaimed`,
`zeroLocationNotClaimed`), **not** "frontier-open mathematics".
The scaffold's `«open»` tag is therefore a scaffold-level
taxonomy, not a difficulty claim. This nuance is recorded in
the Lean file's docstring on `ZetaLeafId.status`.

Count theorems (`rfl`):

- `zeta_closedLeafIds_count = 4`,
- `zeta_openLeafIds_count = 2`,
- `zeta_allLeafIds_count = 6`.

---

## 5. C-BSD leaf registry

The BSD branch reuses the existing `BSDLeafId` of
`Profile/LeafLocalization.lean`. V5 adds only the forgetful
conversion

```
def BSDLeafId.toBranchLeaf (id : BSDLeafId) : BranchLeaf := ...
```

which forwards `id.label` to `BranchLeaf.name`, `id.status` to
`BranchLeaf.status`, and the existing description from
`id.toRefinementLeaf.description`. All four V4-layer registries
(typed coverage, closeability coverage, lookup functions,
string-registry bridge) continue to work unchanged.

Counts inherited from
`Profile/LeafLocalization.lean`:

- `bsd_closedLeafIds_count = 4`,
- `bsd_openLeafIds_count = 12`,
- `bsd_fullyRefinedLeafIds_count = 16`.

---

## 6. C-freezing leaf registry

```
inductive FreezingLeafId where
  | pureImagResponseAlgebra
  | hpZetaFirstOrderFreezing
  | bsdParityFreezing
```

Status: all three are `closed`. The freezing branch consists
entirely of small algebraic theorems and `BSDWhereData` /
profile wrappers, all internalized in this package or in
`GaussianWhoWhere`.

Count theorems (`rfl`):

- `freezing_closedLeafIds_count = 3`,
- `freezing_openLeafIds_count = 0`,
- `freezing_allLeafIds_count = 3`.

---

## 7. Combined `BridgeCAnyLeafId`

A sum type collects the four branch identifiers:

```
inductive BridgeCAnyLeafId where
  | hp : HPLeafId → BridgeCAnyLeafId
  | zeta : ZetaLeafId → BridgeCAnyLeafId
  | bsd : BSDLeafId → BridgeCAnyLeafId
  | freezing : FreezingLeafId → BridgeCAnyLeafId
```

with projections `branch`, `status`, and `toBranchLeaf`.

Four lifted lists and one concatenated registry:

- `bridgeC_allHPLeafIds`,
- `bridgeC_allZetaLeafIds`,
- `bridgeC_allBSDLeafIds`,
- `bridgeC_allFreezingLeafIds`,
- `bridgeC_allLeafIds`
  := the concatenation, in branch order.

Total count theorem:

- `bridgeC_allLeafIds_count : bridgeC_allLeafIds.length = 36`
  (= `11 + 6 + 16 + 3`).

A per-branch summary record

```
structure BridgeCBranchLeafProfile where
  branch : BridgeCMethodBranch
  closedCount : ℕ
  openCount : ℕ
  summary : String
```

is instantiated for each branch
(`hp_branchLeafProfile`, `zeta_branchLeafProfile`,
`bsd_branchLeafProfile`, `freezing_branchLeafProfile`) and
collected in `bridgeC_branchLeafProfiles`. Eight consistency
theorems (`*_branchLeafProfile_openCount` /
`*_branchLeafProfile_closedCount` for each branch) fix the
profile counts against the underlying typed lists by `rfl`.

---

## 8. Non-claims

The branch-leaf registry classifies labels; it does **not**
prove any of them. Explicitly:

- We do **not** prove the Riemann Hypothesis.
- We do **not** prove BSD.
- We do **not** discharge `JensenCartwrightLinearZeroBound`.
- We do **not** prove the Euler product, the Bridge A′
  log-derivative passage, analytic continuation of `riemannZeta`,
  or the zero-location of `riemannZeta`.
- We do **not** prove finiteness of Sha, existence of higher
  Euler / Kolyvagin systems for `r ≥ 2`, or any of the BSD
  refined-leaf sockets.
- The Lean file does **not** import `GaussianWhoWhere`. HP and ζ
  leaves are reference-only labels; the substantive Lean content
  for those branches lives in the other package.
- After V's promotion of `eulerProductInterface` and
  `logDerivativeInterface` to `closed`, the C-ζ branch's
  `«open»` tag means *explicit non-claim* (analytic
  continuation, zero-location / RH), **not** frontier-open
  mathematics. This is the only place in the V5 layer where the
  scaffold's `LeafStatus` is overloaded relative to the BSD
  convention, and the overloading is documented at the source.

---

## 9. Methodology slogan

> **The same leaf-localization language is now applied to all
> four documented Bridge C branches.**

The branch-leaf registry is the V5 evidence that Bridge C is not
a one-off BSD scaffold but a reusable typed methodology:

- the `BridgeCMethodBranch` inductive names the four branches,
- each branch has a typed leaf identifier with `closed` /
  `«open»` partition and `rfl`-closed count theorems,
- each branch has a `toBranchLeaf` lift into a common
  `BranchLeaf` record,
- the `BridgeCAnyLeafId` sum type and the
  `bridgeC_branchLeafProfiles` list collect the four branches
  under one registry,
- nothing in this layer discharges any open leaf.

The combined picture closes V5 Task 1: the methodology
language now demonstrably scales across branches at the
type-check level, while every individual branch's open content
remains exactly as open as before.

---

End of Branch-Leaf Registry note.
