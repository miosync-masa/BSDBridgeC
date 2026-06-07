# Leaf Localization

This note records the methodological principle that animates the
V3 phase of the BSD Bridge C scaffold: **structure refinement
localizes mathematical openness to named leaves of a typed
dependency DAG**. It does not introduce mathematical content
beyond what the Lean files already declare.

Companion files:

- `BSDBridgeC/Profile/LeafLocalization.lean` — the Lean scaffold
  recording the leaf classification used here.
- `docs/BridgeCGenerality.md` — the three-branch generality
  argument that motivates the V3 phase.
- `docs/LeanDAG.md` — the file-by-file map of the package.

---

## 1. Structure refinement as DAG refinement

A Bridge C profile, in its earliest form, is a single coupling
record: Who-data meets a Where-symmetry at a central compatibility
node. The first refinement, recorded in `WhoWhere/Basic.lean`,
splits each of the three roles (Who, Where, compatibility) into
named sub-records. Each subsequent refinement further splits a
record into named structure fields.

Read as a graph, this is iterative DAG refinement:

- the root is the top-level profile (`BSDBridgeCProfile`);
- each node is a structure;
- each edge is a structure field (data or a `Prop`-valued
  socket);
- the depth of a path measures how many refinement rounds have
  been performed on that subtree.

At no point in this process is a new mathematical claim made. Each
refinement replaces a coarse statement with a typed naming of the
same statement's sub-pieces.

---

## 2. Fields as dependency edges

In an interactive proof assistant, a `structure` field is not a
notational convenience: it is an obligation that must be filled at
inhabitation time. If the field's value is a `Prop`, the obligation
is a proof; if it is data, the obligation is a constructor call.

Reading the package's structures as a DAG, each field is therefore
a **dependency edge**: an arrow from "what this profile claims" to
"what must be supplied to inhabit this profile." The DAG is the
explicit map of these obligations.

The V3 phase pushed the depth of this DAG further: bare `Prop`
fields like `regulator_compatibility : Prop` were replaced by named
sub-structures like `RegulatorCompatibility E r ES`, each of which
itself carries one or more sub-fields. The refinement deepens the
dependency tree without changing what is being asked.

---

## 3. Leaves as bottom nodes

A **leaf** of the refinement DAG is a node with no further
sub-structure exposed at the present scaffold level. Concretely,
a leaf is a field whose type is **not** itself a `BSDBridgeC`
`structure` that the package decomposes further.

The leaves of the current BSD-branch DAG include:

- the five Who-side scalar / data types in `BSDWhoData`
  (`TorsionData`, `ShaData`, `TamagawaData`, `RegulatorData`,
  `PeriodData`);
- the `Prop`-valued socket fields of the higher-rank sub-socket
  structures (`compatibility_law`, `control_law`,
  `analytic_matches_algebraic`);
- the indexed-family fields of `HigherEulerSystem` and
  `HigherKolyvaginSystem`;
- the functional-equation `Prop` socket of `BSDWhereData`.

These are the points at which structural refinement, as currently
recorded, terminates.

---

## 4. Closed leaves versus open leaves

The leaves split into two classes.

**Closed leaves.** A closed leaf is one that, at the present
scaffold level, is *intended* to connect to Mathlib, to concrete
algebraic data, or to a finite computation. It is not a residual
BSD-conjecture socket. The "intended" qualifier matters: this
document does **not** claim that every closed leaf has a Mathlib
formalization in place today; it claims that the BSD problem's
residual openness is not located here.

**Open leaves.** An open leaf is one with no such planned
connection. It is a genuine unsolved socket of the BSD problem.
Inhabiting it would require a substantive arithmetic-geometry
result.

The classification, for the current BSD-branch leaves, is recorded
in `BSDBridgeC/Profile/LeafLocalization.lean`:

| Leaf | Status | Reason |
|---|---|---|
| `torsion` | closed | finite torsion data; concrete computation |
| `tamagawa` | closed | local factors; concrete local computation |
| `regulator` | closed | height / regulator data |
| `period` | closed | period data; normalization is explicit |
| `Sha finiteness` | **open** | residual BSD socket |
| `higher Euler systems r ≥ 2` | **open** | residual higher-rank socket |

The open leaves are tagged in Lean with the `LeafStatus.«open»`
constructor (escaped because `open` is a Lean keyword). The Lean
file records three closure/openness theorems:
`sha_finiteness_leaf_is_open`,
`higher_euler_system_leaf_is_open`,
`torsion_leaf_is_closed`.

### 4.1 After V3 Sha decomposition

The V3 Sha refinement of `WhoWhere/Basic.lean` (`ShaDataV3`,
`SelmerShaExactPackage`) further decomposes the coarse Sha leaf
into four named open sub-leaves. The classification updates as
follows:

| Sha leaf, coarse | Sha sub-leaves, refined |
|---|---|
| `Sha finiteness` | `ShaDataV3.finiteSocket` |
|  | `SelmerShaExactPackage.injection_socket` |
|  | `SelmerShaExactPackage.surjection_socket` |
|  | `SelmerShaExactPackage.exactness_socket` |

In Lean, the four refined Sha sub-leaves are declared as:

- `sha_finiteSocket_open_leaf`,
- `sha_selmer_injection_open_leaf`,
- `sha_selmer_surjection_open_leaf`,
- `sha_selmer_exactness_open_leaf`,

each carrying `status := .«open»` and a description pointing to
its source field in `ShaDataV3` or `SelmerShaExactPackage`. Four
new openness theorems mirror the coarse `sha_finiteness_leaf_is_open`:

- `sha_finiteSocket_leaf_is_open`,
- `sha_selmer_injection_leaf_is_open`,
- `sha_selmer_surjection_leaf_is_open`,
- `sha_selmer_exactness_leaf_is_open`.

The coarse `sha_finiteness_open_leaf` (and the coarse
`bsd_leafLocalizationProfile` containing it) are **preserved
unchanged** for backward compatibility. The refined
classification is exposed through a separate registry,
`bsd_refinedShaLeafLocalizationProfile`, in which the four sub-leaves
appear in place of the coarse Sha leaf.

The refined BSD-branch profile reads:

```
closed: torsion, tamagawa, regulator, period
open  : Sha finiteSocket
        Selmer-Sha injection socket
        Selmer-Sha surjection socket
        Selmer-Sha exactness socket
        higher Euler systems r >= 2
```

This update is the first time the leaf-localization principle has
been exercised dynamically: a single open leaf has been replaced
by a strictly more granular family of open sub-leaves without
changing the closed-leaf list and without discharging any open
content.

> **Open leaves are not merely listed; they can be recursively
> refined into smaller open sub-leaves.**

The methodology of §7 thus operates not only at the top-level
DAG, but recursively at any open leaf as the underlying scaffold
is refined.

### 4.2 Compatibility-node leaves

The previous refinement drilled into the Who side. The Bridge C
**compatibility node** itself — the central structure
`BSDWhoWhereCompatible`, which carries the relation between
Who-data and Where-data — also exposes open content. Its two
fields are

- `leadingCoefficientFormula : Prop`,
- `rankOrderCompatibility : Prop`.

Neither is discharged anywhere in the package. Both belong to the
core open content of the BSD formula: the leading-coefficient
identity at the central Taylor point, and the equality between
the analytic-side and algebraic-side rank-or-order data.

These are tagged as named open leaves in Lean:

- `bsd_leadingCoefficientFormula_open_leaf`,
- `bsd_rankOrderCompatibility_open_leaf`,

with corresponding openness theorems
`bsd_leadingCoefficientFormula_leaf_is_open` and
`bsd_rankOrderCompatibility_leaf_is_open`.

A third profile, layered on top of the Sha-refined profile, adds
these two leaves:

```
closed: torsion, tamagawa, regulator, period
open  : Sha finiteSocket
        Selmer-Sha injection socket
        Selmer-Sha surjection socket
        Selmer-Sha exactness socket
        BSD leading coefficient formula
        BSD rank/order compatibility
        higher Euler systems r >= 2
```

This is recorded in Lean as
`bsd_refinedShaAndCompatibilityLeafLocalizationProfile`. The
earlier `bsd_leafLocalizationProfile` and
`bsd_refinedShaLeafLocalizationProfile` are preserved unchanged.

### 4.3 Profile registry comparison

The three profiles form a chain of increasing refinement,
recording the same underlying problem at progressively higher
granularity:

| Profile | Closed leaves | Open leaves | # open |
|---|---|---|---|
| `bsd_leafLocalizationProfile` | 4 | Sha finiteness; higher Euler systems `r ≥ 2` | 2 |
| `bsd_refinedShaLeafLocalizationProfile` | 4 | 4 Sha sub-leaves; higher Euler systems `r ≥ 2` | 5 |
| `bsd_refinedShaAndCompatibilityLeafLocalizationProfile` | 4 | 4 Sha sub-leaves; 2 compatibility-node leaves; higher Euler systems `r ≥ 2` | 7 |

Note that the closed-leaf list is identical across all three
profiles. Each successive profile *increases* the number of open
leaves by replacing a single coarse open leaf, or by exposing a
previously bare compatibility socket, as a finer family of named
open sub-leaves. No open leaf has been discharged at any step.

### 4.4 Higher-rank sub-leaves

The coarse `higher_euler_system_open_leaf` records the higher-rank
content in a single bullet. The V3 higher-rank refinement of
`Socket/HigherRank.lean` (`HigherRankSocketStructure` and the
three named sub-socket structures `RegulatorCompatibility`,
`SelmerControl`, `CoreRankBSDRankCompatibility`, plus the socket
fields of `HigherEulerSystem`, `HigherKolyvaginSystem`,
`HigherKolyvaginDerivative`) decomposes this single bullet into
six named open sub-leaves.

| Refined leaf (Lean name) | Source field |
|---|---|
| `higherEuler_normCompatibility_open_leaf` | `HigherEulerSystem.norm_compatibility` |
| `higherKolyvagin_localRelations_open_leaf` | `HigherKolyvaginSystem.local_relations` |
| `higherKolyvagin_derivativeLaw_open_leaf` | `HigherKolyvaginDerivative.derivative_law` |
| `higherRank_regulatorCompatibility_open_leaf` | `RegulatorCompatibility.compatibility_law` |
| `higherRank_selmerControl_open_leaf` | `SelmerControl.control_law` |
| `higherRank_analyticRankCompatibility_open_leaf` | `CoreRankBSDRankCompatibility.analytic_matches_algebraic` |

Six openness theorems mirror the Sha and compatibility patterns:

- `higherEuler_normCompatibility_leaf_is_open`,
- `higherKolyvagin_localRelations_leaf_is_open`,
- `higherKolyvagin_derivativeLaw_leaf_is_open`,
- `higherRank_regulatorCompatibility_leaf_is_open`,
- `higherRank_selmerControl_leaf_is_open`,
- `higherRank_analyticRankCompatibility_leaf_is_open`.

The earlier `higher_euler_system_open_leaf` is preserved unchanged
as a coarse summary, exactly as `sha_finiteness_open_leaf` was
preserved alongside its four Sha sub-leaves.

#### Non-claims for the higher-rank refinement

- This refinement does **not** prove the existence of higher Euler
  or Kolyvagin systems for `r ≥ 2`.
- It does **not** prove the BSD rank equality
  (`analytic_matches_algebraic` remains an open `Prop` socket).
- It only replaces one coarse open leaf with six named open
  sub-leaves drawn from the V3 socket-structure fields.

### 4.5 Fully refined BSD-branch profile

The fully refined profile combines all three V3 refinement layers
(Sha, compatibility, higher-rank). It is declared in Lean as
`bsd_fullyRefinedLeafLocalizationProfile`. It carries

- **4 closed leaves** (unchanged across every profile in the
  registry), and
- **12 open leaves** (4 Sha + 2 compatibility + 6 higher-rank).

Updated profile registry:

| Profile | Closed | Open | # open |
|---|---|---|---|
| `bsd_leafLocalizationProfile` | 4 | Sha finiteness; higher Euler systems `r ≥ 2` | 2 |
| `bsd_refinedShaLeafLocalizationProfile` | 4 | 4 Sha sub-leaves; higher Euler systems `r ≥ 2` | 5 |
| `bsd_refinedShaAndCompatibilityLeafLocalizationProfile` | 4 | 4 Sha sub-leaves; 2 compatibility-node leaves; higher Euler systems `r ≥ 2` | 7 |
| `bsd_fullyRefinedLeafLocalizationProfile` | 4 | 4 Sha sub-leaves; 2 compatibility-node leaves; 6 higher-rank sub-leaves | **12** |

The four profiles form a monotone chain of refinements: each
successor differs from its predecessor only by replacing one
coarse open leaf with the finer family of named open sub-leaves
that V3 has exposed for it. No closed leaf has changed status, and
no open leaf has been discharged.

> **The unsolved content of the BSD branch has been localized to
> twelve named open leaves of the typed dependency DAG.**

This is the first completed shape of the leaf-localization
methodology: the three V3 refinement axes (Sha, compatibility,
higher-rank) have each been exercised once, and the union of their
exposed leaves is the present open-leaf list.

### 4.6 Lean-counted open leaves

The refinement chain `2 → 5 → 7 → 12` is now also a sequence of
Lean theorems. The file declares Boolean discriminators

- `LeafStatus.isOpen : LeafStatus → Bool`,
- `LeafStatus.isClosed : LeafStatus → Bool`,

and count functions

- `LeafLocalizationProfile.openCount : LeafLocalizationProfile → ℕ`,
- `LeafLocalizationProfile.closedCount : LeafLocalizationProfile → ℕ`,

implemented by `List.filter` followed by `.length`. The concrete
values for the four registered BSD profiles are then witnessed by:

| Profile | `openCount` theorem | value | `closedCount` theorem | value |
|---|---|---|---|---|
| `bsd_leafLocalizationProfile` | `bsd_leafLocalizationProfile_openCount` | 2 | `bsd_leafLocalizationProfile_closedCount` | 4 |
| `bsd_refinedShaLeafLocalizationProfile` | `bsd_refinedShaLeafLocalizationProfile_openCount` | 5 | `bsd_refinedShaLeafLocalizationProfile_closedCount` | 4 |
| `bsd_refinedShaAndCompatibilityLeafLocalizationProfile` | `bsd_refinedShaAndCompatibilityLeafLocalizationProfile_openCount` | 7 | `bsd_refinedShaAndCompatibilityLeafLocalizationProfile_closedCount` | 4 |
| `bsd_fullyRefinedLeafLocalizationProfile` | `bsd_fullyRefinedLeafLocalizationProfile_openCount` | 12 | `bsd_fullyRefinedLeafLocalizationProfile_closedCount` | 4 |

Every count theorem is closed by `decide`, evaluating the
`List.filter` over the literal leaf list.

The concrete monotone chain

```
2 ≤ 5 ≤ 7 ≤ 12
```

is recorded as a single conjunction theorem:

- `bsd_leafLocalization_openCount_chain`.

It is not a general monotonicity statement (no such statement is
proved here); it is the witness that the four currently registered
profiles satisfy the inequality concretely.

#### What the counts mean

> **These counts do not measure mathematical difficulty.  They
> measure the granularity of the current typed decomposition.**

A larger `openCount` is not a sign of more open mathematics; it is
a sign that the *same* underlying open content has been split into
more sharply named pieces. The closed-leaf count is invariant
across the entire chain (always `4`); no leaf has changed status
between any two profiles.

This makes the leaf-localization principle, for the first time,
not only a labeling discipline but a measurable one: the Lean
development can report how finely the unsolved core of BSD has
been localized.

---

## 5. BSD-branch summary

For the BSD branch, the open core consists of exactly the leaves
already named in §4:

- **Sha finiteness**, and
- **higher Euler / Kolyvagin systems in rank `r ≥ 2`**.

Everything else in the BSD scaffold either decomposes further into
named sub-structures (which are themselves not open BSD sockets, by
construction) or terminates at a closed leaf in the sense of §4.

The leading-coefficient socket of `BSDWhoWhereCompatible` and the
rank/order compatibility socket are bare `Prop`s in V2 of the
scaffold; they should be read as **open leaves until further
refinement**. A future structure-refinement round could split them
into named sub-sockets in the same way V3 split the higher-rank
bridge.

---

## 6. Why this is not a BSD proof

The leaf-localization scaffold is not a proof of any open leaf, and
it is not a proof of BSD. Specifically:

- We do **not** prove finiteness of `Sha`. The leaf is recorded
  as open.
- We do **not** prove existence of higher-rank Euler or Kolyvagin
  systems. The leaf is recorded as open.
- We do **not** prove modularity, Gross–Zagier, Kolyvagin's
  theorem for higher ranks, the Iwasawa main conjecture, or
  analytic-rank equals algebraic-rank.
- We do **not** claim the closed leaves are fully formalized in
  Mathlib today; we claim they are not the residual BSD socket.

The scaffold records *where* the open content lives, not what it
is. Its value is taxonomic, not arithmetic.

---

## 7. The methodological claim

Across the V1, V2, and V3 phases of the BSD Bridge C scaffold, the
discipline is uniform: refine structure, name fields, surface
sockets. The leaf-localization principle is the explicit version of
that discipline.

> **The contribution is not to remove the open leaves, but to prove
> that the remaining openness has been localized to named leaves of
> the typed dependency DAG.**

Lean is used here as a localization instrument: it turns the
diffuse statement "BSD is unsolved" into a finite list of named
open leaves and a typed dependency tree leading to them. The slogan
of `BridgeCGenerality.md` — *Bridge C is a proof architecture with
typed exits* — has its dual here:

> **Open mathematics, in this scaffold, is a finite list of
> labeled leaves.**

That is what the V3 phase has produced for the BSD branch, and it
is the form in which subsequent refinements should continue to
deliver further progress: not by closing the open leaves directly,
but by deepening the DAG until openness is forced into ever
smaller, more sharply named, individually addressable leaves.

---

## 8. Typed leaf identifiers

The `RefinementLeaf` registry above identifies a leaf by its
`name : String` field. That is enough for documentation, but Lean
cannot compare two `RefinementLeaf` records for *identity of
leaf* without unfolding the string. The V4 phase adds a typed
overlay.

A single inductive

```
inductive BSDLeafId where
  | torsion | tamagawa | regulator | period
  | shaFiniteSocket | shaSelmerInjection
  | shaSelmerSurjection | shaSelmerExactness
  | bsdLeadingCoefficientFormula | bsdRankOrderCompatibility
  | higherEulerNormCompatibility | higherKolyvaginLocalRelations
  | higherKolyvaginDerivativeLaw
  | higherRankRegulatorCompatibility
  | higherRankSelmerControl
  | higherRankAnalyticRankCompatibility
```

enumerates the sixteen leaves of the fully refined BSD-branch
profile. The inductive derives `DecidableEq` and `Repr`, so leaf
identity is now Lean-decidable rather than string-compared.

Three definitions read each constructor's status and label:

- `BSDLeafId.status : BSDLeafId → LeafStatus`,
- `BSDLeafId.label : BSDLeafId → String`,
- `BSDLeafId.isOpen / BSDLeafId.isClosed : BSDLeafId → Bool`.

The labels match the `name` fields of the corresponding
`RefinementLeaf` values verbatim, so the two registries can be
read in parallel.

Three concrete `List BSDLeafId` values record the partitions:

| List | Length | Count theorem |
|---|---|---|
| `bsd_closedLeafIds` | 4 | `bsd_closedLeafIds_count` |
| `bsd_openLeafIds` | 12 | `bsd_openLeafIds_count` |
| `bsd_fullyRefinedLeafIds` | 16 | `bsd_fullyRefinedLeafIds_count` |

All three theorems are closed by `rfl`: the lists are literal,
`List.length` reduces definitionally, and the counts are constant.

### Non-destructive overlay

The typed registry is layered on top of the existing
`RefinementLeaf`-based registry. None of the V3
`*_open_leaf` / `*_closed_leaf` declarations, the leaf
profiles, or the count theorems are changed. The typed
identifiers are a separate addressing mode for the same leaves,
not a replacement for the string-based registry.

### What this enables

- Future audits and pending registries can take
  `BSDLeafId` arguments and exhibit coverage relations as Lean
  data instead of by string comparison.
- A leaf is now a value of a type, with a decidable identity, so
  audit coverage can be proved or refuted by `decide` rather
  than argued in prose.

The V3 picture **"leaves are named cells in a registry"**
becomes the V4 picture **"leaves are values of a typed
identifier."**

The first downstream use of `BSDLeafId` is the `AuditCoverage`
relation introduced in `docs/PartialClosureAudit.md` §12: each
closure-audit entry is paired with a `List BSDLeafId` of refined
leaves it thematically covers, so the previously prose-level
correspondence between audit entries and refined leaves becomes
Lean data. The typed pending list `bsd_pendingAuditLeafIds`,
defined relative to that coverage relation, contains `4`
entries; this number is a theorem, not a comment.

### Typed-to-string registry bridge

The typed `BSDLeafId` and the string-based `RefinementLeaf`
registry now live side by side. V4 Task 9 connects them
explicitly:

```
BSDLeafId.toRefinementLeaf : BSDLeafId → RefinementLeaf
```

Each constructor of `BSDLeafId` maps to the corresponding
`RefinementLeaf` value already declared earlier in this file
(`torsion_closed_leaf`, `sha_finiteSocket_open_leaf`, etc.). The
bridge is **non-destructive**: no existing `RefinementLeaf`
value is changed; the bridge merely identifies which string-level
cell each typed identifier addresses.

Four consistency theorems pin down the bridge's correctness:

| Theorem | Statement |
|---|---|
| `BSDLeafId.toRefinementLeaf_status` | `id.toRefinementLeaf.status = id.status` |
| `BSDLeafId.toRefinementLeaf_label` | `id.toRefinementLeaf.name = id.label` |
| `BSDLeafId.toRefinementLeaf_closed_iff` | `id.toRefinementLeaf.IsClosed ↔ id.status = .closed` |
| `BSDLeafId.toRefinementLeaf_open_iff` | `id.toRefinementLeaf.IsOpen ↔ id.status = .«open»` |

All four are closed by `cases id <;> rfl`.

The list-level bridge maps the typed partitions into lists of
`RefinementLeaf` values:

| Bridge list | Length theorem | Value |
|---|---|---|
| `bsd_fullyRefinedLeavesFromIds` | `bsd_fullyRefinedLeavesFromIds_count` | `16` |
| `bsd_openLeafIds.map BSDLeafId.toRefinementLeaf` | `bsd_openLeavesFromIds_count` | `12` |
| `bsd_closedLeafIds.map BSDLeafId.toRefinementLeaf` | `bsd_closedLeavesFromIds_count` | `4` |

All three count theorems are closed by `rfl`.

#### What this prevents

Without an explicit bridge, the typed registry and the string
registry would drift over time: a future refinement of one
might silently change the implicit correspondence to the other,
and the docs claim "the labels match" would degrade from a
theorem into a comment.

With the bridge, the correspondence is a Lean theorem. If a
future change breaks the status / label consistency, the
file no longer type-checks — and the maintainer is forced to
update both sides together.

### V4 final summary

After V4 Tasks 1, 2, 3, 5, 6, and 9, `BSDLeafId` is the **common
key** by which the BSD-branch scaffold organizes its bookkeeping.
Every downstream registry now keys off the typed identifier:

| Layer | Lean identifier | Direction |
|---|---|---|
| Leaf localization | `bsd_openLeafIds`, `bsd_closedLeafIds` | partition |
| Partial closure audit | `bsd_auditCoverage`, `bsd_auditCoveredLeaves` | forward (audit → leaves) |
| Pending audit | `bsd_pendingAuditLeafIds` | forward (uncovered leaves) |
| Closeability audit | `bsd_closeabilityCoverage`, `bsd_closeabilityCoveredLeaves` | forward (reason → leaves) |
| Partial-audit lookup | `BSDLeafId.partialClosureAuditStatus` | inverse (leaf → status) |
| Closeability lookup | `BSDLeafId.closeabilityStatus` | inverse (leaf → status) |
| String-registry bridge | `BSDLeafId.toRefinementLeaf` | bidirectional consistency |

The slogan for this phase:

> **The V4 layer turns the observer into an index.**

V3 was a four-axis observation device. V4 made every axis
queryable by the same typed key. Concretely:

```
#check BSDLeafId.shaSelmerExactness.partialClosureAuditStatus
-- none      (pending; not covered by current audit registry)

#check BSDLeafId.shaSelmerExactness.closeabilityStatus
-- some blockedByModeling

#check BSDLeafId.shaSelmerExactness.toRefinementLeaf
-- sha_selmer_exactness_open_leaf  (label and status preserved)
```

No theorem of V4 discharges any open leaf; the layer is
registry consistency. What it changes is *how the scaffold can
be queried*, not *what the scaffold proves*.

---

## 9. Closeability is orthogonal to leaf localization

Leaf localization, on its own, classifies a leaf with a binary
tag — `closed` or `«open»` — and counts how many of each there
are. It does **not** ask why the open leaves are open. That
second-order question is the job of `docs/CloseabilityAudit.md`,
which assigns each audited leaf one of five reasons:

- `mathematicallyOpen` — genuinely unsolved at the frontier;
- `technicallyHard` — known mathematically; a serious
  formalization project;
- `technicallyHeavy` — closeable in principle, mostly
  engineering / API / maps;
- `blockedByModeling` — abstraction too coarse to decide;
- `closeableNow` — should be closed already.

A leaf counted as `«open»` in leaf localization may later be
audited as `knownButUninternalized` in `PartialClosureAudit` and
as `technicallyHard` in `CloseabilityAudit`. None of these
classifications is implied by any of the others; they record
three different observations about the same leaf along three
independent axes:

| Axis | Question | Implementation |
|---|---|---|
| Leaf localization | *Where is the leaf?* | `LeafLocalizationProfile` |
| Partial closure audit | *What role does it currently play?* | `ClosureAuditEntry`, `bsd_partialClosureAudit` |
| Closeability audit | *Why is it not closed?* | `CloseabilityAuditEntry`, `bsd_closeabilityAudit` |

The slogan that ties the axes together:

> **Leaf localization tells us where the boundary lies;
> closeability audit tells us what kind of boundary it is.**

This document continues to count leaves and report granularity.
For the deeper question of how that openness is shaped, see
`docs/CloseabilityAudit.md`.

---

End of Leaf Localization note.
