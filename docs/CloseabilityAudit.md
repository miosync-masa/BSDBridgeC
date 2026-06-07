# Closeability Audit

This note records the next layer of honesty in the BSD Bridge C
scaffold, beyond the leaf-localization and partial-closure-audit
disciplines. Leaf localization asks **where are the open
leaves?**; partial closure audit asks **what is each open leaf's
current scaffold role?**; pending-audit asks **which leaves have
not been classified yet?**. The closeability audit asks a
sharper question:

> ***Why is each leaf not closed yet?***

Different open leaves are open for very different reasons. A
scaffold that labels every undischarged leaf with the same color
`open` flattens the actual landscape and prevents the reader
from distinguishing the genuinely unsolved frontier from the
merely uninternalized.

Companion files:

- `BSDBridgeC/Profile/CloseabilityAudit.lean` — the Lean
  registry implementing the status taxonomy below.
- `BSDBridgeC/Profile/PartialClosureAudit.lean` — the prior
  partial-closure audit registry.
- `docs/LeafLocalization.md`, `docs/PartialClosureAudit.md` —
  the prior disciplines this layer builds on.

---

## 1. Why closeability is different from openness

`PartialClosureAudit` classifies a leaf into one of
`closed` / `knownButUninternalized` / `structuralCandidate` /
`«open»`. That partition answers the question *"what role does
this leaf currently play in the scaffold?"*.

It does **not** answer the question *"why is this leaf still in
that role?"*. An entry classified as `«open»` could be open
because the underlying mathematics is unsolved; an entry
classified as `structuralCandidate` could be parked there because
the relevant maps are not yet modeled. These are very different
failure modes, and a scaffold that wants to be read honestly
should make the distinction.

Closeability audit is that second-order classification.

---

## 2. Status taxonomy

The Lean inductive `CloseabilityStatus` carries five values:

| Status | Meaning |
|---|---|
| `mathematicallyOpen` | Genuinely unsolved at the mathematical frontier. |
| `technicallyHard` | Known mathematically; serious formalization project (descent, exact sequences, ...). |
| `technicallyHeavy` | Closeable in principle; mostly engineering / API / maps. |
| `blockedByModeling` | Current abstraction too coarse to decide closeability yet. |
| `closeableNow` | Should already be closed; leaving it open is a reverse overclaim. |

The five values are mutually exclusive at the audit-entry level.
They are *not* a refinement of `ClosureAuditStatus`: a leaf could
be `«open»` in `PartialClosureAudit` for reasons that fall into
any of the closeability categories. The two registries operate on
the same leaves but along orthogonal axes.

---

## 3. Current BSD audit table

The Lean registry `bsd_closeabilityAudit` currently contains
seven entries:

| Lean identifier | Status |
|---|---|
| `shaGlobalFiniteness_mathematicallyOpen` | `mathematicallyOpen` |
| `higherEulerSystems_mathematicallyOpen` | `mathematicallyOpen` |
| `bsdLeadingCoefficientFormula_mathematicallyOpen` | `mathematicallyOpen` |
| `bsdRankOrderCompatibility_mathematicallyOpen` | `mathematicallyOpen` |
| `selmerFinite_technicallyHard` | `technicallyHard` |
| `mordellWeilToSelmerInjection_technicallyHeavy` | `technicallyHeavy` |
| `selmerShaExactness_blockedByModeling` | `blockedByModeling` |

Each entry's `reason` field records why the assigned status is
the honest one at the present scaffold level.

The reasoning behind individual entries:

- **Sha global finiteness, higher Euler/Kolyvagin systems for
  `r ≥ 2`, the BSD leading-coefficient formula, and the BSD
  rank/order compatibility** are unsolved at the mathematical
  frontier in their generality. Closing them is a research-level
  task, not an internalization task.
- **Finite-level Selmer finiteness** is known mathematically (a
  descent argument plus finite-Selmer theory delivers it), but
  internalizing it inside the scaffold is a substantial
  formalization project — Mathlib does not, at the time of
  writing, expose a ready-to-use API.
- **Mordell-Weil to Selmer injection** is part of the standard
  Selmer exact-sequence construction. The mathematical content is
  routine, but the maps and quotient objects have not yet been
  modeled in the scaffold.
- **Selmer/Sha exactness** is presently blocked by modeling:
  exactness is a statement about three named maps in the
  Selmer/Sha exact package, and those maps are currently
  abstract carriers. Until they are made concrete, the question
  of exactness cannot even be assessed in the scaffold's own
  terms.

---

## 4. Closeability counts

The registry's partition is itself counted in Lean. With

- `closeabilityCountBy : (CloseabilityStatus → Bool) →
   List CloseabilityAuditEntry → ℕ`,

the four count theorems and the summary partition are:

| Status | Count theorem | Value |
|---|---|---|
| `mathematicallyOpen` | `bsd_closeabilityAudit_mathematicallyOpenCount` | `4` |
| `technicallyHard` | `bsd_closeabilityAudit_technicallyHardCount` | `1` |
| `technicallyHeavy` | `bsd_closeabilityAudit_technicallyHeavyCount` | `1` |
| `blockedByModeling` | `bsd_closeabilityAudit_blockedByModelingCount` | `1` |
| `closeableNow` | `bsd_closeabilityAudit_closeableNowCount` | `0` |

The five-way conjunction is fixed by
`bsd_closeabilityAudit_partition_counts`. All count theorems are
closed by `decide`.

The `closeableNow` count being `0` is itself a disciplinary
fact: if a future audit entry is classified `closeableNow`, the
honest action is to either close the leaf or move it back to a
more accurate status. Leaving a `closeableNow` entry on the open
side of the scaffold is, by this audit's own definition, a
reverse overclaim.

---

## 5. Reverse-overclaim discipline

Two complementary reverse-overclaim guards are now in place:

- `PartialClosureAudit` guards against treating every
  undischarged leaf as residual unsolved content.
- `CloseabilityAudit` further guards against treating every
  unsolved leaf as if it were mathematically open. Engineering
  work, modeling work, and internalization work are distinguished
  from frontier mathematics.

Together, the two disciplines turn the bare statement *"this
leaf is open"* into the much sharper *"this leaf is open
because P, and its current scaffold role is Q"*.

---

## 6. Relation to the prior audits

The three registries operate on the same population of leaves
along orthogonal questions:

| Registry | Question |
|---|---|
| `LeafLocalization` | *Where are the open leaves?* |
| `PartialClosureAudit` | *What is each open leaf's scaffold role?* |
| `PendingClosureAudit` (subset of `PartialClosureAudit`) | *Which leaves have not been classified yet?* |
| `CloseabilityAudit` | *Why is each leaf not closed yet?* |

They do **not** form a chain of refinements; they are four
independent observation axes. A leaf can simultaneously be
classified as `«open»` in `PartialClosureAudit` and
`technicallyHeavy` in `CloseabilityAudit`, or as
`knownButUninternalized` in `PartialClosureAudit` and
`technicallyHard` in `CloseabilityAudit`. The two coordinates
together give a more informative picture than either alone.

---

## 7. Non-claims

To prevent the audit from being misread as a discharge:

- We do **not** prove BSD.
- We do **not** prove Sha finiteness.
- We do **not** formalize Selmer-group finiteness.
- We do **not** construct higher Euler / Kolyvagin systems for
  `r ≥ 2`.
- We do **not** make the Selmer/Sha maps concrete.
- A `technicallyHard` audit does **not** import the relevant
  classical result.
- A `technicallyHeavy` audit does **not** add the corresponding
  maps or records.
- A `blockedByModeling` audit does **not** refine the
  abstractions it points to.
- A `mathematicallyOpen` audit does **not** improve the state of
  the underlying mathematics.

The audit registry assigns labels and reasons; it does not change
the underlying landscape.

---

## 8. Registry hygiene

`closeableNow` is **not** a stable resting state. By the
definition of the taxonomy, an entry classified `closeableNow`
should be closed (or reclassified to a more honest status)
**immediately**. Leaving such an entry on the open side of the
registry is, by this document's own discipline, a reverse
overclaim.

The Lean file therefore exposes a hygiene predicate and an
invariant theorem on top of the counts:

- `CloseabilityRegistryHygieneClean entries : Prop` —
  `closeabilityCountBy CloseabilityStatus.isCloseableNow entries = 0`.
- `bsd_closeabilityAudit_hygieneClean :
   CloseabilityRegistryHygieneClean bsd_closeabilityAudit` —
  the current `bsd_closeabilityAudit` satisfies the hygiene
  predicate (forwarded from
  `bsd_closeabilityAudit_closeableNowCount`).

A re-export `bsd_closeabilityAudit_has_no_closeableNow` provides
the same content under a name that reads naturally in narrative
prose.

### What the hygiene invariant means

- It is **not** a mathematical theorem about BSD or about any
  audited leaf. It is a **registry-hygiene invariant** about the
  scaffold's bookkeeping.
- It states a *current* state of the registry, not a future
  guarantee. If a future audit entry is marked `closeableNow`,
  the invariant breaks until the maintainer closes the leaf or
  reclassifies the entry.
- It is the operational mechanism that makes the slogan of §9
  enforceable: *open is not a single color, and `closeableNow`
  is not a color the registry is allowed to display
  permanently*.

This is the operational discipline the V3 phase has produced
for the BSD branch: open leaves are taxonomized, counted, and
audited along four orthogonal axes, and the one taxonomy value
that would represent the scaffold itself failing to do its work
is guarded by a Lean theorem.

---

## 9. Typed closeability coverage (V4)

V4 Task 5 attaches each closeability entry to a typed list of
`BSDLeafId` values: the typed leaves it **explains**. This
parallels the typed audit coverage of
`docs/PartialClosureAudit.md` §12.

### The `CloseabilityCoverage` structure

```
structure CloseabilityCoverage where
  closeabilityName : String
  status : CloseabilityStatus
  covers : List BSDLeafId
```

Each of the seven closeability entries receives a parallel
`CloseabilityCoverage` value:

| Entry | Status | Covered typed leaves |
|---|---|---|
| `shaGlobalFiniteness_mathematicallyOpen` | `mathematicallyOpen` | `[shaFiniteSocket]` |
| `higherEulerSystems_mathematicallyOpen` | `mathematicallyOpen` | six refined higher-rank leaves |
| `bsdLeadingCoefficientFormula_mathematicallyOpen` | `mathematicallyOpen` | `[bsdLeadingCoefficientFormula]` |
| `bsdRankOrderCompatibility_mathematicallyOpen` | `mathematicallyOpen` | `[bsdRankOrderCompatibility]` |
| `selmerFinite_technicallyHard` | `technicallyHard` | `[]` |
| `mordellWeilToSelmerInjection_technicallyHeavy` | `technicallyHeavy` | `[shaSelmerInjection]` |
| `selmerShaExactness_blockedByModeling` | `blockedByModeling` | `[shaSelmerSurjection, shaSelmerExactness]` |

The empty `covers` of `selmerFinite_closeabilityCoverage` is the
type-level reason the closeability registry, like the
closure-audit registry, is not by itself a partition of the
twelve refined leaves: at least one entry explains no refined
leaf.

### Coverage totals and exhaustiveness

The literal list `bsd_closeabilityCoveredLeaves` records the
union (with multiplicity) of all `covers` fields:

- `bsd_closeabilityCoveredLeaves_eq_flatten` —
  literal list equals `closeabilityCoverageCoveredLeaves
  bsd_closeabilityCoverage` (`rfl`).
- `bsd_closeabilityCoveredLeaves_count :
   bsd_closeabilityCoveredLeaves.length = 12` (`rfl`).
- `bsd_closeabilityCoveredLeaves_nodup` (`decide`).
- `bsd_closeabilityCoverage_subset_open` — every covered
  typed leaf is a typed open leaf.
- `bsd_closeabilityCoverage_covers_openLeafIds` —
  the closeability coverage is **exhaustive** over
  `bsd_openLeafIds`: every typed open leaf has a closeability
  explanation.

This is the strongest coverage statement the scaffold currently
makes: **all twelve typed open leaves receive a closeability
explanation, without any of them being closed**.

### Per-status typed-leaf attribution

Each closeability status gets its own literal list of typed
leaves it covers:

| List | Status | Length |
|---|---|---|
| `bsd_closeabilityMathematicallyOpenLeafIds` | `mathematicallyOpen` | `9` |
| `bsd_closeabilityTechnicallyHardLeafIds` | `technicallyHard` | `0` |
| `bsd_closeabilityTechnicallyHeavyLeafIds` | `technicallyHeavy` | `1` |
| `bsd_closeabilityBlockedByModelingLeafIds` | `blockedByModeling` | `2` |
| `bsd_closeabilityCloseableNowLeafIds` | `closeableNow` | `0` |

Five count theorems (`bsd_closeability*LeafIds_count`) close
each by `rfl`. The summary theorem
`bsd_closeabilityPerStatusCounts_sum` records
`9 + 0 + 1 + 2 + 0 = 12 = bsd_closeabilityCoveredLeaves.length`.

The interpretation:

- **`9` mathematically open typed leaves** are at the frontier
  in the strict sense.
- **`1` technically heavy typed leaf** (Mordell–Weil to Selmer
  injection) is open only because the relevant maps are not yet
  modeled.
- **`2` blocked-by-modeling typed leaves** (Selmer–Sha
  surjection and exactness) are open only because the
  `SelmerShaExactPackage` carriers are still abstract.
- **`0` technically hard typed leaves**: the `technicallyHard`
  entry `selmerFinite_closeabilityCoverage` covers no refined
  leaf directly. The classical Selmer-finiteness theme is
  recorded in the audit registry, but it lies *outside* the
  twelve refined leaves of the scaffold.
- **`0` closeable-now typed leaves**, as required by the
  hygiene invariant `bsd_closeabilityAudit_hygieneClean`.

### Honest reading

> *The closeability registry now explains all twelve typed open
> leaves at the coverage level, while still not closing any of
> them. Of those twelve, nine are mathematically open at the
> frontier; the remaining three are open for engineering or
> modeling reasons that are explicitly named.*

This is the strongest closeability statement the V4 layer
permits. None of it is a closure proof for any leaf.

### Closeability lookup by `BSDLeafId`

V4 Task 6 adds a leaf-indexed closeability lookup:

```
BSDLeafId.closeabilityStatus :
  BSDLeafId → Option CloseabilityStatus
```

Because the closeability coverage is exhaustive over the typed
open leaves
(`bsd_closeabilityCoverage_covers_openLeafIds`), this lookup is
**total over open leaves**: every typed open leaf returns
`some` with the closeability status that explains why it is not
currently closed. The four typed closed leaves return `none`,
since the why-not-closed concept does not apply to leaves
already classified as closed.

| Typed open leaf | Lookup result |
|---|---|
| `shaFiniteSocket` | `some mathematicallyOpen` |
| `shaSelmerInjection` | `some technicallyHeavy` |
| `shaSelmerSurjection` | `some blockedByModeling` |
| `shaSelmerExactness` | `some blockedByModeling` |
| `bsdLeadingCoefficientFormula` | `some mathematicallyOpen` |
| `bsdRankOrderCompatibility` | `some mathematicallyOpen` |
| six refined higher-rank leaves | each `some mathematicallyOpen` |
| `torsion`, `tamagawa`, `regulator`, `period` | `none` |

Witness theorems
(`closeabilityStatus_shaFinite`,
`closeabilityStatus_selmerInjection`,
`closeabilityStatus_selmerExactness`,
`closeabilityStatus_torsion_closedLeaf_none`) fix the lookup at
representative leaves.

Two exhaustiveness theorems pin down the total/partial structure:

- `closeabilityStatus_some_of_openLeaf` —
  for every `id ∈ bsd_openLeafIds`, `∃ s, id.closeabilityStatus = some s`;
- `closeabilityStatus_none_of_closedLeaf` —
  for every `id ∈ bsd_closedLeafIds`,
  `id.closeabilityStatus = none`.

Each is proved by case analysis on the sixteen `BSDLeafId`
constructors followed by either `exact ⟨_, rfl⟩` (for matching
constructors) or `exact absurd hid (by decide)` (for
constructors whose membership hypothesis is decidably false).

### Querying a leaf

The scaffold can now answer a query like

```
#check BSDLeafId.shaSelmerExactness.closeabilityStatus
-- some blockedByModeling
```

directly, without traversing the audit registry by hand. This
is the V4 progression from *observation device* (V3) to
*queryable index* (V4): a reader picks a typed leaf and gets
back its closure-audit status (`Option ClosureAuditStatus`) and
its closeability status (`Option CloseabilityStatus`) in two
constant-time lookups.

### Bridge to the string registry

Each `BSDLeafId` value is also mapped to its `RefinementLeaf`
counterpart by `BSDLeafId.toRefinementLeaf`
(`LeafLocalization.lean`; see `docs/LeafLocalization.md` §8).
The bridge's four consistency theorems
(`BSDLeafId.toRefinementLeaf_status`,
`BSDLeafId.toRefinementLeaf_label`,
`BSDLeafId.toRefinementLeaf_closed_iff`,
`BSDLeafId.toRefinementLeaf_open_iff`) guarantee that the
typed closeability lookup and the string-level
closeability-audit entries agree on label and status. Drift
between the typed registry and the string registry now
manifests as a type-check failure, not as silent documentation
decay.

### All twelve open leaves are explained

The combination of
`bsd_closeabilityCoverage_covers_openLeafIds` and
`closeabilityStatus_some_of_openLeaf` is the strongest
positive statement the closeability layer makes:

> **Every typed open leaf of the BSD branch has a closeability
> explanation.** Nine are `mathematicallyOpen`; one is
> `technicallyHeavy`; two are `blockedByModeling`; none is
> `closeableNow`. The explanation is queryable in constant
> time by the leaf's typed identifier; the typed/string
> registry agreement is a Lean theorem; and none of this
> discharges any open content.

---

## 10. Slogan

> **Open is not a single color.** Some open leaves are
> mathematically open; others are merely expensive,
> under-modeled, or awaiting internalization. The closeability
> audit makes the difference visible at the type level — and the
> registry-hygiene invariant prevents the scaffold from quietly
> parking closeable material under an open-looking label.

---

End of Closeability Audit note.
