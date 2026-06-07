# Partial Closure Audit

This note records the second-order discipline that accompanies the
leaf-localization principle of `docs/LeafLocalization.md`. Where
leaf localization asks **"which leaves are open?"**, partial
closure audit asks **"which of those should remain open?"**.

The two disciplines are complementary. Without leaf localization
the scaffold cannot point at the open content; without closure
audit the scaffold cannot tell the open content from the
uninternalized.

Companion files:

- `BSDBridgeC/Profile/PartialClosureAudit.lean` — the Lean
  registry implementing the audit.
- `BSDBridgeC/Profile/LeafLocalization.lean` — the leaf
  classification this audit operates over.
- `docs/LeafLocalization.md` — the prose form of the underlying
  leaf-localization principle.

---

## 1. Why open leaves need an audit

Leaf localization, on its own, is a one-sided discipline. It
records which leaves of the dependency DAG are open. It does not
ask whether each open leaf is open *for the right reason*.

A scaffold that records every undischarged leaf as `open` without
auditing the list will, over time, accumulate leaves that

- are classical results not yet imported from Mathlib,
- are structural constructions that the scaffold has not yet
  added,
- are conventions / normalizations awaiting a choice,

alongside the genuine open content of the underlying problem. The
result is a leaf list that *looks* like a difficulty profile but
is in fact a mixture of mathematical openness and scaffold
incompleteness.

The audit corrects this by asking, for each open leaf: would
closing this leaf require new mathematics, or only further
scaffold work?

---

## 2. Reverse overclaim: leaving closeable leaves open

The standard overclaim of an ambitious package is to mark too much
content as closed: "we have proved X" when X is only conjectured.
The **reverse overclaim**, which is the failure mode this audit
guards against, is to mark too much content as open: leaving
closeable leaves on the open list, and thereby presenting the
problem as harder than it is.

The reverse overclaim is tempting because:

- it makes the open-leaf count look impressive,
- it makes refinement progress look slower than it is,
- it inflates the perceived difficulty of the underlying problem.

The discipline of this document is the explicit refusal of those
incentives:

> **Leaf localization is not a difficulty amplifier. It is a
> boundary detector.**

---

## 3. Audit-status taxonomy

The Lean file declares a four-way audit status:

| Status | Meaning |
|---|---|
| `closed` | Already closed in the scaffold. |
| `knownButUninternalized` | Known by external mathematics, not yet imported. |
| `structuralCandidate` | Closeable once structural maps / records are added; no new mathematics needed. |
| `«open»` | Genuinely open at the present mathematical frontier. |

The first three categories do **not** count as residual unsolved
mathematics. Only the fourth, `«open»`, is the honest open core.

---

## 4. Sha as a mixed leaf

The coarse leaf `sha_finiteness_open_leaf` of leaf-localization
treats the Sha-related content as a single open bullet. The audit
splits it into several entries with different statuses:

| Entry | Status | Why |
|---|---|---|
| finite-level Selmer finiteness | `knownButUninternalized` | Classical descent + finite-Selmer theory. Not yet imported into this scaffold. |
| Mordell--Weil to Selmer injection | `structuralCandidate` | Standard component of the Selmer exact sequence. Closeable once the maps are introduced. |
| global Sha finiteness | `«open»` | Genuine BSD-side open question. |

The audit therefore reads the Sha leaf as a **mixed** leaf:
classifying part of it as "external classical result", part as
"structural to-do inside the scaffold", and part as "genuine
unsolved".

This is the kind of decomposition the audit is designed for. The
single coarse leaf, viewed through the audit, is not one open
question but three differently-shaped items.

---

## 5. Current audit table

The Lean registry `bsd_partialClosureAudit` currently contains
four entries:

| Entry name | Lean identifier | Status |
|---|---|---|
| finite-level Selmer finiteness | `selmerFinite_knownButUninternalized` | `knownButUninternalized` |
| Mordell--Weil to Selmer injection | `mordellWeilToSelmerInjection_structuralCandidate` | `structuralCandidate` |
| global Sha finiteness | `shaGlobalFiniteness_staysOpen` | `«open»` |
| higher Euler systems `r ≥ 2` | `higherEulerSystems_stayOpen` | `«open»` |

Witness theorems fix the recorded status of each:

- `shaGlobalFiniteness_audit_is_open`,
- `selmerFinite_audit_is_knownButUninternalized`,
- `mordellWeilInjection_audit_is_structuralCandidate`,
- `higherEulerSystems_audit_is_open`.

Boolean discriminators
(`ClosureAuditStatus.isOpen`,
`ClosureAuditStatus.isKnownButUninternalized`,
`ClosureAuditStatus.isStructuralCandidate`,
`ClosureAuditStatus.isClosed`)
allow downstream code to filter the registry by audit status.

The registry is currently small. It is intended to grow as further
open leaves of leaf-localization are audited.

---

## 6. Policy

The discipline this document establishes for every open leaf of
`docs/LeafLocalization.md`:

1. Each leaf marked `«open»` in `LeafLocalization` should
   eventually receive at least one audit entry in
   `PartialClosureAudit`.
2. The audit entry's status must be one of
   `closed` / `knownButUninternalized` / `structuralCandidate` /
   `«open»`.
3. Leaves classified `closed` or `knownButUninternalized` or
   `structuralCandidate` are no longer counted as residual
   unsolved content; they remain on the leaf list as bookkeeping,
   but the scaffold does not advertise them as part of the open
   core.
4. Only leaves audited as `«open»` belong to the honest open
   core.

This policy is monotone in a different direction from the
leaf-localization refinement chain: leaf-localization tends to
increase the open count by drilling, while the audit tends to
*decrease* the residual open count by reclassifying. The two
operate on different axes and do not conflict.

---

## 7. Non-claims

To prevent the audit from being misread as a discharge:

- No leaf is **proved** here. Audit entries assign a status; they
  do not provide a proof of the underlying claim.
- A `knownButUninternalized` audit does **not** internalize the
  cited classical result into the scaffold.
- A `structuralCandidate` audit does **not** add the corresponding
  maps or records.
- A leaf still recorded as `«open»` after audit remains open in
  every sense — the audit confirms, rather than discharges, its
  open status.

---

## 8. Methodological claim

The leaf-localization principle, on its own, says:

> *The unsolved content of the BSD branch has been localized to
> twelve named open leaves.*

After partial closure audit, the honest reading is sharper:

> *Of the twelve named open leaves, some are genuinely open at the
> present mathematical frontier, some are known by external
> mathematics but not yet internalized, and some are structural
> candidates closeable by further scaffold work. The current audit
> registry records this partition explicitly.*

The audit converts the leaf-localization picture from a count
into a **partition** — and a partition is the form an honest
progress report should take.

---

## 9. Audit-count summary

The audit registry's partition is now itself counted in Lean.
Boolean discriminators at the entry level

- `ClosureAuditEntry.isOpen`,
- `ClosureAuditEntry.isKnownButUninternalized`,
- `ClosureAuditEntry.isStructuralCandidate`,
- `ClosureAuditEntry.isClosed`,

are followed by registry-level count functions

- `closureAudit_openCount`,
- `closureAudit_knownButUninternalizedCount`,
- `closureAudit_structuralCandidateCount`,
- `closureAudit_closedCount`,

each implemented by `List.filter` followed by `.length`. For the
current registry `bsd_partialClosureAudit` the four counts are
fixed by concrete theorems:

| Audit status | Count | Theorem |
|---|---|---|
| `«open»` | 2 | `bsd_partialClosureAudit_openCount` |
| `knownButUninternalized` | 1 | `bsd_partialClosureAudit_knownButUninternalizedCount` |
| `structuralCandidate` | 1 | `bsd_partialClosureAudit_structuralCandidateCount` |
| `closed` | 0 | `bsd_partialClosureAudit_closedCount` |

The conjunction is fixed in one theorem:
`bsd_partialClosureAudit_partition_counts`. All five are closed
by `decide`.

### Audit registry vs leaf-localization

The interplay between the two count layers is the central honest
report this scaffold can currently make:

| Layer | Count function | Current value | Theorem |
|---|---|---|---|
| Leaf localization (binary, fully refined) | `LeafLocalizationProfile.openCount` on `bsd_fullyRefinedLeafLocalizationProfile` | `12` | `bsd_fullyRefinedLeafLocalizationProfile_openCount` |
| Audit registry, `«open»` partition | `closureAudit_openCount` on `bsd_partialClosureAudit` | `2` | `bsd_partialClosureAudit_openCount` |

The two `2`s and the one `12` are intentionally different
quantities and must not be conflated:

- `12` is the number of named open leaves the *refined*
  leaf-localization profile records — it measures how finely the
  scaffold has decomposed its open content.
- The audit's `«open»` count is `2`, but this is taken over the
  current four-entry audit registry, **not** over all twelve
  leaves. The audit registry is currently a representative subset.

> The current audit registry classifies four representative
> leaves: two remain genuinely open (`shaGlobalFiniteness_staysOpen`
> and `higherEulerSystems_stayOpen`), one is known but not
> internalized (`selmerFinite_knownButUninternalized`), and one is
> a structural candidate for closure
> (`mordellWeilToSelmerInjection_structuralCandidate`).
> Auditing the remaining leaves of the fully refined profile is
> not claimed and is left to future entries.

This separation between the localization count (`12`) and the
audit-partition count (`2 / 1 / 1 / 0`) is itself the form of
honesty this document is meant to enforce: the residual open core
is **not** simply twelve, and **not** simply two — it is twelve in
the localization sense, of which only the audited subset has been
classified, with the remainder pending audit.

---

## 10. Pending audit registry

The previous section repeatedly used the word *pending* to mark
the leaves that have not been thematically covered by
`bsd_partialClosureAudit`. The next layer of honesty is to turn
that word into Lean data.

A separate registry, `bsd_pendingClosureAudit`, records the
refined leaves whose audit status has **not** been assigned. A
pending entry is **not** the same as an `«open»` audit entry: an
`«open»` audit is a classification ("we have looked, and this is
genuinely open"); a pending entry is the explicit absence of a
classification ("we have not yet looked").

### Why not "the remaining eight"?

It would be tempting to write *"the remaining eight leaves are
pending audit."* That phrasing assumes a one-to-one bijection
between the four audit entries of `bsd_partialClosureAudit` and
four of the twelve leaves of
`bsd_fullyRefinedLeafLocalizationProfile`. Such a bijection has
**not** been established in this scaffold. The audit registry is
thematic:

- `shaGlobalFiniteness_staysOpen` thematically corresponds to
  `sha_finiteSocket_open_leaf` of the refined profile;
- `mordellWeilToSelmerInjection_structuralCandidate` thematically
  corresponds to `sha_selmer_injection_open_leaf`;
- `higherEulerSystems_stayOpen` audits the **coarse** higher-rank
  leaf, not any of the six refined higher-rank sub-leaves;
- `selmerFinite_knownButUninternalized` does not correspond
  directly to any refined leaf of the current profile.

Concretely:

> Do **not** say "the remaining eight" unless a precise bijection
> is established.

The honest statement is: **the refined leaves not yet covered
thematically by `bsd_partialClosureAudit` are recorded in
`bsd_pendingClosureAudit`**, and that pending list has ten
entries (not eight) — one per refined leaf whose status the audit
registry has not addressed.

### Pending entries (10)

| Pending entry | Refined leaf it shadows |
|---|---|
| `selmerShaSurjection_pendingAudit` | `sha_selmer_surjection_open_leaf` |
| `selmerShaExactness_pendingAudit` | `sha_selmer_exactness_open_leaf` |
| `bsdLeadingCoefficientFormula_pendingAudit` | `bsd_leadingCoefficientFormula_open_leaf` |
| `bsdRankOrderCompatibility_pendingAudit` | `bsd_rankOrderCompatibility_open_leaf` |
| `higherEulerNormCompatibility_pendingAudit` | `higherEuler_normCompatibility_open_leaf` |
| `higherKolyvaginLocalRelations_pendingAudit` | `higherKolyvagin_localRelations_open_leaf` |
| `higherKolyvaginDerivativeLaw_pendingAudit` | `higherKolyvagin_derivativeLaw_open_leaf` |
| `higherRankRegulatorCompatibility_pendingAudit` | `higherRank_regulatorCompatibility_open_leaf` |
| `higherRankSelmerControl_pendingAudit` | `higherRank_selmerControl_open_leaf` |
| `higherRankAnalyticRankCompatibility_pendingAudit` | `higherRank_analyticRankCompatibility_open_leaf` |

### Count and non-exhaustivity theorems

The pending count is fixed by:

- `bsd_pendingClosureAudit_count :
   pendingAuditCount bsd_pendingClosureAudit = 10`.

The audit's non-exhaustivity is itself a Lean theorem:

- `bsd_partialAudit_is_not_exhaustive :
   pendingAuditCount bsd_pendingClosureAudit ≠ 0`.

Both are closed by `decide`.

### Three-layer count summary

The leaf-localization / audit / pending layers now form a
three-stage report:

| Layer | Object | Count function | Current value |
|---|---|---|---|
| Refined localization | `bsd_fullyRefinedLeafLocalizationProfile` | `openCount` | `12` |
| Audit registry, `«open»` partition | `bsd_partialClosureAudit` | `closureAudit_openCount` | `2` |
| Pending audit registry | `bsd_pendingClosureAudit` | `pendingAuditCount` | `10` |

The three numbers `12`, `2`, `10` measure three different things:

- `12` is the number of named refined open leaves of the
  localization profile.
- `2` is the number of audit entries currently classified as
  genuinely open (`«open»`).
- `10` is the number of refined leaves currently marked as
  pending audit.

`2` and `10` are **not** a partition of `12`: the four audit
entries are thematic, and `selmerFinite_knownButUninternalized` in
particular does not correspond to any refined leaf. The three
numbers are independent, and the scaffold reports them as such.

---

## 11. Final methodological statement

After this layer, the scaffold's honest progress report takes the
form:

> *The fully refined leaf profile records twelve named open
> leaves. The audit registry currently classifies four
> representative entries: two as genuinely open, one as
> known-but-uninternalized, and one as a structural candidate.
> Ten refined leaves remain in the pending-audit registry; their
> closure status has not yet been assigned.*

This is the form a future paper section can quote verbatim
without overstating the closure progress and without
understating the remaining work.

---

## 12. Typed audit coverage (V4)

V4 introduces typed leaf identifiers (`BSDLeafId`, declared in
`Profile/LeafLocalization.lean` and described in
`docs/LeafLocalization.md` §8). Once leaves are values of a typed
inductive, the **coverage relation** between audit entries and
refined leaves can itself be recorded as Lean data instead of
prose.

### The `AuditCoverage` structure

```
structure AuditCoverage where
  auditName : String
  covers : List BSDLeafId
```

Each existing closure-audit entry receives a parallel
`AuditCoverage` value:

| Audit entry | Lean coverage | Covered leaves |
|---|---|---|
| `shaGlobalFiniteness_staysOpen` | `shaGlobalFiniteness_auditCoverage` | `[shaFiniteSocket]` |
| `mordellWeilToSelmerInjection_structuralCandidate` | `mordellWeilInjection_auditCoverage` | `[shaSelmerInjection]` |
| `higherEulerSystems_stayOpen` | `higherEulerSystems_auditCoverage` | the six refined higher-rank leaves |
| `selmerFinite_knownButUninternalized` | `selmerFinite_auditCoverage` | `[]` |

The empty `covers` list of `selmerFinite_auditCoverage` is the
precise type-level reason the closure-audit registry is not a
partition of the twelve refined leaves: at least one audit entry
covers no refined leaf.

### Counts

`auditCoverageCoveredLeaves : List AuditCoverage → List BSDLeafId`
is the `flatMap` over the `covers` fields. The registry
`bsd_auditCoverage` and the literal list `bsd_auditCoveredLeaves`
satisfy:

- `bsd_auditCoveredLeaves_eq_flatten` —
  `bsd_auditCoveredLeaves = auditCoverageCoveredLeaves bsd_auditCoverage`
  (closed by `rfl`).
- `bsd_auditCoveredLeaves_count :
   bsd_auditCoveredLeaves.length = 8`.
- `bsd_pendingAuditLeafIds_count :
   bsd_pendingAuditLeafIds.length = 4`.
- `bsd_typedCoverage_count_summary :
   ... = 8 ∧ ... = 4`.
- `bsd_typedCoverage_count_matches_openLeafCount :
   covered + pending = bsd_openLeafIds.length`
  (i.e., `8 + 4 = 12`).

All theorems are closed by `rfl`.

### Two pending registries, on different layers

V3 already provided a string-level pending registry
`bsd_pendingClosureAudit` with `10` entries. V4 adds a typed
pending list `bsd_pendingAuditLeafIds` with `4` entries. The two
counts differ for a specific structural reason:

- The string-level pending list of V3 is **conservative**: it
  marks every refined leaf that has not been thematically named
  inside the closure-audit registry as pending, even if the
  closure-audit registry already covers it through a coarse
  thematic entry.
- The typed pending list of V4 is **relative to the explicit
  `AuditCoverage` relation**: the coarse audit entry
  `higherEulerSystems_stayOpen` explicitly covers all six
  refined higher-rank leaves, so they are not counted as typed
  pending. Only the four refined leaves with no covering audit
  entry remain.

Both registries are correct under their own conventions; the
discrepancy `10 ≠ 4` is itself the discipline-level statement
that the V3 string registry did **not** assume a bijection
between audit entries and refined leaves. V4 makes the implicit
many-to-one (and one-to-zero) thematic mapping into explicit
typed data, and the resulting typed pending count is the count
relative to *that* mapping.

The two registries should be read together, not conflated:

| Registry | Convention | Count |
|---|---|---|
| `bsd_pendingClosureAudit` (V3, string) | conservative; no audit-to-leaf bijection assumed | `10` |
| `bsd_pendingAuditLeafIds` (V4, typed) | relative to the explicit `AuditCoverage` relation | `4` |

Both numbers are theorems (`bsd_pendingClosureAudit_count = 10`,
`bsd_pendingAuditLeafIds_count = 4`); neither is "wrong" — they
measure different things.

### Typed coverage consistency

V4 Task 2 fixed the count identity `8 + 4 = 12`. V4 Task 3
sharpens it to **membership-level** consistency: the two typed
lists are disjoint, both sit inside `bsd_openLeafIds`, and
together they cover exactly the typed open-leaf identifiers.

| Theorem | Statement |
|---|---|
| `bsd_typedCoverage_disjoint` | `id ∈ covered → id ∈ pending → False` |
| `bsd_auditCoveredLeaves_subset_open` | `id ∈ covered → id ∈ openLeafIds` |
| `bsd_pendingAuditLeafIds_subset_open` | `id ∈ pending → id ∈ openLeafIds` |
| `bsd_openLeafIds_covered_or_pending` | `id ∈ openLeafIds → id ∈ covered ∨ id ∈ pending` |
| `bsd_typedCoverage_covers_openLeafIds` | `id ∈ openLeafIds ↔ id ∈ covered ∨ id ∈ pending` |

All five proofs are by case analysis on the sixteen `BSDLeafId`
constructors followed by `decide`.

The three lists are also recorded as duplicate-free:

| Theorem | Statement |
|---|---|
| `bsd_auditCoveredLeaves_nodup` | `bsd_auditCoveredLeaves.Nodup` |
| `bsd_pendingAuditLeafIds_nodup` | `bsd_pendingAuditLeafIds.Nodup` |
| `bsd_openLeafIds_nodup` | `bsd_openLeafIds.Nodup` |

`Nodup` upgrades the count statements to genuine
set-cardinality statements: the typed open leaves are exactly the
sixteen distinct `BSDLeafId` open constructors, and the covered /
pending partition is a literal partition at the set level.

### What this is (and isn't)

> *The V4 typed coverage layer now records not only the counts
> `8 + 4 = 12`, but also the membership-level fact that every
> typed open leaf is either covered by the audit relation or
> pending audit, and never both.*

These theorems are **registry bookkeeping**: they fix the
correctness of the V4 coverage data against the V4 typed leaf
identifiers. They are **not** mathematical theorems about
closure, BSD, or any of the underlying open content. The honest
content of "covered" remains "audited thematically by an audit
entry whose closure status was assigned in
`bsd_partialClosureAudit`"; the typed coverage layer does not
discharge any of those statuses.

### Lookup by `BSDLeafId`

V4 Task 6 adds a leaf-indexed lookup function:

```
BSDLeafId.partialClosureAuditStatus :
  BSDLeafId → Option ClosureAuditStatus
```

The lookup is **strict** with respect to the partial audit:
only the eight typed leaves covered by `bsd_auditCoverage`
return a `some` value; the four pending typed leaves and the
four closed typed leaves return `none`. This avoids the silent
overclaim of pretending the partial audit is exhaustive over the
twelve refined open leaves.

| Typed leaf | Lookup result |
|---|---|
| `shaFiniteSocket` | `some «open»` |
| `shaSelmerInjection` | `some structuralCandidate` |
| six refined higher-rank leaves | each `some «open»` |
| `shaSelmerSurjection`, `shaSelmerExactness`, `bsdLeadingCoefficientFormula`, `bsdRankOrderCompatibility` | `none` (pending) |
| `torsion`, `tamagawa`, `regulator`, `period` | `none` (closed) |

Witness theorems
(`partialClosureAuditStatus_shaFinite`,
`partialClosureAuditStatus_shaSelmerInjection`,
`partialClosureAuditStatus_selmerSurjection_pending`,
`partialClosureAuditStatus_higherRankSelmerControl`) fix the
lookup at representative leaves. Two `iff` consistency theorems
tie the lookup to the typed coverage relation:

- `partialClosureAuditStatus_isSome_iff_covered` —
  `id.partialClosureAuditStatus.isSome ↔ id ∈ bsd_auditCoveredLeaves`;
- `partialClosureAuditStatus_isNone_iff_uncovered` —
  `id.partialClosureAuditStatus = none ↔ id ∉ bsd_auditCoveredLeaves`.

Both are closed by `cases id <;> decide`.

The lookup direction inverts the V4 coverage: instead of
"which leaves does this audit entry cover?", we now ask
"what is the audit status of this typed leaf?". The two
directions agree by the consistency theorems above, and the
combined story is the first time the scaffold lets a reader
*query* a specific typed leaf and get back a typed status.

### Bridge to the string registry

Each `BSDLeafId` value also has a bridge into the string-based
`RefinementLeaf` registry via
`BSDLeafId.toRefinementLeaf` (declared in
`LeafLocalization.lean` and described in
`docs/LeafLocalization.md` §8). A leaf returned by the typed
coverage relation can therefore be projected back to its
human-readable cell with full label/status agreement
(`BSDLeafId.toRefinementLeaf_label`,
`BSDLeafId.toRefinementLeaf_status`).

The combined report for any typed leaf takes the form:

```
id : BSDLeafId
id.toRefinementLeaf : RefinementLeaf                -- human-readable
id.partialClosureAuditStatus : Option ClosureAuditStatus  -- this audit
id.closeabilityStatus : Option CloseabilityStatus         -- closeability
```

### Pending counts revisited

The two pending registries continue to coexist after V4 Task 6:

- `bsd_pendingClosureAudit_count = 10` (V3 string-level,
  conservative — no audit-to-leaf bijection assumed),
- `bsd_pendingAuditLeafIds_count = 4` (V4 typed-level,
  relative to the explicit `AuditCoverage` relation),

and `partialClosureAuditStatus_isNone_iff_uncovered` is the
theorem that ties the V4 lookup's `none` cases back to
`bsd_auditCoveredLeaves` exactly.

---

## 13. Relation to CloseabilityAudit

`PartialClosureAudit` asks **what role each leaf currently
plays**: `closed`, `knownButUninternalized`,
`structuralCandidate`, or `«open»`.

`CloseabilityAudit` (recorded in
`docs/CloseabilityAudit.md`) asks the orthogonal question of
**why each leaf is not closed yet**:
`mathematicallyOpen`, `technicallyHard`, `technicallyHeavy`,
`blockedByModeling`, `closeableNow`.

The two registries are **not** refinements of each other. A
leaf can be `«open»` in the partial closure audit and
`technicallyHard` in the closeability audit; a leaf can be
`structuralCandidate` here and `technicallyHeavy` there. Each
coordinate carries independent information.

Current closeability counts (recorded in `docs/CloseabilityAudit.md`):

| Status | Count |
|---|---|
| `mathematicallyOpen` | `4` |
| `technicallyHard` | `1` |
| `technicallyHeavy` | `1` |
| `blockedByModeling` | `1` |
| `closeableNow` | `0` |

### Warnings on misreading

To avoid the standard misreadings that pair the two registries
incorrectly:

- The closeability audit is **not exhaustive** over the twelve
  refined leaves of `bsd_fullyRefinedLeafLocalizationProfile`,
  in the same sense as `bsd_partialClosureAudit`.
- A `technicallyHard` audit entry is **not** the same as a
  `mathematicallyOpen` entry. The former records that the
  formalization work is heavy; the latter records that the
  mathematical content is open.
- A `closeableNow = 0` count is the **current registry state**.
  It does not assert that no future entry can ever be
  `closeableNow`. If such an entry appears, the discipline
  requires that the leaf be either closed or reclassified.

The orthogonality of the two registries is itself part of the
honest reporting layer: a single status word would erase the
difference between *"open at the frontier"* and *"open because
the API isn't there yet."*

---

End of Partial Closure Audit note.
