# BSD Bridge C Lean DAG

This document maps the file-by-file Lean structure of the
`BSDBridgeC` package. It is the BSD-side counterpart of the Lean DAG
appendix used in the `GaussianWhoWhere` development. It describes
what each file declares and depends on; it does not prove anything,
and it does not advance any mathematical claim beyond what the source
itself records.

A separate document, `docs/BSDSerializationEngine.md`, gives the
prose-level reading of why the Lean DAG is shaped the way it is.

---

## 0. Global policy

The entire package operates under the following invariants:

- no `sorry`,
- no `admit`,
- no `axiom`,
- every open mathematical statement appears as a named structure
  field or as an explicit hypothesis in a theorem signature,
- rank `≥ 2` higher-rank arithmetic bridges remain open: their
  inhabitation is consumed as a hypothesis, never discharged,
- modularity, finiteness of `Sha`, Gross–Zagier, Kolyvagin systems
  for `r ≥ 2`, the Iwasawa main conjecture, and the BSD formula
  itself are **not** proved by this package.

A repository search confirms no occurrences of `sorry`, `admit`, or
`axiom` keywords in any `.lean` file of the package.

---

## 1. Package root

### `BSDBridgeC.lean`

Role: root aggregator. Imports every public-facing module so that a
downstream client can `import BSDBridgeC` and see the entire surface.

Current imports (in dependency order):

- `BSDBridgeC.Basic`
- `BSDBridgeC.WhoWhere.Basic`
- `BSDBridgeC.Bridges.Basic`
- `BSDBridgeC.Socket.HigherRank`
- `BSDBridgeC.Specialization.RankOne`
- `BSDBridgeC.Freezing.Parity`
- `BSDBridgeC.Profile.Basic`
- `BSDBridgeC.Freezing.ProfileParity`
- `BSDBridgeC.TheoremMap`

---

## 2. Basic placeholders

### `BSDBridgeC/Basic.lean`

Role: abstract foundational objects. Every type here is intentionally
lightweight; a future arithmetic-geometry-level instantiation would
replace each with a concrete Mathlib counterpart.

Key declarations:

- `EllipticCurveLike`
- `GaloisRep`
- `TateModule : EllipticCurveLike → GaloisRep`
- `H1 (K : Type) (T : GaloisRep) : Type`
- `SelmerQuotient (n : ℕ) (T : GaloisRep) : Type`
- `WedgePower (r : ℕ) (M : Type) : Type`
- `AnalyticRank`, `AlgebraicRank`, `CoreRank` (distinct `ℕ`
  abbreviations, deliberately not unified)
- `RankAgreement (analytic algebraic : ℕ) : Prop`

Boundary: the three rank names are not silently identified. Any
identification between analytic, algebraic, and core ranks must be
supplied as a hypothesis (`RankAgreement`).

---

## 3. Who / Where layer

### `BSDBridgeC/WhoWhere/Basic.lean`

Role: heterogeneous Who data, central Where data, and a named
compatibility socket between them. Also provides the three
forgetful packaging bundles used by the constraint-triangle
narrative.

Component data types:

- `TorsionData`, `ShaData`, `TamagawaData`, `RegulatorData`,
  `PeriodData`,
- `BSDWhoData` (the five-field heterogeneous Who package),
- `CentralTaylorData`,
- `BSDWhereData` (`L`, `rootNumber`, `centralTaylor`,
  `functionalEquationAtCenter`),
- `BSDWhoWhereCompatible who where_` (the two-socket
  compatibility witness).

Constants and predicates:

- `bsdCenter : ℂ` (`= 1`),
- `BSDWhoHeterogeneousBundle`, `BSDWhereCentralBundle`,
  `BSDCompatibilitySocketBundle` — `Type`-side packaging
  structures.

Forgetful constructors:

- `bsdWhoData_to_heterogeneousBundle`,
- `bsdWhereData_to_centralBundle`,
- `bsdWhoWhereCompatible_to_socketBundle`,
- `bsdWhoWhereCompatible_socketPair : (Prop × Prop)`.

Field projections (15 total):

Who side:
`bsdWhoData_has_torsion`, `bsdWhoData_has_sha`,
`bsdWhoData_has_tamagawa`, `bsdWhoData_has_regulator`,
`bsdWhoData_has_period`.

Where side:
`centralTaylor_order`, `centralTaylor_leadingCoeff`,
`bsdWhereData_has_L`, `bsdWhereData_has_rootNumber`,
`bsdWhereData_has_centralTaylor`,
`bsdWhereData_has_functionalEquationSocket`.

Compatibility:
`bsdWhoWhereCompatible_has_leadingCoefficientFormula`,
`bsdWhoWhereCompatible_has_rankOrderCompatibility`,
`compatible_leading_formula`.

Meaning: Who = (torsion, Sha, Tamagawa, regulator, period); Where =
(L, root number, central Taylor data, functional-equation socket);
Compatibility = (leading-coefficient formula socket, rank/order
compatibility socket). All sockets are `Prop` values forwarded from
the source structures.

### 3.1 V3 Sha decomposition

The V2 `ShaData` carries only `order : ℕ`. The V3 refinement of
`WhoWhere/Basic.lean` decomposes the Sha leaf into a Selmer/Sha
exact-sequence package without proving exactness or Sha finiteness:

- `MordellWeilLike`, `SelmerGroupLike`, `ShaTorsionLike` — three
  abstract carriers.
- `SelmerShaExactPackage E n` — `Type`-side bundle of the three
  carriers plus three named `Prop` sockets:
  `injection_socket`, `surjection_socket`, `exactness_socket`.
- `ShaDataV3 E` — `Type`-side bundle: `shaCarrier`, indexed
  `torsionAt`, indexed `selmerShaPackage`, and a single
  `finiteSocket : Prop`.
- `ShaDataWithOrderV3 E extends ShaDataV3 E` — adds `order : ℕ`
  for the V3 → V2 forgetful map.
- `shaData_of_v3 : ShaDataWithOrderV3 E → ShaData` — forgetful
  migration.

Projection ergonomics include `shaDataV3_carrier`,
`shaDataV3_torsionAt`, `shaDataV3_selmerShaPackage`,
`shaDataV3_finiteSocket`, plus six `selmerShaExactPackage_*`
projections.

Boundary: Sha finiteness, exactness, and existence of the typed
carriers in any concrete arithmetic-geometry sense are all
**not** asserted. The V2 → V3 direction is **not** provided.

---

## 4. Bridge layers

### `BSDBridgeC/Bridges/Basic.lean`

Role: Bridge A / A′ / B / C socket genealogy. Each bridge is a
`structure` whose fields name exactly what an external supply would
have to provide.

Structures:

- `ModularitySocket E` — one socket field.
- `BridgeA_Encode E where_` — modularity socket + Euler-product
  model + Dirichlet model.
- `BridgeAprime_LogDeriv where_` — log-derivative model +
  pole/residue encoding.
- `IwasawaMainSocket E` — characteristic-ideal comparison socket.
- `BridgeB_Decode E who where_` — Iwasawa-main socket +
  Taylor-to-arithmetic + normalization compatibility.
- `BridgeC_Rigidity E who where_` — `whoWhere`, `encode`, `decode`,
  `logDeriv` sub-bridge fields.

Sub-bridge projections (11 total, exposed at this layer):

Bridge A (3): `bridgeA_has_modularity`,
`bridgeA_has_eulerProductModel`, `bridgeA_has_dirichletModel`.

Bridge A′ (2): `bridgeAprime_has_logDerivativeModel`,
`bridgeAprime_has_poleResidueEncoding`.

Bridge B (3): `bridgeB_has_iwasawaMain`,
`bridgeB_has_taylorToArithmetic`,
`bridgeB_has_normalizationCompatibility`.

Bridge C sub-bridges (3): `bridgeC_has_encode`, `bridgeC_has_decode`,
`bridgeC_has_logDeriv`. (`bridgeC_has_who_where` existed prior to
this layer expansion and is preserved.)

Boundary: none of the socket fields is discharged in this file. Each
projection returns the field verbatim.

---

## 5. Higher-rank sockets

### `BSDBridgeC/Socket/HigherRank.lean`

Role: the higher Euler / Kolyvagin / derivative socket family and
its arithmetic-bridge bundle.

Structures:

- `HigherEulerSystem T r` — indexed wedge classes + norm
  compatibility socket.
- `HigherKolyvaginSystem T r` — indexed wedge classes in
  `SelmerQuotient` + local-relations socket.
- `HigherKolyvaginDerivative ES KS` — derivative-law socket
  (Bridge D in the BSD literature, not to be confused with the BSD
  formula).
- `HigherRankArithmeticBridge E r` — `ES`, `KS`, `D`, plus
  regulator, Selmer, and core/BSD-rank-matching sockets.
- `HigherRankSocket E r : Prop` — defined as
  `Nonempty (HigherRankArithmeticBridge E r)`; this is the visible
  socket that downstream theorems consume as a hypothesis.
- `HigherRankSocketBundle E r` — `Type`-side packaging structure
  with the same six-field shape.

Projections (9 internal + 3 top-level = 12):

Bridge-level (3): `higherRankBridge_has_eulerSystem`,
`higherRankBridge_has_kolyvaginSystem`,
`higherRankBridge_has_derivative`.

ES internal (2): `higherEulerSystem_classes`,
`higherEulerSystem_normCompatibility`.

KS internal (2): `higherKolyvaginSystem_classes`,
`higherKolyvaginSystem_localRelations`.

D internal (1): `higherKolyvaginDerivative_law`.

Remaining socket fields (3):
`higherRankBridge_has_regulatorCompatibility`,
`higherRankBridge_has_selmerControl`,
`higherRankBridge_has_coreRankMatchesBSDRank`.

Bundle constructor (1): `higherRankBridge_to_socketBundle`.

Boundary: `HigherRankSocket E r` is **not** discharged for `r ≥ 2`.
The development never produces a term of this type without being
given the underlying bridge as input.

### 5.1 V3 higher-rank decomposition

The V2 `HigherRankArithmeticBridge` carries three bare-`Prop`
socket fields (`regulator_compatibility`, `selmer_control`,
`core_rank_matches_bsd_rank`). V3 refines them into named
sub-socket structures and rebuilds the socket non-destructively:

- `RegulatorCompatibility E r ES` — wraps `compatibility_law : Prop`.
- `SelmerControl E r KS` — wraps `control_law : Prop`.
- `CoreRankBSDRankCompatibility E r` — wraps three rank values
  plus `core_matches_algebraic : Eq` (definite identification of
  core and algebraic rank) and `analytic_matches_algebraic : Prop`
  (BSD rank-equality socket, undischarged).
- `HigherRankSocketStructure E r` — decomposed `Type`-side
  structure with the three sub-socket fields in place.
- `HigherRankSocketV3 E r : Prop :=
   Nonempty (HigherRankSocketStructure E r)`.

V3 → V2 migration is one-way:

- `higherRankSocketStructure_to_arithmeticBridge` — V3 socket
  structure → V2 arithmetic bridge.
- `higherRankSocket_of_v3 : HigherRankSocketV3 E r →
   HigherRankSocket E r`.

Six V3 projections (`higherRankSocketStructure_has_*`) round out
the layer.

Boundary: V3 → V2 forgetful direction only. **V2 → V3 is not
provided** (V2 lacks the structural information needed to
reconstruct V3's named sub-sockets).

---

## 6. Rank-one specialization

### `BSDBridgeC/Specialization/RankOne.lean`

Role: the closure of the higher socket at `r = 1`. A `Heegner` /
`Kolyvagin`-style witness is supplied as data; the rank-one socket
follows mechanically. Gross–Zagier and Kolyvagin's theorems are
**not** proved.

Data type:

- `RankOneHeegnerWitness E` — six fields mirroring
  `HigherRankArithmeticBridge E 1`.

Top-level closures:

- `rankOneArithmeticBridge_of_heegnerWitness :
   RankOneHeegnerWitness E → HigherRankArithmeticBridge E 1`,
- `higherRankSocket_rankOne_of_heegnerWitness :
   RankOneHeegnerWitness E → HigherRankSocket E 1`.

Witness-internal projections (6):
`rankOneHeegnerWitness_has_eulerSystem`,
`rankOneHeegnerWitness_has_kolyvaginSystem`,
`rankOneHeegnerWitness_has_derivative`,
`rankOneHeegnerWitness_has_regulatorCompatibility`,
`rankOneHeegnerWitness_has_selmerControl`,
`rankOneHeegnerWitness_has_coreRankMatchesBSDRank`.

Bundles:

- `RankOneWitnessBundle E` — `Type`-side six-field bundle,
- `rankOneHeegnerWitness_to_bundle :
   RankOneHeegnerWitness E → RankOneWitnessBundle E`,
- `rankOneHeegnerWitness_to_higherRankSocketBundle :
   RankOneHeegnerWitness E → HigherRankSocketBundle E 1`
  (composition with `higherRankBridge_to_socketBundle`).

Boundary: the existence of `RankOneHeegnerWitness E` for a given
elliptic curve is a hypothesis. No theorem in this file produces one
unconditionally.

### 6.1 V3 rank-one Heegner witness

The V3 refinement adds a witness layer that mirrors
`HigherRankSocketStructure` at `r = 1`:

- `RankOneHeegnerWitnessV3 E` — six-field structure with named
  `RegulatorCompatibility`, `SelmerControl`,
  `CoreRankBSDRankCompatibility` sub-sockets in place of bare
  `Prop`s.
- `rankOneHeegnerWitnessV3_to_higherRankSocketStructure` —
  V3 witness → `HigherRankSocketStructure E 1`.
- `higherRankSocketV3_rankOne_of_heegnerWitnessV3` —
  V3 witness → `HigherRankSocketV3 E 1`.
- `rankOneHeegnerWitness_of_v3` — V3 witness → V2 witness
  (forgetful).
- `rankOneHeegnerWitnessV3_to_arithmeticBridge` — V3 witness →
  V2 arithmetic bridge at rank 1.
- `higherRankSocket_rankOne_of_heegnerWitnessV3` — V3 witness →
  V2 `HigherRankSocket E 1` via the V3-to-V2 composition.
- `RankOneWitnessBundleV3 E` + `rankOneHeegnerWitnessV3_to_bundleV3`
  — `Type`-side bundle and forgetful constructor.

Six V3 projections (`rankOneHeegnerWitnessV3_has_*`) parallel the
V3 socket-structure projections.

Boundary: Gross–Zagier and Kolyvagin's theorems remain
unproved. The V3 → V2 direction is provided; the **V2 → V3
direction is not**, by the same structural argument as in §5.1.

---

## 7. Parity freezing

### `BSDBridgeC/Freezing/Parity.lean`

Role: the algebraic root-number consequence. If a center-`1`
functional equation has sign `−1`, the center value vanishes.

Definitions and theorems:

- `RootNumberFunctionalEquation (L : ℂ → ℂ) (w : ℂ) : Prop`
  — `∀ t, L (1 + t) = w * L (1 - t)`.
- `bsd_where_rootNumber_forces_centralZero` — the closed algebraic
  theorem: sign `−1` ⇒ `L 1 = 0`. The proof uses only ring
  algebra on `ℂ`.
- `bsd_where_sign_neg_one_forces_vanishing` — application-flavored
  alias of the previous theorem.
- `BSDWhereHasNegativeRootFunctionalEquation W` — the
  `BSDWhereData`-level predicate: `W.rootNumber = -1 ∧
  RootNumberFunctionalEquation W.L (-1)`.
- `bsdWhereData_centralZero_of_negativeRootFunctionalEquation` —
  Where-layer wrapper: under the above predicate, `W.L 1 = 0`.

Boundary: the functional equation itself is not proved. It is a
component of the named predicate; the wrapper takes it as a
hypothesis.

### `BSDBridgeC/Freezing/ProfileParity.lean`

Role: profile-level wrapper. A separate file is used to avoid a
circular import between `Profile.Basic` and `Freezing.Parity`.

Definitions and theorems:

- `BSDBridgeCProfileHasNegativeRootFunctionalEquation P` :=
  `BSDWhereHasNegativeRootFunctionalEquation P.where_`.
- `bsdBridgeCProfile_centralZero_of_negativeRootFunctionalEquation`
  — profile-level central-zero conclusion under the same
  hypothesis.

---

## 8. Profile and constraint triangle

### `BSDBridgeC/Profile/Basic.lean`

Role: top-level BSD profile that bundles a curve-like object, Who
and Where data, the Bridge C rigidity package, and an
identity-forwarding higher-rank socket hypothesis.

Structure and primary projections:

- `BSDBridgeCProfile` — fields `E`, `who`, `where_`, `bridgeC`,
  `higherRankSocket`.
- `bsdBridgeCProfile_has_bridgeC`,
  `bsdBridgeCProfile_has_whoWhere`.

Bridge sub-layer projections (3):
`bsdBridgeCProfile_has_encode`,
`bsdBridgeCProfile_has_decode`,
`bsdBridgeCProfile_has_logDeriv`.

Higher-rank hypothesis projection (1):
`bsdBridgeCProfile_has_higherRankSocket_as_hypothesis` — receives
the rank-`r` socket as a hypothesis and returns it unchanged. The
profile does not discharge the socket.

Rank-one alias (1):
`rankOneProfileSocket_of_heegnerWitness :
 RankOneHeegnerWitness E → HigherRankSocket E 1`.

Constraint triangle:

- `bsdBridgeCProfile_whoBundle`,
- `bsdBridgeCProfile_whereBundle`,
- `bsdBridgeCProfile_compatibilityBundle`,
- `BSDConstraintTriangle P` — `Type`-side three-field bundle
  indexed by a profile,
- `bsdBridgeCProfile_constraintTriangle :
   (P : BSDBridgeCProfile) → BSDConstraintTriangle P`.

The constraint triangle is the Lean witness of the
constraint-satisfaction reading described in
`docs/BSDSerializationEngine.md` §3.

### 8.1 Leaf localization

`BSDBridgeC/Profile/LeafLocalization.lean` records the typed
dependency DAG's bottom-level classification: every closure-leaf
of the BSD branch is tagged `closed` (intended to connect to
Mathlib / concrete data / finite computation) or `«open»`
(a genuine unsolved socket).

Core types:

- `LeafStatus` (`.closed` / `.«open»`, the latter escaped because
  `open` is a Lean keyword);
- `RefinementLeaf` — name + status + description;
- `LeafLocalizationProfile` — branch + leaves;
- `RefinementLeaf.IsClosed`, `RefinementLeaf.IsOpen` — `Prop`
  predicates;
- `LeafStatus.isOpen`, `LeafStatus.isClosed` — `Bool` discriminators.

Four BSD-branch profiles form a monotone refinement chain (the
**closed-leaf count is invariant at 4**):

| Profile | `openCount` theorem | value |
|---|---|---|
| `bsd_leafLocalizationProfile` | `bsd_leafLocalizationProfile_openCount` | 2 |
| `bsd_refinedShaLeafLocalizationProfile` | `bsd_refinedShaLeafLocalizationProfile_openCount` | 5 |
| `bsd_refinedShaAndCompatibilityLeafLocalizationProfile` | `bsd_refinedShaAndCompatibilityLeafLocalizationProfile_openCount` | 7 |
| `bsd_fullyRefinedLeafLocalizationProfile` | `bsd_fullyRefinedLeafLocalizationProfile_openCount` | **12** |

Counts use `LeafLocalizationProfile.openCount` /
`closedCount` (`List.filter ... .length`). The monotone chain
`2 ≤ 5 ≤ 7 ≤ 12` is recorded as
`bsd_leafLocalization_openCount_chain`. All count theorems are
closed by `decide`.

`closedCount = 4` is invariant across the four profiles
(`bsd_*_closedCount` theorems).

Boundary: an increase in `openCount` is a refinement of
granularity, **not** an increase in mathematical difficulty. No
leaf is discharged at any refinement step.

### 8.2 Partial closure audit

`BSDBridgeC/Profile/PartialClosureAudit.lean` adds the
second-order honesty layer: open leaves are themselves audited and
classified into four buckets.

- `ClosureAuditStatus` —
  `closed` / `knownButUninternalized` /
  `structuralCandidate` / `«open»`.
- `ClosureAuditEntry` — leaf name + audit status + reason.
- `bsd_partialClosureAudit : List ClosureAuditEntry` — currently
  four representative entries.

Entry-level `Bool` discriminators
(`ClosureAuditEntry.isOpen` etc.) and registry-level counts
(`closureAudit_openCount`,
`closureAudit_knownButUninternalizedCount`,
`closureAudit_structuralCandidateCount`,
`closureAudit_closedCount`) make the partition computable. The
concrete partition for `bsd_partialClosureAudit` is `(2, 1, 1, 0)`
across the four statuses, fixed by
`bsd_partialClosureAudit_partition_counts`.

The audit registry is **not** a partition of the twelve refined
leaves. A separate `PendingAuditEntry` structure and registry
`bsd_pendingClosureAudit` list the refined leaves not yet covered
thematically:

- `bsd_pendingClosureAudit_count : pendingAuditCount
   bsd_pendingClosureAudit = 10`;
- `bsd_partialAudit_is_not_exhaustive : pendingAuditCount
   bsd_pendingClosureAudit ≠ 0`.

The three numbers — `12` (refined `openCount`), `2` (audit `«open»`
count over the four-entry thematic registry), and `10` (pending
audit count) — measure **three independent observation axes** and
must not be conflated. In particular, the entry
`selmerFinite_knownButUninternalized` does not correspond to any
single refined leaf, so no bijection between the audit registry
and the twelve refined leaves is established.

Slogan:

> Leaf localization is not a difficulty amplifier. It is a
> boundary detector.

### 8.3 Closeability audit

`BSDBridgeC/Profile/CloseabilityAudit.lean` adds a third audit
axis, orthogonal to leaf localization and partial closure: it
asks **why** each leaf is not closed yet.

- `CloseabilityStatus` — five-way taxonomy:
  `mathematicallyOpen`,
  `technicallyHard`,
  `technicallyHeavy`,
  `blockedByModeling`,
  `closeableNow`.
- `CloseabilityAuditEntry` — leaf name + status + reason.
- `bsd_closeabilityAudit : List CloseabilityAuditEntry` —
  currently seven entries.

Bool discriminators
(`CloseabilityStatus.isMathematicallyOpen`,
`...isTechnicallyHard`, `...isTechnicallyHeavy`,
`...isBlockedByModeling`, `...isCloseableNow`) plus a registry
counter `closeabilityCountBy` give the partition shape.

Count theorems (all closed by `decide`):

| Status | Count theorem | Value |
|---|---|---|
| `mathematicallyOpen` | `bsd_closeabilityAudit_mathematicallyOpenCount` | `4` |
| `technicallyHard` | `bsd_closeabilityAudit_technicallyHardCount` | `1` |
| `technicallyHeavy` | `bsd_closeabilityAudit_technicallyHeavyCount` | `1` |
| `blockedByModeling` | `bsd_closeabilityAudit_blockedByModelingCount` | `1` |
| `closeableNow` | `bsd_closeabilityAudit_closeableNowCount` | `0` |

The five-way conjunction is fixed by
`bsd_closeabilityAudit_partition_counts`.

Interpretation: closeability audit asks **why** a leaf is not
closed. It is **orthogonal** to leaf localization (which counts
where leaves are) and to partial closure audit (which classifies
each leaf's current scaffold role). A single leaf can therefore
appear in three different audits with three different statuses
along three independent axes.

Slogan:

> Open is not a single color.

A registry-hygiene invariant is exported on top of the counts:

- `CloseabilityRegistryHygieneClean entries : Prop` —
  `closeableNow` count is zero;
- `bsd_closeabilityAudit_hygieneClean` —
  the current registry satisfies the invariant
  (forwarded from
  `bsd_closeabilityAudit_closeableNowCount`);
- `bsd_closeabilityAudit_has_no_closeableNow` —
  re-export under a narrative-friendly name.

This is not a mathematical theorem; it is the operational
guarantee that the scaffold never quietly parks closeable
material under an open-looking label.

### 8.4 V4 typed leaf registry

`BSDBridgeC/Profile/LeafLocalization.lean` adds a typed
overlay on top of the string-based `RefinementLeaf` registry.
The inductive

```
inductive BSDLeafId where
  -- 4 closed:  torsion, tamagawa, regulator, period
  -- 4 Sha open:  shaFiniteSocket, shaSelmerInjection,
  --              shaSelmerSurjection, shaSelmerExactness
  -- 2 compatibility open: bsdLeadingCoefficientFormula,
  --                       bsdRankOrderCompatibility
  -- 6 higher-rank open:   higherEulerNormCompatibility ...
  --                       higherRankAnalyticRankCompatibility
deriving DecidableEq, Repr
```

enumerates the sixteen leaves of the fully refined BSD-branch
profile. Three projections (`BSDLeafId.status`,
`BSDLeafId.label`, `BSDLeafId.isOpen` / `.isClosed`) and three
typed partition lists (`bsd_closedLeafIds`, `bsd_openLeafIds`,
`bsd_fullyRefinedLeafIds`) round out the layer.

Count theorems (all `rfl`):

- `bsd_closedLeafIds_count = 4`,
- `bsd_openLeafIds_count = 12`,
- `bsd_fullyRefinedLeafIds_count = 16`.

### 8.5 V4 typed audit coverage

`BSDBridgeC/Profile/PartialClosureAudit.lean` attaches each
closure-audit entry to a typed `List BSDLeafId` via the
structure

```
structure AuditCoverage where
  auditName : String
  covers : List BSDLeafId
```

The registry `bsd_auditCoverage` has four entries:
`shaGlobalFiniteness_auditCoverage`,
`mordellWeilInjection_auditCoverage`,
`higherEulerSystems_auditCoverage`,
`selmerFinite_auditCoverage`. The last one carries
`covers := []`, which is the type-level reason the audit
registry is not a partition of the twelve refined open leaves.

Count theorems (`rfl`):

- `bsd_auditCoveredLeaves_count = 8`,
- `bsd_pendingAuditLeafIds_count = 4`,
- `bsd_typedCoverage_count_matches_openLeafCount`
  (covered + pending = `bsd_openLeafIds.length`).

Membership-consistency theorems
(`cases id <;> decide`):

- `bsd_typedCoverage_disjoint` —
  covered ∩ pending → False;
- `bsd_auditCoveredLeaves_subset_open`,
  `bsd_pendingAuditLeafIds_subset_open`;
- `bsd_openLeafIds_covered_or_pending`,
  `bsd_typedCoverage_covers_openLeafIds` —
  open ↔ covered ∨ pending.

`Nodup` witnesses (`decide`):
`bsd_auditCoveredLeaves_nodup`,
`bsd_pendingAuditLeafIds_nodup`,
`bsd_openLeafIds_nodup`. These upgrade the count statements to
genuine set-cardinality statements.

### 8.6 V4 typed closeability coverage

`BSDBridgeC/Profile/CloseabilityAudit.lean` adds a parallel
structure

```
structure CloseabilityCoverage where
  closeabilityName : String
  status : CloseabilityStatus
  covers : List BSDLeafId
```

with seven entries (one per closeability audit entry) and a
literal coverage list `bsd_closeabilityCoveredLeaves` of length
`12` — the closeability coverage is **exhaustive** over
`bsd_openLeafIds`
(`bsd_closeabilityCoverage_covers_openLeafIds`).

Per-status typed-leaf attribution:

- `bsd_closeabilityMathematicallyOpenLeafIds.length = 9`,
- `bsd_closeabilityTechnicallyHardLeafIds.length = 0`,
- `bsd_closeabilityTechnicallyHeavyLeafIds.length = 1`,
- `bsd_closeabilityBlockedByModelingLeafIds.length = 2`,
- `bsd_closeabilityCloseableNowLeafIds.length = 0`,
- `bsd_closeabilityPerStatusCounts_sum` —
  `9 + 0 + 1 + 2 + 0 = 12 = bsd_closeabilityCoveredLeaves.length`.

### 8.7 V4 leaf-indexed lookup layer

Two `BSDLeafId → Option ...` lookup functions invert the
typed-coverage relations:

- `BSDLeafId.partialClosureAuditStatus :
   BSDLeafId → Option ClosureAuditStatus` — strict over the
  partial audit, returning `none` for pending and closed
  leaves;
- `BSDLeafId.closeabilityStatus :
   BSDLeafId → Option CloseabilityStatus` — total over open
  leaves, returning `none` only for closed leaves.

Consistency theorems
(`partialClosureAuditStatus_isSome_iff_covered`,
`partialClosureAuditStatus_isNone_iff_uncovered`,
`closeabilityStatus_some_of_openLeaf`,
`closeabilityStatus_none_of_closedLeaf`) pin down the
total/partial structure. Specific witness theorems fix the
lookup at representative leaves (e.g.
`closeabilityStatus_selmerExactness =
some blockedByModeling`).

### 8.8 V4 typed-to-string registry bridge

`BSDLeafId.toRefinementLeaf : BSDLeafId → RefinementLeaf`
connects the typed identifier inductive to the string-based
`RefinementLeaf` registry. Four consistency theorems
(`cases id <;> rfl`):

- `BSDLeafId.toRefinementLeaf_status`,
- `BSDLeafId.toRefinementLeaf_label`,
- `BSDLeafId.toRefinementLeaf_closed_iff`,
- `BSDLeafId.toRefinementLeaf_open_iff`.

List-level bridge counts (`rfl`):

- `bsd_fullyRefinedLeavesFromIds_count = 16`,
- `bsd_openLeavesFromIds_count = 12`,
- `bsd_closedLeavesFromIds_count = 4`.

The bridge is **drift-preventing**: if a future change breaks
the typed/string correspondence, the file no longer
type-checks.

---

## 9. Theorem map

### `BSDBridgeC/TheoremMap.lean`

Role: `#check` index of every public-facing definition, structure,
and theorem. The file proves nothing; it makes the public DAG
inspectable from a single import.

Current section breakdown:

- Basic objects (7),
- Who side (8),
- Where side (9),
- Compatibility socket (4),
- Bridge layers (7),
- Bridge A / A′ / B / C internal sub-projections (11),
- Higher-rank sockets (8),
- Higher Euler / Kolyvagin / derivative internal (5),
- Higher-rank arithmetic bridge remaining sockets (3),
- Higher-rank socket genealogy bundle (2),
- Rank-one specialization (4),
- Rank-one Heegner witness internal projections (6),
- Rank-one witness genealogy bundle (3),
- Parity freezing (3),
- Parity freezing wrappers (4),
- Bridge C generality registry (12),
- Leaf localization (15),
- Refined Sha sub-leaves (9),
- Compatibility-node leaves (5),
- Higher-rank sub-leaves (13),
- Leaf count and refinement chain (13),
- Profile and constraint triangle (12),
- V3 Sha decomposition (7),
- V3 Sha projections (4),
- Selmer/Sha exact-package projections (6),
- V3 decomposed higher-rank sockets (7),
- V3 socket-structure projections (6),
- V3 rank-one Heegner witness (6),
- V3 rank-one witness projections (6),
- V3 rank-one witness bundle (2),
- Partial closure audit (16),
- Audit-registry counts (13),
- Pending audit registry (15),
- Closeability audit (24),
- Closeability registry hygiene (3),
- Typed leaf identifiers V4 (11),
- Typed-to-string registry bridge V4 (9),
- Typed audit coverage V4 (14),
- Typed coverage consistency V4 (8),
- Leaf-indexed partial-audit lookup V4 (7),
- Typed closeability coverage V4 (16),
- Per-status typed-leaf attribution V4 (11),
- Leaf-indexed closeability lookup V4 (7).

Total: **`#check` entries grow with each V3 / V4 task**; the
current count is approximately 362, all resolved against the
compiled modules.

---

## 10. Current DAG summary

```
Who side
  BSDWhoData  --bsdWhoData_to_heterogeneousBundle-->
              BSDWhoHeterogeneousBundle

Where side
  BSDWhereData  --bsdWhereData_to_centralBundle-->
                BSDWhereCentralBundle

Compatibility
  BSDWhoWhereCompatible  --bsdWhoWhereCompatible_to_socketBundle-->
                         BSDCompatibilitySocketBundle

Bridge C rigidity
  BridgeC_Rigidity
    +-- bridgeC_has_encode    --> BridgeA_Encode
    |     +-- modularity / euler product / dirichlet sockets
    +-- bridgeC_has_decode    --> BridgeB_Decode
    |     +-- iwasawa main / taylor-to-arith / normalization sockets
    +-- bridgeC_has_logDeriv  --> BridgeAprime_LogDeriv
    |     +-- log-derivative / pole-residue sockets
    +-- bridgeC_has_who_where --> BSDWhoWhereCompatible

Higher rank (r >= 2: OPEN)
  HigherRankArithmeticBridge E r
    +-- ES / KS / D
    +-- regulator / selmer / core-rank sockets
    --higherRankBridge_to_socketBundle-->
      HigherRankSocketBundle E r

  HigherRankSocket E r := Nonempty (HigherRankArithmeticBridge E r)
  (consumed only as a hypothesis)

Rank 1 (CLOSED, given witness)
  RankOneHeegnerWitness E
    --rankOneArithmeticBridge_of_heegnerWitness-->
      HigherRankArithmeticBridge E 1
    --higherRankSocket_rankOne_of_heegnerWitness-->
      HigherRankSocket E 1
    --rankOneHeegnerWitness_to_higherRankSocketBundle-->
      HigherRankSocketBundle E 1

Parity freezing
  BSDWhereData
    + (rootNumber = -1) + RootNumberFunctionalEquation
    --bsdWhereData_centralZero_of_negativeRootFunctionalEquation-->
      W.L 1 = 0

  BSDBridgeCProfile
    + BSDBridgeCProfileHasNegativeRootFunctionalEquation
    --bsdBridgeCProfile_centralZero_of_negativeRootFunctionalEquation-->
      P.where_.L 1 = 0

Profile aggregation
  BSDBridgeCProfile
    --bsdBridgeCProfile_constraintTriangle-->
      BSDConstraintTriangle P
        := (whoBundle, whereBundle, compatibilityBundle)

V3 decomposition layers (non-destructive over V2)
  HigherRankSocketStructure
    +-- ES, KS, D
    +-- RegulatorCompatibility (compatibility_law socket)
    +-- SelmerControl (control_law socket)
    +-- CoreRankBSDRankCompatibility (analytic_matches_algebraic socket)
  HigherRankSocketV3 E r := Nonempty HigherRankSocketStructure E r
    --higherRankSocket_of_v3-->
      HigherRankSocket E r          (V3 -> V2 forgetful only)

  RankOneHeegnerWitnessV3 E
    --rankOneHeegnerWitnessV3_to_higherRankSocketStructure-->
      HigherRankSocketStructure E 1
    --higherRankSocketV3_rankOne_of_heegnerWitnessV3-->
      HigherRankSocketV3 E 1
    --higherRankSocket_rankOne_of_heegnerWitnessV3-->
      HigherRankSocket E 1          (V3 -> V2 -> V2-socket)

  ShaDataV3 E
    +-- shaCarrier : Type
    +-- torsionAt n         -> ShaTorsionLike
    +-- selmerShaPackage n  -> SelmerShaExactPackage
    |     +-- mordellWeilMod, selmer, shaTorsion
    |     +-- injection_socket, surjection_socket, exactness_socket
    +-- finiteSocket : Prop
  ShaDataWithOrderV3 E
    --shaData_of_v3-->
      ShaData                       (V3 -> V2 forgetful)

Leaf localization (binary count, granularity)
  bsd_leafLocalizationProfile                                  openCount = 2
  bsd_refinedShaLeafLocalizationProfile                        openCount = 5
  bsd_refinedShaAndCompatibilityLeafLocalizationProfile        openCount = 7
  bsd_fullyRefinedLeafLocalizationProfile                      openCount = 12
                                                               closedCount = 4 (all four)

Partial closure audit (4-way partition, thematic registry)
  bsd_partialClosureAudit   open = 2, known = 1, structural = 1, closed = 0
  bsd_pendingClosureAudit   pending = 10
  bsd_partialAudit_is_not_exhaustive : pending != 0

Closeability audit (why is each leaf not closed?)
  bsd_closeabilityAudit
    mathematicallyOpen = 4
    technicallyHard    = 1
    technicallyHeavy   = 1
    blockedByModeling  = 1
    closeableNow       = 0

Four independent observation axes (none is a partition of the others):
  LeafLocalization     : where      (refined openCount = 12)
  PartialClosureAudit  : what role  (open=2, known=1, structural=1, closed=0)
  PendingClosureAudit  : which unaudited  (pending = 10)
  CloseabilityAudit    : why not closed   (4,1,1,1,0)

V4 typed layer (turns the observer into an index)
  BSDLeafId                      (4 closed + 12 open = 16)
    --AuditCoverage-->           typed coverage 8 + pending 4 = 12
    --CloseabilityCoverage-->    exhaustive: 12 covered, (9,0,1,2,0) by status
    --partialClosureAuditStatus--> Option ClosureAuditStatus  (strict)
    --closeabilityStatus-->      Option CloseabilityStatus  (total over open)
    --toRefinementLeaf-->        RefinementLeaf  (string registry bridge)

V4 consistency:
  membership: disjoint, subset, covers-iff, NoDup
  lookup    : isSome-iff-covered, isNone-iff-uncovered,
              some-of-open, none-of-closed
  bridge    : status / label / IsClosed / IsOpen consistency
```

---

## 11. Non-claims

To prevent the DAG layout from being read as a sequence of stealth
proofs, the following are explicitly **not** asserted anywhere in
the package:

- We do **not** prove the Birch–Swinnerton-Dyer conjecture.
- We do **not** prove finiteness of `Sha`.
- We do **not** compute `Sha`, the regulator, or the period.
- We do **not** prove modularity of elliptic curves.
- We do **not** prove the existence of higher Euler systems or
  higher Kolyvagin systems for `r ≥ 2`.
- We do **not** discharge `HigherRankSocket E r` for `r ≥ 2`.
- We do **not** prove `AnalyticRank = AlgebraicRank` (and we do
  **not** silently identify them: the three rank names are typed
  distinctly, with `RankAgreement` as an explicit hypothesis).
- We do **not** normalize the period.
- We do **not** prove the functional equation; it is a socket
  inside `BSDWhereHasNegativeRootFunctionalEquation`.
- We do **not** prove Gross–Zagier or Kolyvagin's theorem; the
  rank-one closure of the higher socket is conditional on the
  witness being supplied as data.
- We do **not** discharge `HigherRankSocketV3 E r` for `r ≥ 2`
  (the V3 socket is open in exactly the same sense as the V2
  socket; V3 only renames the bare `Prop` fields as named
  sub-sockets).
- We do **not** provide a V2 → V3 migration in either the
  higher-rank or the rank-one witness layer: V2 lacks the
  structural information needed to reconstruct V3's named
  sub-sockets, and this asymmetry is honest.
- We do **not** prove exactness of the Selmer/Sha sequence; the
  `injection_socket`, `surjection_socket`, and `exactness_socket`
  fields of `SelmerShaExactPackage` are all undischarged.
- We do **not** claim that the `12`, `2`, and `10` numbers
  reported by leaf localization, the audit registry, and the
  pending registry form a partition of one another; they measure
  three independent observation axes.
- We do **not** claim the audit registry is exhaustive: the
  theorem `bsd_partialAudit_is_not_exhaustive` records the
  non-exhaustivity explicitly.
- The closeability audit does **not** prove any of its entries:
  a `mathematicallyOpen` audit does not close the open question,
  a `technicallyHard` audit does not internalize the cited
  classical result, and a `blockedByModeling` audit does not
  refine the abstractions it points to.
- A `technicallyHard` or `technicallyHeavy` audit does **not**
  assert mathematical impossibility — it only records that the
  required formalization or engineering work has not been done.
- The current `closeableNow = 0` count is the **current
  registry state**, not a theorem that no future closure is ever
  possible. If a `closeableNow` entry appears in the registry,
  the discipline requires that the leaf be closed or
  reclassified.

- The V4 typed layer (`BSDLeafId`, `AuditCoverage`,
  `CloseabilityCoverage`, `partialClosureAuditStatus`,
  `closeabilityStatus`, `toRefinementLeaf`) adds **registry
  consistency** theorems only.  None of them discharges any
  closure-audit `«open»` or closeability `mathematicallyOpen`
  status; the typed layer is a queryable index over the
  existing audit registries, not a closure proof.
- The drift-prevention bridge `BSDLeafId.toRefinementLeaf` is
  not a uniqueness theorem about the underlying open content;
  it asserts the typed and string registries continue to agree
  on label and status. If a future refactor breaks that
  agreement, the file no longer type-checks.

The constraint-satisfaction reading of these non-claims is
recorded in `docs/BSDSerializationEngine.md` §5. The
leaf-localization reading is recorded in
`docs/LeafLocalization.md`. The closure-audit discipline is
recorded in `docs/PartialClosureAudit.md`. The closeability
discipline is recorded in `docs/CloseabilityAudit.md`.

---

End of Lean DAG.
