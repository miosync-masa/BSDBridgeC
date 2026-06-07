import BSDBridgeC.Profile.LeafLocalization
import BSDBridgeC.WhoWhere.Basic

/-!
# Partial closure audit

`LeafLocalization` records which leaves are currently open in the
typed dependency DAG of the BSD scaffold.  By itself, that is a
one-sided discipline: it lists open leaves, but it does not check
whether each listed open leaf *should* be open.

A scaffold that leaves a closeable leaf open is committing a
**reverse overclaim** — making a problem appear harder than it is.
The slogan recorded in `docs/PartialClosureAudit.md` is:

> **Leaf localization is not a difficulty amplifier.  It is a
> boundary detector.**

This file introduces an audit-status registry that classifies each
candidate open leaf into one of four buckets:

- `closed` — already closed in the scaffold;
- `knownButUninternalized` — known by external mathematics
  (e.g. by classical descent / finite-Selmer theory) but not yet
  internalized in this Lean development;
- `structuralCandidate` — likely closeable once the corresponding
  structural maps are internalized; not yet attempted;
- `«open»` — genuinely open at the present mathematical frontier.

No mathematical claim is added.  No leaf is discharged.  The audit
is taxonomic: it records the current honest status of each entry.
-/

noncomputable section

namespace BSDBridgeC

/-- Audit status of a leaf, refined from the binary
`LeafStatus`.  The four-way split separates leaves that the
scaffold could plausibly close — by Mathlib citation, by structural
construction, or by future refinement — from leaves that are
genuinely open at the present mathematical frontier. -/
inductive ClosureAuditStatus where
  /-- The leaf is already closed in the scaffold. -/
  | closed
  /-- The leaf is known by external mathematics (e.g. descent,
  finite Selmer theory) but is not yet internalized. -/
  | knownButUninternalized
  /-- The leaf is a structural candidate: likely closeable once the
  relevant maps / records are added, no new mathematics needed. -/
  | structuralCandidate
  /-- The leaf is genuinely open. -/
  | «open»
deriving DecidableEq, Repr

/-- A single audit entry recording the closure status of one leaf. -/
structure ClosureAuditEntry where
  leafName : String
  status : ClosureAuditStatus
  reason : String

/-! ## Audit entries

The audit entries below classify several of the open leaves
declared in `Profile/LeafLocalization.lean` (or near them).  An
entry pointing to a leaf with status `«open»` here means **no
honest path to closure is currently visible**; entries pointing to
`knownButUninternalized` or `structuralCandidate` flag a leaf as
*not* genuinely open in the difficulty sense — only uninternalized
or untaken-yet inside this scaffold. -/

/-- Finiteness of finite-level Selmer groups is classical: a
descent argument together with finite-Selmer theory delivers it.
This entry marks the corresponding leaf as known by external
mathematics but not yet internalized in the present scaffold. -/
def selmerFinite_knownButUninternalized : ClosureAuditEntry :=
  { leafName := "finite-level Selmer finiteness"
    status := .knownButUninternalized
    reason :=
      "known by descent / finite-level Selmer theory, but not internalized in this scaffold" }

/-- The Mordell--Weil-to-Selmer injection is part of the standard
Selmer exact-sequence construction.  It is a structural candidate
for closure: once the appropriate maps are introduced, no further
mathematical input is needed. -/
def mordellWeilToSelmerInjection_structuralCandidate : ClosureAuditEntry :=
  { leafName := "Mordell-Weil to Selmer injection"
    status := .structuralCandidate
    reason :=
      "part of the Selmer exact-sequence construction; closeable once maps are internalized" }

/-- Global finiteness of the Tate--Shafarevich group `Sha` is a
genuine BSD-side open question.  This entry preserves it as
`«open»` after audit. -/
def shaGlobalFiniteness_staysOpen : ClosureAuditEntry :=
  { leafName := "global Sha finiteness"
    status := .«open»
    reason :=
      "general Sha finiteness remains a genuine BSD open socket" }

/-- Existence of higher-rank Euler / Kolyvagin systems for
`r ≥ 2` is not supplied by this scaffold and is a genuine
open question at the present mathematical frontier. -/
def higherEulerSystems_stayOpen : ClosureAuditEntry :=
  { leafName := "higher Euler systems r >= 2"
    status := .«open»
    reason :=
      "existence of higher-rank Euler/Kolyvagin systems is not supplied" }

/-- The BSD-branch partial closure audit registry. -/
def bsd_partialClosureAudit : List ClosureAuditEntry :=
  [ selmerFinite_knownButUninternalized,
    mordellWeilToSelmerInjection_structuralCandidate,
    shaGlobalFiniteness_staysOpen,
    higherEulerSystems_stayOpen ]

/-! ## Boolean discriminators on audit status -/

/-- True iff the audit status is `«open»`. -/
def ClosureAuditStatus.isOpen : ClosureAuditStatus → Bool
  | .«open» => true
  | _ => false

/-- True iff the audit status is `knownButUninternalized`. -/
def ClosureAuditStatus.isKnownButUninternalized :
    ClosureAuditStatus → Bool
  | .knownButUninternalized => true
  | _ => false

/-- True iff the audit status is `structuralCandidate`. -/
def ClosureAuditStatus.isStructuralCandidate :
    ClosureAuditStatus → Bool
  | .structuralCandidate => true
  | _ => false

/-- True iff the audit status is `closed`. -/
def ClosureAuditStatus.isClosed : ClosureAuditStatus → Bool
  | .closed => true
  | _ => false

/-! ## Audit-status witness theorems

These are not closure proofs.  They are tag-witnesses: each fixes
the recorded audit status of one entry, so that the registry's
content is itself a `#check`-able claim. -/

/-- `shaGlobalFiniteness_staysOpen` is recorded as `«open»`. -/
theorem shaGlobalFiniteness_audit_is_open :
    shaGlobalFiniteness_staysOpen.status = .«open» := by
  rfl

/-- `selmerFinite_knownButUninternalized` is recorded as
`knownButUninternalized`. -/
theorem selmerFinite_audit_is_knownButUninternalized :
    selmerFinite_knownButUninternalized.status =
      .knownButUninternalized := by
  rfl

/-- `mordellWeilToSelmerInjection_structuralCandidate` is recorded
as `structuralCandidate`. -/
theorem mordellWeilInjection_audit_is_structuralCandidate :
    mordellWeilToSelmerInjection_structuralCandidate.status =
      .structuralCandidate := by
  rfl

/-- `higherEulerSystems_stayOpen` is recorded as `«open»`. -/
theorem higherEulerSystems_audit_is_open :
    higherEulerSystems_stayOpen.status = .«open» := by
  rfl

/-! ## Entry-level Boolean discriminators

Lift the `ClosureAuditStatus.is*` predicates to the entry level so
that they can be used directly as predicates over
`List ClosureAuditEntry`. -/

/-- True iff the entry's recorded audit status is `«open»`. -/
def ClosureAuditEntry.isOpen (E : ClosureAuditEntry) : Bool :=
  E.status.isOpen

/-- True iff the entry's recorded audit status is
`knownButUninternalized`. -/
def ClosureAuditEntry.isKnownButUninternalized
    (E : ClosureAuditEntry) : Bool :=
  E.status.isKnownButUninternalized

/-- True iff the entry's recorded audit status is
`structuralCandidate`. -/
def ClosureAuditEntry.isStructuralCandidate
    (E : ClosureAuditEntry) : Bool :=
  E.status.isStructuralCandidate

/-- True iff the entry's recorded audit status is `closed`. -/
def ClosureAuditEntry.isClosed (E : ClosureAuditEntry) : Bool :=
  E.status.isClosed

/-! ## Audit-registry partition counts

These counts measure the audit registry's partition of its
entries, not the leaf-localization granularity (which is counted
separately in `LeafLocalization.lean`).  Counting here is
deliberately registry-local: it does **not** claim to be a count
over all twelve leaves of `bsd_fullyRefinedLeafLocalizationProfile`,
since the audit registry is currently a representative subset. -/

/-- Count entries audited as `«open»`. -/
def closureAudit_openCount
    (entries : List ClosureAuditEntry) : ℕ :=
  (entries.filter ClosureAuditEntry.isOpen).length

/-- Count entries audited as `knownButUninternalized`. -/
def closureAudit_knownButUninternalizedCount
    (entries : List ClosureAuditEntry) : ℕ :=
  (entries.filter ClosureAuditEntry.isKnownButUninternalized).length

/-- Count entries audited as `structuralCandidate`. -/
def closureAudit_structuralCandidateCount
    (entries : List ClosureAuditEntry) : ℕ :=
  (entries.filter ClosureAuditEntry.isStructuralCandidate).length

/-- Count entries audited as `closed`. -/
def closureAudit_closedCount
    (entries : List ClosureAuditEntry) : ℕ :=
  (entries.filter ClosureAuditEntry.isClosed).length

/-! ### Concrete counts for `bsd_partialClosureAudit` -/

/-- Two entries of `bsd_partialClosureAudit` are audited as
`«open»` (`shaGlobalFiniteness_staysOpen`,
`higherEulerSystems_stayOpen`). -/
theorem bsd_partialClosureAudit_openCount :
    closureAudit_openCount bsd_partialClosureAudit = 2 := by
  decide

/-- One entry of `bsd_partialClosureAudit` is audited as
`knownButUninternalized` (`selmerFinite_knownButUninternalized`). -/
theorem bsd_partialClosureAudit_knownButUninternalizedCount :
    closureAudit_knownButUninternalizedCount
      bsd_partialClosureAudit = 1 := by
  decide

/-- One entry of `bsd_partialClosureAudit` is audited as
`structuralCandidate`
(`mordellWeilToSelmerInjection_structuralCandidate`). -/
theorem bsd_partialClosureAudit_structuralCandidateCount :
    closureAudit_structuralCandidateCount
      bsd_partialClosureAudit = 1 := by
  decide

/-- No entry of `bsd_partialClosureAudit` is audited as
`closed`. -/
theorem bsd_partialClosureAudit_closedCount :
    closureAudit_closedCount bsd_partialClosureAudit = 0 := by
  decide

/-- Summary partition theorem for `bsd_partialClosureAudit`:
`(2, 1, 1, 0)` across the four audit statuses
(`«open»`, `knownButUninternalized`, `structuralCandidate`,
`closed`). -/
theorem bsd_partialClosureAudit_partition_counts :
    closureAudit_openCount bsd_partialClosureAudit = 2 ∧
    closureAudit_knownButUninternalizedCount
      bsd_partialClosureAudit = 1 ∧
    closureAudit_structuralCandidateCount
      bsd_partialClosureAudit = 1 ∧
    closureAudit_closedCount bsd_partialClosureAudit = 0 := by
  decide

/-! ## Pending audit registry

The audit registry `bsd_partialClosureAudit` above is **not** a
one-to-one partition of the twelve refined open leaves of
`bsd_fullyRefinedLeafLocalizationProfile`.  Its entries are
*thematic*: each audits a mathematical concern that may correspond
to one or more refined leaves (or, in the case of
`selmerFinite_knownButUninternalized`, to none of the twelve
refined leaves directly).

To avoid the silent overclaim of treating un-audited leaves as if
they were already classified, the refined leaves not yet covered
thematically by `bsd_partialClosureAudit` are recorded as
**pending audit**.  A pending entry is **not** the same as an
audit-`«open»` entry: a pending entry has not been classified at
all.

Below we enumerate the ten refined leaves whose audit status is
pending. -/

/-- A leaf whose closure status has not yet been audited.  The
`reason` field records what kind of audit is still owed. -/
structure PendingAuditEntry where
  leafName : String
  reason : String

/-! ### Pending entries (10 refined leaves) -/

/-- Pending: `sha_selmer_surjection_open_leaf`. -/
def selmerShaSurjection_pendingAudit : PendingAuditEntry :=
  { leafName := "Selmer-Sha surjection socket"
    reason :=
      "surjection in the Selmer/Sha exact sequence; audit status not yet assigned" }

/-- Pending: `sha_selmer_exactness_open_leaf`. -/
def selmerShaExactness_pendingAudit : PendingAuditEntry :=
  { leafName := "Selmer-Sha exactness socket"
    reason :=
      "exactness of the Selmer/Sha sequence; audit status not yet assigned" }

/-- Pending: `bsd_leadingCoefficientFormula_open_leaf`. -/
def bsdLeadingCoefficientFormula_pendingAudit : PendingAuditEntry :=
  { leafName := "BSD leading coefficient formula"
    reason :=
      "central-Taylor leading-coefficient compatibility; audit status not yet assigned" }

/-- Pending: `bsd_rankOrderCompatibility_open_leaf`. -/
def bsdRankOrderCompatibility_pendingAudit : PendingAuditEntry :=
  { leafName := "BSD rank/order compatibility"
    reason :=
      "rank/order compatibility socket of BSDWhoWhereCompatible; audit pending" }

/-- Pending: `higherEuler_normCompatibility_open_leaf`. -/
def higherEulerNormCompatibility_pendingAudit : PendingAuditEntry :=
  { leafName := "higher Euler norm compatibility"
    reason :=
      "norm_compatibility field of HigherEulerSystem; audit pending" }

/-- Pending: `higherKolyvagin_localRelations_open_leaf`. -/
def higherKolyvaginLocalRelations_pendingAudit : PendingAuditEntry :=
  { leafName := "higher Kolyvagin local relations"
    reason :=
      "local_relations field of HigherKolyvaginSystem; audit pending" }

/-- Pending: `higherKolyvagin_derivativeLaw_open_leaf`. -/
def higherKolyvaginDerivativeLaw_pendingAudit : PendingAuditEntry :=
  { leafName := "higher Kolyvagin derivative law"
    reason :=
      "derivative_law field of HigherKolyvaginDerivative; audit pending" }

/-- Pending: `higherRank_regulatorCompatibility_open_leaf`. -/
def higherRankRegulatorCompatibility_pendingAudit : PendingAuditEntry :=
  { leafName := "higher-rank regulator compatibility"
    reason :=
      "compatibility_law field of RegulatorCompatibility; audit pending" }

/-- Pending: `higherRank_selmerControl_open_leaf`. -/
def higherRankSelmerControl_pendingAudit : PendingAuditEntry :=
  { leafName := "higher-rank Selmer control"
    reason :=
      "control_law field of SelmerControl; audit pending" }

/-- Pending: `higherRank_analyticRankCompatibility_open_leaf`. -/
def higherRankAnalyticRankCompatibility_pendingAudit : PendingAuditEntry :=
  { leafName := "higher-rank analytic/algebraic rank compatibility"
    reason :=
      "analytic_matches_algebraic field of CoreRankBSDRankCompatibility; audit pending" }

/-- BSD-branch pending-audit registry.  These ten refined leaves
have not yet been classified by `bsd_partialClosureAudit`; the
list intentionally does **not** assign them any audit status. -/
def bsd_pendingClosureAudit : List PendingAuditEntry :=
  [ selmerShaSurjection_pendingAudit,
    selmerShaExactness_pendingAudit,
    bsdLeadingCoefficientFormula_pendingAudit,
    bsdRankOrderCompatibility_pendingAudit,
    higherEulerNormCompatibility_pendingAudit,
    higherKolyvaginLocalRelations_pendingAudit,
    higherKolyvaginDerivativeLaw_pendingAudit,
    higherRankRegulatorCompatibility_pendingAudit,
    higherRankSelmerControl_pendingAudit,
    higherRankAnalyticRankCompatibility_pendingAudit ]

/-- Count pending-audit entries. -/
def pendingAuditCount (entries : List PendingAuditEntry) : ℕ :=
  entries.length

/-- The current pending-audit registry contains `10` entries. -/
theorem bsd_pendingClosureAudit_count :
    pendingAuditCount bsd_pendingClosureAudit = 10 := by
  decide

/-- The current partial audit is **not** exhaustive: the pending
registry is nonempty. -/
theorem bsd_partialAudit_is_not_exhaustive :
    pendingAuditCount bsd_pendingClosureAudit ≠ 0 := by
  decide

/-! ## V4 typed audit coverage

The audit registry above is **thematic**: an audit entry is
described by a string `leafName` and may correspond to one, many,
or zero refined leaves of the localization profile.  V4 makes the
relationship explicit by attaching each audit entry to a typed
list of `BSDLeafId` values.

Coverage is **not** a proof.  An entry that "covers" a typed leaf
only records the *intent* of the audit: it explains which leaves
the audit means to address.  Whether the underlying leaf is then
closed, known-but-uninternalized, or open is a separate question
(answered by `PartialClosureAudit` and `CloseabilityAudit`).

This typed coverage relation is added non-destructively: the
string-based `bsd_partialClosureAudit` and the string-based
`bsd_pendingClosureAudit` are preserved unchanged. -/

/-- A typed relation recording which BSD refined leaves an audit
entry thematically covers. -/
structure AuditCoverage where
  auditName : String
  covers : List BSDLeafId

/-- Coverage of `shaGlobalFiniteness_staysOpen`: the
`shaFiniteSocket` refined leaf. -/
def shaGlobalFiniteness_auditCoverage : AuditCoverage :=
  { auditName := "global Sha finiteness"
    covers := [BSDLeafId.shaFiniteSocket] }

/-- Coverage of
`mordellWeilToSelmerInjection_structuralCandidate`: the
`shaSelmerInjection` refined leaf. -/
def mordellWeilInjection_auditCoverage : AuditCoverage :=
  { auditName := "Mordell-Weil to Selmer injection"
    covers := [BSDLeafId.shaSelmerInjection] }

/-- Coverage of `higherEulerSystems_stayOpen`: the six refined
higher-rank leaves of the fully refined profile.  This entry is
the example of a single audit entry covering many refined
leaves. -/
def higherEulerSystems_auditCoverage : AuditCoverage :=
  { auditName := "higher Euler systems r >= 2"
    covers :=
      [ BSDLeafId.higherEulerNormCompatibility,
        BSDLeafId.higherKolyvaginLocalRelations,
        BSDLeafId.higherKolyvaginDerivativeLaw,
        BSDLeafId.higherRankRegulatorCompatibility,
        BSDLeafId.higherRankSelmerControl,
        BSDLeafId.higherRankAnalyticRankCompatibility ] }

/-- Coverage of `selmerFinite_knownButUninternalized`: empty.

`selmerFinite_knownButUninternalized` is thematically about
finite-level Selmer finiteness, which is **not** itself one of
the twelve refined leaves of the fully refined profile.  The
audit entry exists in the closure-audit registry but covers no
typed leaf directly.  This is the precise reason the closure-audit
registry was not a partition of the twelve refined leaves. -/
def selmerFinite_auditCoverage : AuditCoverage :=
  { auditName := "finite-level Selmer finiteness"
    covers := [] }

/-- The BSD typed audit-coverage registry, parallel to
`bsd_partialClosureAudit` at the string level. -/
def bsd_auditCoverage : List AuditCoverage :=
  [ shaGlobalFiniteness_auditCoverage,
    mordellWeilInjection_auditCoverage,
    higherEulerSystems_auditCoverage,
    selmerFinite_auditCoverage ]

/-- Flatten an audit-coverage list into the union of covered
typed leaves (with multiplicity preserved). -/
def auditCoverageCoveredLeaves
    (entries : List AuditCoverage) : List BSDLeafId :=
  entries.flatMap (fun e => e.covers)

/-- The typed leaves covered by `bsd_auditCoverage`, recorded as a
literal list for `rfl`-friendly count theorems.  Equality with the
flattened-coverage form is recorded separately by
`bsd_auditCoveredLeaves_eq_flatten`. -/
def bsd_auditCoveredLeaves : List BSDLeafId :=
  [ BSDLeafId.shaFiniteSocket,
    BSDLeafId.shaSelmerInjection,
    BSDLeafId.higherEulerNormCompatibility,
    BSDLeafId.higherKolyvaginLocalRelations,
    BSDLeafId.higherKolyvaginDerivativeLaw,
    BSDLeafId.higherRankRegulatorCompatibility,
    BSDLeafId.higherRankSelmerControl,
    BSDLeafId.higherRankAnalyticRankCompatibility ]

/-- The literal `bsd_auditCoveredLeaves` agrees with the flattened
form of `bsd_auditCoverage`.  Closed by `rfl` after definitional
unfolding of `flatMap` on a literal list. -/
theorem bsd_auditCoveredLeaves_eq_flatten :
    bsd_auditCoveredLeaves =
      auditCoverageCoveredLeaves bsd_auditCoverage := rfl

/-- The typed leaves *not* covered by `bsd_auditCoverage`,
recorded directly as a list (relative to the coverage relation,
not to the string-level `bsd_pendingClosureAudit`). -/
def bsd_pendingAuditLeafIds : List BSDLeafId :=
  [ BSDLeafId.shaSelmerSurjection,
    BSDLeafId.shaSelmerExactness,
    BSDLeafId.bsdLeadingCoefficientFormula,
    BSDLeafId.bsdRankOrderCompatibility ]

/-! ### Concrete count theorems -/

/-- `bsd_auditCoveredLeaves` has `8` entries: one Sha finite, one
Sha injection, and six higher-rank refined leaves. -/
theorem bsd_auditCoveredLeaves_count :
    bsd_auditCoveredLeaves.length = 8 := rfl

/-- `bsd_pendingAuditLeafIds` has `4` entries. -/
theorem bsd_pendingAuditLeafIds_count :
    bsd_pendingAuditLeafIds.length = 4 := rfl

/-- Summary count: covered `8` + pending `4` = open-leaf count
`12`.  This is a count-level statement only; it does **not**
assert disjointness or set-equality of the underlying typed lists. -/
theorem bsd_typedCoverage_count_summary :
    bsd_auditCoveredLeaves.length = 8 ∧
    bsd_pendingAuditLeafIds.length = 4 :=
  ⟨bsd_auditCoveredLeaves_count, bsd_pendingAuditLeafIds_count⟩

/-- Sum of covered and pending typed counts equals the typed
`bsd_openLeafIds` length.  Count-level only. -/
theorem bsd_typedCoverage_count_matches_openLeafCount :
    bsd_auditCoveredLeaves.length + bsd_pendingAuditLeafIds.length =
      bsd_openLeafIds.length := rfl

/-! ### Membership-level consistency

V4 Task 2 fixed the count `8 + 4 = 12`.  V4 Task 3 sharpens this
to the membership level: covered and pending typed leaves are
disjoint, both are subsets of `bsd_openLeafIds`, and together they
cover exactly the typed open-leaf identifiers.

These are registry-bookkeeping facts, not mathematical theorems
about the underlying problem.  All five proofs are by case
analysis on the sixteen typed leaf constructors followed by
`decide`. -/

/-- A typed leaf cannot be both covered by the audit and listed
as pending. -/
theorem bsd_typedCoverage_disjoint :
    ∀ id : BSDLeafId,
      id ∈ bsd_auditCoveredLeaves →
      id ∈ bsd_pendingAuditLeafIds → False := by
  intro id; cases id <;> decide

/-- Every covered typed leaf is one of the typed open-leaf
identifiers. -/
theorem bsd_auditCoveredLeaves_subset_open :
    ∀ id : BSDLeafId,
      id ∈ bsd_auditCoveredLeaves → id ∈ bsd_openLeafIds := by
  intro id; cases id <;> decide

/-- Every pending typed leaf is one of the typed open-leaf
identifiers. -/
theorem bsd_pendingAuditLeafIds_subset_open :
    ∀ id : BSDLeafId,
      id ∈ bsd_pendingAuditLeafIds → id ∈ bsd_openLeafIds := by
  intro id; cases id <;> decide

/-- Every typed open-leaf identifier is either covered by the
audit or pending. -/
theorem bsd_openLeafIds_covered_or_pending :
    ∀ id : BSDLeafId,
      id ∈ bsd_openLeafIds →
      id ∈ bsd_auditCoveredLeaves ∨
        id ∈ bsd_pendingAuditLeafIds := by
  intro id; cases id <;> decide

/-- Membership-level statement: the typed open-leaf identifiers
are exactly the disjoint union of `bsd_auditCoveredLeaves` and
`bsd_pendingAuditLeafIds`. -/
theorem bsd_typedCoverage_covers_openLeafIds :
    ∀ id : BSDLeafId,
      id ∈ bsd_openLeafIds ↔
        id ∈ bsd_auditCoveredLeaves ∨
          id ∈ bsd_pendingAuditLeafIds := by
  intro id; cases id <;> decide

/-! ### `Nodup` witnesses

The three typed lists are duplicate-free.  These witnesses
upgrade the count statements to genuine set-cardinality
statements about the underlying typed identifiers. -/

/-- `bsd_auditCoveredLeaves` contains no duplicates. -/
theorem bsd_auditCoveredLeaves_nodup :
    bsd_auditCoveredLeaves.Nodup := by decide

/-- `bsd_pendingAuditLeafIds` contains no duplicates. -/
theorem bsd_pendingAuditLeafIds_nodup :
    bsd_pendingAuditLeafIds.Nodup := by decide

/-- `bsd_openLeafIds` contains no duplicates. -/
theorem bsd_openLeafIds_nodup :
    bsd_openLeafIds.Nodup := by decide

/-! ### Leaf-indexed lookup of partial-audit status

A `BSDLeafId → Option ClosureAuditStatus` function inverts the
typed coverage relation: given a typed leaf, it returns the
status assigned by `bsd_partialClosureAudit` if the leaf is
covered, and `none` otherwise.

The lookup is **strict** with respect to the partial audit: only
the eight covered typed leaves get a `some` value.  The four
pending typed leaves and the four closed typed leaves return
`none`.  This avoids the silent overclaim of pretending the
partial audit is exhaustive. -/

/-- Strict partial-audit status of a typed leaf.  Returns `some`
exactly for the eight typed leaves covered by
`bsd_auditCoverage`; the four pending typed leaves and the four
closed typed leaves return `none`. -/
def BSDLeafId.partialClosureAuditStatus :
    BSDLeafId → Option ClosureAuditStatus
  | .shaFiniteSocket => some .«open»
  | .shaSelmerInjection => some .structuralCandidate
  | .higherEulerNormCompatibility => some .«open»
  | .higherKolyvaginLocalRelations => some .«open»
  | .higherKolyvaginDerivativeLaw => some .«open»
  | .higherRankRegulatorCompatibility => some .«open»
  | .higherRankSelmerControl => some .«open»
  | .higherRankAnalyticRankCompatibility => some .«open»
  | _ => none

/-! ### Lookup witness theorems -/

/-- `shaFiniteSocket` is partially audited as `«open»`. -/
theorem partialClosureAuditStatus_shaFinite :
    BSDLeafId.partialClosureAuditStatus
      .shaFiniteSocket = some .«open» := rfl

/-- `shaSelmerInjection` is partially audited as
`structuralCandidate`. -/
theorem partialClosureAuditStatus_shaSelmerInjection :
    BSDLeafId.partialClosureAuditStatus
      .shaSelmerInjection = some .structuralCandidate := rfl

/-- `shaSelmerSurjection` is pending: no partial-audit status. -/
theorem partialClosureAuditStatus_selmerSurjection_pending :
    BSDLeafId.partialClosureAuditStatus
      .shaSelmerSurjection = none := rfl

/-- `higherRankSelmerControl` is partially audited as `«open»`. -/
theorem partialClosureAuditStatus_higherRankSelmerControl :
    BSDLeafId.partialClosureAuditStatus
      .higherRankSelmerControl = some .«open» := rfl

/-! ### Coverage/lookup consistency theorems -/

/-- A typed leaf has a partial-audit status iff it is covered by
the typed audit relation. -/
theorem partialClosureAuditStatus_isSome_iff_covered :
    ∀ id : BSDLeafId,
      id.partialClosureAuditStatus.isSome = true ↔
        id ∈ bsd_auditCoveredLeaves := by
  intro id; cases id <;> decide

/-- A typed leaf has no partial-audit status iff it is uncovered
(i.e. pending or closed). -/
theorem partialClosureAuditStatus_isNone_iff_uncovered :
    ∀ id : BSDLeafId,
      id.partialClosureAuditStatus = none ↔
        id ∉ bsd_auditCoveredLeaves := by
  intro id; cases id <;> decide

end BSDBridgeC
