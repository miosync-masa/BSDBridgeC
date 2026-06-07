import BSDBridgeC.Profile.PartialClosureAudit

/-!
# Closeability audit

`PartialClosureAudit` classified each audited leaf into one of
four buckets according to its **current scaffold role**
(`closed` / `knownButUninternalized` / `structuralCandidate` /
`«open»`).  Closeability audit asks the next question:

> *Why is this leaf not closed yet?*

A leaf can be open for very different reasons:

- it is genuinely unsolved at the mathematical frontier;
- it is known mathematically but its formalization is a serious
  project (descent, exact sequences, etc.);
- it is closeable in principle but the API / records / maps have
  not yet been internalized;
- the surrounding abstractions are too coarse to even decide
  closeability yet;
- it should already be closed and leaving it open would be a
  reverse overclaim.

This file registers these distinctions as a typed status taxonomy
and audits each open leaf accordingly.  No new mathematics is
introduced; the file is a classification registry.

The slogan recorded in `docs/CloseabilityAudit.md`:

> **Open is not a single color.**  Some open leaves are
> mathematically open; others are merely expensive,
> under-modeled, or awaiting internalization.
-/

noncomputable section

namespace BSDBridgeC

/-! ## Closeability status

Five-way classification of why a leaf is currently not closed.
The five values are mutually exclusive at the audit-entry level. -/

/-- Why a leaf is not currently closed in the Lean scaffold. -/
inductive CloseabilityStatus where
  /-- Genuinely unsolved at the mathematical frontier. -/
  | mathematicallyOpen
  /-- Known mathematically; serious formalization project. -/
  | technicallyHard
  /-- Closeable in principle, mostly engineering / API work. -/
  | technicallyHeavy
  /-- Current abstraction too coarse to decide closeability. -/
  | blockedByModeling
  /-- Should be closed now; leaving it open is a reverse
  overclaim. -/
  | closeableNow
deriving DecidableEq, Repr

/-- A closeability audit entry for a leaf or thematic socket. -/
structure CloseabilityAuditEntry where
  leafName : String
  status : CloseabilityStatus
  reason : String

/-! ## BSD closeability audit entries -/

/-- Sha global finiteness: genuinely open. -/
def shaGlobalFiniteness_mathematicallyOpen :
    CloseabilityAuditEntry :=
  { leafName := "global Sha finiteness"
    status := .mathematicallyOpen
    reason :=
      "general Sha finiteness is a genuine BSD-frontier open problem" }

/-- Higher Euler / Kolyvagin systems for `r ≥ 2`: genuinely open. -/
def higherEulerSystems_mathematicallyOpen :
    CloseabilityAuditEntry :=
  { leafName := "higher Euler/Kolyvagin systems r >= 2"
    status := .mathematicallyOpen
    reason :=
      "existence of higher-rank Euler/Kolyvagin systems is not generally available" }

/-- Finite-level Selmer finiteness: known by descent, but a
substantial formalization project to internalize. -/
def selmerFinite_technicallyHard :
    CloseabilityAuditEntry :=
  { leafName := "finite-level Selmer finiteness"
    status := .technicallyHard
    reason :=
      "known by descent / finite-level Selmer theory; nontrivial formalization" }

/-- Mordell-Weil-to-Selmer injection: structural, mostly
engineering once the maps are introduced. -/
def mordellWeilToSelmerInjection_technicallyHeavy :
    CloseabilityAuditEntry :=
  { leafName := "Mordell-Weil to Selmer injection"
    status := .technicallyHeavy
    reason :=
      "structural; closeable once maps and quotient objects are modeled in the Selmer/Sha package" }

/-- Selmer/Sha exactness: cannot be assessed until the maps in
the Selmer/Sha package are concretely modeled. -/
def selmerShaExactness_blockedByModeling :
    CloseabilityAuditEntry :=
  { leafName := "Selmer-Sha exactness"
    status := .blockedByModeling
    reason :=
      "exactness cannot be assessed until the maps in SelmerShaExactPackage are explicit" }

/-- The BSD leading-coefficient formula: the central BSD identity,
mathematically open. -/
def bsdLeadingCoefficientFormula_mathematicallyOpen :
    CloseabilityAuditEntry :=
  { leafName := "BSD leading coefficient formula"
    status := .mathematicallyOpen
    reason :=
      "this is the central BSD formula and is not proved in general" }

/-- BSD rank/order compatibility (analytic rank = algebraic rank):
mathematically open. -/
def bsdRankOrderCompatibility_mathematicallyOpen :
    CloseabilityAuditEntry :=
  { leafName := "BSD rank/order compatibility"
    status := .mathematicallyOpen
    reason :=
      "analytic rank equals algebraic rank is the rank part of BSD" }

/-- BSD closeability audit registry. -/
def bsd_closeabilityAudit : List CloseabilityAuditEntry :=
  [ shaGlobalFiniteness_mathematicallyOpen,
    higherEulerSystems_mathematicallyOpen,
    selmerFinite_technicallyHard,
    mordellWeilToSelmerInjection_technicallyHeavy,
    selmerShaExactness_blockedByModeling,
    bsdLeadingCoefficientFormula_mathematicallyOpen,
    bsdRankOrderCompatibility_mathematicallyOpen ]

/-! ## Boolean discriminators -/

/-- True iff the status is `mathematicallyOpen`. -/
def CloseabilityStatus.isMathematicallyOpen :
    CloseabilityStatus → Bool
  | .mathematicallyOpen => true
  | _ => false

/-- True iff the status is `technicallyHard`. -/
def CloseabilityStatus.isTechnicallyHard :
    CloseabilityStatus → Bool
  | .technicallyHard => true
  | _ => false

/-- True iff the status is `technicallyHeavy`. -/
def CloseabilityStatus.isTechnicallyHeavy :
    CloseabilityStatus → Bool
  | .technicallyHeavy => true
  | _ => false

/-- True iff the status is `blockedByModeling`. -/
def CloseabilityStatus.isBlockedByModeling :
    CloseabilityStatus → Bool
  | .blockedByModeling => true
  | _ => false

/-- True iff the status is `closeableNow`. -/
def CloseabilityStatus.isCloseableNow :
    CloseabilityStatus → Bool
  | .closeableNow => true
  | _ => false

/-! ## Counts and partition -/

/-- Count audit entries whose status satisfies a `Bool` predicate. -/
def closeabilityCountBy
    (p : CloseabilityStatus → Bool)
    (entries : List CloseabilityAuditEntry) : ℕ :=
  (entries.filter (fun E => p E.status)).length

/-! ### Concrete counts for `bsd_closeabilityAudit`

Four entries are mathematically open (Sha global finiteness, higher
Euler/Kolyvagin systems, BSD leading coefficient formula, BSD
rank/order compatibility); one each is technically hard, technically
heavy, blocked by modeling; none are closeable-now. -/

/-- Four `bsd_closeabilityAudit` entries are mathematically open. -/
theorem bsd_closeabilityAudit_mathematicallyOpenCount :
    closeabilityCountBy CloseabilityStatus.isMathematicallyOpen
      bsd_closeabilityAudit = 4 := by
  decide

/-- One `bsd_closeabilityAudit` entry is technically hard. -/
theorem bsd_closeabilityAudit_technicallyHardCount :
    closeabilityCountBy CloseabilityStatus.isTechnicallyHard
      bsd_closeabilityAudit = 1 := by
  decide

/-- One `bsd_closeabilityAudit` entry is technically heavy. -/
theorem bsd_closeabilityAudit_technicallyHeavyCount :
    closeabilityCountBy CloseabilityStatus.isTechnicallyHeavy
      bsd_closeabilityAudit = 1 := by
  decide

/-- One `bsd_closeabilityAudit` entry is blocked by modeling. -/
theorem bsd_closeabilityAudit_blockedByModelingCount :
    closeabilityCountBy CloseabilityStatus.isBlockedByModeling
      bsd_closeabilityAudit = 1 := by
  decide

/-- No `bsd_closeabilityAudit` entry is closeable-now.  If this
count becomes nonzero, the offending entry must be closed (or
reclassified) to avoid a reverse overclaim. -/
theorem bsd_closeabilityAudit_closeableNowCount :
    closeabilityCountBy CloseabilityStatus.isCloseableNow
      bsd_closeabilityAudit = 0 := by
  decide

/-- Summary partition for `bsd_closeabilityAudit`:
`(4, 1, 1, 1, 0)` across the five closeability statuses
(`mathematicallyOpen`, `technicallyHard`, `technicallyHeavy`,
`blockedByModeling`, `closeableNow`). -/
theorem bsd_closeabilityAudit_partition_counts :
    closeabilityCountBy CloseabilityStatus.isMathematicallyOpen
        bsd_closeabilityAudit = 4 ∧
    closeabilityCountBy CloseabilityStatus.isTechnicallyHard
        bsd_closeabilityAudit = 1 ∧
    closeabilityCountBy CloseabilityStatus.isTechnicallyHeavy
        bsd_closeabilityAudit = 1 ∧
    closeabilityCountBy CloseabilityStatus.isBlockedByModeling
        bsd_closeabilityAudit = 1 ∧
    closeabilityCountBy CloseabilityStatus.isCloseableNow
        bsd_closeabilityAudit = 0 := by
  decide

/-! ## Registry hygiene

`closeableNow` is not a stable resting state for an audit entry:
it explicitly means *"this leaf should be closed already, or
reclassified".*  A closeability registry that contains a
`closeableNow` entry is therefore in a state of pending operational
work.

The hygiene predicate below records the negation of that state:
the registry is *hygiene-clean* exactly when no audited entry
sits in `closeableNow`.  This is not a mathematical theorem about
the underlying problem; it is a **registry-hygiene invariant**
that the maintainer must preserve.  Future entries marked
`closeableNow` are flagged for action (close or reclassify), not
for indefinite parking under an open-looking label. -/

/-- A closeability registry is hygiene-clean if it has no
`closeableNow` entries left unresolved. -/
def CloseabilityRegistryHygieneClean
    (entries : List CloseabilityAuditEntry) : Prop :=
  closeabilityCountBy CloseabilityStatus.isCloseableNow entries = 0

/-- The current `bsd_closeabilityAudit` is hygiene-clean: no
entry is `closeableNow`.  This is the registry-hygiene invariant
discharged for the present registry; future entries marked
`closeableNow` would break it until the leaf is closed or
reclassified. -/
theorem bsd_closeabilityAudit_hygieneClean :
    CloseabilityRegistryHygieneClean bsd_closeabilityAudit :=
  bsd_closeabilityAudit_closeableNowCount

/-- Re-export of the `closeableNow` zero count as a hygiene
witness.  Forwarded from `bsd_closeabilityAudit_closeableNowCount`. -/
theorem bsd_closeabilityAudit_has_no_closeableNow :
    closeabilityCountBy CloseabilityStatus.isCloseableNow
      bsd_closeabilityAudit = 0 :=
  bsd_closeabilityAudit_closeableNowCount

/-! ## V4 typed closeability coverage

V4 Task 5 extends the typed-coverage pattern from
`PartialClosureAudit` to `CloseabilityAudit`.  Each closeability
entry is paired with the list of `BSDLeafId` values it
*explains*: the reason recorded by that entry applies to those
typed leaves.

Coverage is not a proof of closure or of openness.  It is the
typed record of which reason applies to which leaf. -/

/-- A typed relation recording which refined typed leaves a
closeability entry explains, together with the entry's audit
status. -/
structure CloseabilityCoverage where
  closeabilityName : String
  status : CloseabilityStatus
  covers : List BSDLeafId

/-- `shaGlobalFiniteness_mathematicallyOpen` explains the
`shaFiniteSocket` refined leaf. -/
def shaGlobalFiniteness_closeabilityCoverage : CloseabilityCoverage :=
  { closeabilityName := "global Sha finiteness"
    status := .mathematicallyOpen
    covers := [BSDLeafId.shaFiniteSocket] }

/-- `higherEulerSystems_mathematicallyOpen` explains all six
refined higher-rank leaves. -/
def higherEulerSystems_closeabilityCoverage : CloseabilityCoverage :=
  { closeabilityName := "higher Euler/Kolyvagin systems r >= 2"
    status := .mathematicallyOpen
    covers :=
      [ BSDLeafId.higherEulerNormCompatibility,
        BSDLeafId.higherKolyvaginLocalRelations,
        BSDLeafId.higherKolyvaginDerivativeLaw,
        BSDLeafId.higherRankRegulatorCompatibility,
        BSDLeafId.higherRankSelmerControl,
        BSDLeafId.higherRankAnalyticRankCompatibility ] }

/-- `bsdLeadingCoefficientFormula_mathematicallyOpen` explains
the corresponding refined leaf. -/
def bsdLeadingCoefficientFormula_closeabilityCoverage :
    CloseabilityCoverage :=
  { closeabilityName := "BSD leading coefficient formula"
    status := .mathematicallyOpen
    covers := [BSDLeafId.bsdLeadingCoefficientFormula] }

/-- `bsdRankOrderCompatibility_mathematicallyOpen` explains the
corresponding refined leaf. -/
def bsdRankOrderCompatibility_closeabilityCoverage :
    CloseabilityCoverage :=
  { closeabilityName := "BSD rank/order compatibility"
    status := .mathematicallyOpen
    covers := [BSDLeafId.bsdRankOrderCompatibility] }

/-- `selmerFinite_technicallyHard` covers no refined typed leaf
directly: finite-level Selmer finiteness is thematically
relevant but is not one of the twelve refined open leaves.  This
empty `covers` list is the type-level reason the closeability
registry, like the closure-audit registry, is not a partition of
the twelve refined leaves on its own. -/
def selmerFinite_closeabilityCoverage : CloseabilityCoverage :=
  { closeabilityName := "finite-level Selmer finiteness"
    status := .technicallyHard
    covers := [] }

/-- `mordellWeilToSelmerInjection_technicallyHeavy` explains the
`shaSelmerInjection` refined leaf. -/
def mordellWeilInjection_closeabilityCoverage :
    CloseabilityCoverage :=
  { closeabilityName := "Mordell-Weil to Selmer injection"
    status := .technicallyHeavy
    covers := [BSDLeafId.shaSelmerInjection] }

/-- `selmerShaExactness_blockedByModeling` explains the two
remaining Sha sub-leaves (`shaSelmerSurjection` and
`shaSelmerExactness`), which together require the maps in
`SelmerShaExactPackage` to be modeled before exactness can be
assessed. -/
def selmerShaExactness_closeabilityCoverage :
    CloseabilityCoverage :=
  { closeabilityName := "Selmer-Sha exactness"
    status := .blockedByModeling
    covers :=
      [ BSDLeafId.shaSelmerSurjection,
        BSDLeafId.shaSelmerExactness ] }

/-- The BSD typed closeability-coverage registry, parallel to
`bsd_closeabilityAudit` at the string level. -/
def bsd_closeabilityCoverage : List CloseabilityCoverage :=
  [ shaGlobalFiniteness_closeabilityCoverage,
    higherEulerSystems_closeabilityCoverage,
    bsdLeadingCoefficientFormula_closeabilityCoverage,
    bsdRankOrderCompatibility_closeabilityCoverage,
    selmerFinite_closeabilityCoverage,
    mordellWeilInjection_closeabilityCoverage,
    selmerShaExactness_closeabilityCoverage ]

/-- Flatten a closeability-coverage list into the union of
covered typed leaves (with multiplicity preserved). -/
def closeabilityCoverageCoveredLeaves
    (entries : List CloseabilityCoverage) : List BSDLeafId :=
  entries.flatMap (fun e => e.covers)

/-- The typed leaves explained by `bsd_closeabilityCoverage`,
recorded as a literal list for `rfl`-friendly count theorems. -/
def bsd_closeabilityCoveredLeaves : List BSDLeafId :=
  [ BSDLeafId.shaFiniteSocket,
    BSDLeafId.higherEulerNormCompatibility,
    BSDLeafId.higherKolyvaginLocalRelations,
    BSDLeafId.higherKolyvaginDerivativeLaw,
    BSDLeafId.higherRankRegulatorCompatibility,
    BSDLeafId.higherRankSelmerControl,
    BSDLeafId.higherRankAnalyticRankCompatibility,
    BSDLeafId.bsdLeadingCoefficientFormula,
    BSDLeafId.bsdRankOrderCompatibility,
    BSDLeafId.shaSelmerInjection,
    BSDLeafId.shaSelmerSurjection,
    BSDLeafId.shaSelmerExactness ]

/-- The literal `bsd_closeabilityCoveredLeaves` agrees with the
flattened form of `bsd_closeabilityCoverage`. -/
theorem bsd_closeabilityCoveredLeaves_eq_flatten :
    bsd_closeabilityCoveredLeaves =
      closeabilityCoverageCoveredLeaves bsd_closeabilityCoverage :=
  rfl

/-- The closeability coverage explains exactly `12` typed leaves. -/
theorem bsd_closeabilityCoveredLeaves_count :
    bsd_closeabilityCoveredLeaves.length = 12 := rfl

/-- `bsd_closeabilityCoveredLeaves` contains no duplicates. -/
theorem bsd_closeabilityCoveredLeaves_nodup :
    bsd_closeabilityCoveredLeaves.Nodup := by decide

/-- Every typed leaf explained by the closeability registry is a
typed open leaf. -/
theorem bsd_closeabilityCoverage_subset_open :
    ∀ id : BSDLeafId,
      id ∈ bsd_closeabilityCoveredLeaves →
      id ∈ bsd_openLeafIds := by
  intro id; cases id <;> decide

/-- Every typed open leaf is explained by the closeability
registry: the closeability coverage is exhaustive over
`bsd_openLeafIds`. -/
theorem bsd_closeabilityCoverage_covers_openLeafIds :
    ∀ id : BSDLeafId,
      id ∈ bsd_openLeafIds ↔ id ∈ bsd_closeabilityCoveredLeaves := by
  intro id; cases id <;> decide

/-! ### Per-status typed-leaf lists

Each closeability status is associated with the union of the
typed leaves explained by entries carrying that status.  Recorded
as literal lists with `rfl`-friendly count theorems. -/

/-- Typed leaves explained by `mathematicallyOpen` entries
(Sha finite + 6 higher-rank + leading coeff + rank/order). -/
def bsd_closeabilityMathematicallyOpenLeafIds : List BSDLeafId :=
  [ BSDLeafId.shaFiniteSocket,
    BSDLeafId.higherEulerNormCompatibility,
    BSDLeafId.higherKolyvaginLocalRelations,
    BSDLeafId.higherKolyvaginDerivativeLaw,
    BSDLeafId.higherRankRegulatorCompatibility,
    BSDLeafId.higherRankSelmerControl,
    BSDLeafId.higherRankAnalyticRankCompatibility,
    BSDLeafId.bsdLeadingCoefficientFormula,
    BSDLeafId.bsdRankOrderCompatibility ]

/-- Typed leaves explained by `technicallyHard` entries.  Empty
because `selmerFinite_closeabilityCoverage.covers = []`. -/
def bsd_closeabilityTechnicallyHardLeafIds : List BSDLeafId := []

/-- Typed leaves explained by `technicallyHeavy` entries. -/
def bsd_closeabilityTechnicallyHeavyLeafIds : List BSDLeafId :=
  [BSDLeafId.shaSelmerInjection]

/-- Typed leaves explained by `blockedByModeling` entries. -/
def bsd_closeabilityBlockedByModelingLeafIds : List BSDLeafId :=
  [ BSDLeafId.shaSelmerSurjection,
    BSDLeafId.shaSelmerExactness ]

/-- Typed leaves explained by `closeableNow` entries.  Empty by
the hygiene invariant `bsd_closeabilityAudit_hygieneClean`. -/
def bsd_closeabilityCloseableNowLeafIds : List BSDLeafId := []

/-- Per-status counts: `(9, 0, 1, 2, 0)`.  Sum = `12`, matching
`bsd_closeabilityCoveredLeaves_count`. -/
theorem bsd_closeabilityMathematicallyOpenLeafIds_count :
    bsd_closeabilityMathematicallyOpenLeafIds.length = 9 := rfl

theorem bsd_closeabilityTechnicallyHardLeafIds_count :
    bsd_closeabilityTechnicallyHardLeafIds.length = 0 := rfl

theorem bsd_closeabilityTechnicallyHeavyLeafIds_count :
    bsd_closeabilityTechnicallyHeavyLeafIds.length = 1 := rfl

theorem bsd_closeabilityBlockedByModelingLeafIds_count :
    bsd_closeabilityBlockedByModelingLeafIds.length = 2 := rfl

theorem bsd_closeabilityCloseableNowLeafIds_count :
    bsd_closeabilityCloseableNowLeafIds.length = 0 := rfl

/-- Per-status counts sum to the total covered-leaf count. -/
theorem bsd_closeabilityPerStatusCounts_sum :
    bsd_closeabilityMathematicallyOpenLeafIds.length +
      bsd_closeabilityTechnicallyHardLeafIds.length +
      bsd_closeabilityTechnicallyHeavyLeafIds.length +
      bsd_closeabilityBlockedByModelingLeafIds.length +
      bsd_closeabilityCloseableNowLeafIds.length =
        bsd_closeabilityCoveredLeaves.length := rfl

/-! ### Leaf-indexed lookup of closeability status

A `BSDLeafId → Option CloseabilityStatus` function inverts the
typed closeability coverage relation: given a typed leaf, it
returns the closeability status that explains why the leaf is
not currently closed.

The lookup is **total over open leaves**: every typed open leaf
returns a `some` value, reflecting the closeability coverage
exhaustiveness recorded by
`bsd_closeabilityCoverage_covers_openLeafIds`.  The four typed
closed leaves return `none`, since closeability is a
why-not-closed concept that does not apply to leaves already
classified as closed. -/

/-- Closeability status of a typed leaf, when one applies.
Returns `some` for every typed open leaf and `none` for every
typed closed leaf. -/
def BSDLeafId.closeabilityStatus :
    BSDLeafId → Option CloseabilityStatus
  | .shaFiniteSocket => some .mathematicallyOpen
  | .shaSelmerInjection => some .technicallyHeavy
  | .shaSelmerSurjection => some .blockedByModeling
  | .shaSelmerExactness => some .blockedByModeling
  | .bsdLeadingCoefficientFormula => some .mathematicallyOpen
  | .bsdRankOrderCompatibility => some .mathematicallyOpen
  | .higherEulerNormCompatibility => some .mathematicallyOpen
  | .higherKolyvaginLocalRelations => some .mathematicallyOpen
  | .higherKolyvaginDerivativeLaw => some .mathematicallyOpen
  | .higherRankRegulatorCompatibility => some .mathematicallyOpen
  | .higherRankSelmerControl => some .mathematicallyOpen
  | .higherRankAnalyticRankCompatibility =>
      some .mathematicallyOpen
  | .torsion => none
  | .tamagawa => none
  | .regulator => none
  | .period => none

/-! ### Lookup witness theorems for individual leaves -/

/-- `shaFiniteSocket` is mathematically open. -/
theorem closeabilityStatus_shaFinite :
    BSDLeafId.closeabilityStatus .shaFiniteSocket =
      some .mathematicallyOpen := rfl

/-- `shaSelmerInjection` is technically heavy. -/
theorem closeabilityStatus_selmerInjection :
    BSDLeafId.closeabilityStatus .shaSelmerInjection =
      some .technicallyHeavy := rfl

/-- `shaSelmerExactness` is blocked by modeling. -/
theorem closeabilityStatus_selmerExactness :
    BSDLeafId.closeabilityStatus .shaSelmerExactness =
      some .blockedByModeling := rfl

/-- `torsion` is a closed leaf; closeability status does not
apply, so returns `none`. -/
theorem closeabilityStatus_torsion_closedLeaf_none :
    BSDLeafId.closeabilityStatus .torsion = none := rfl

/-! ### Exhaustiveness theorems

Together these record the closeability lookup's total/partial
structure: every typed open leaf has a closeability status,
every typed closed leaf has none. -/

/-- Every typed open leaf has a closeability status. -/
theorem closeabilityStatus_some_of_openLeaf :
    ∀ id : BSDLeafId,
      id ∈ bsd_openLeafIds →
      ∃ s : CloseabilityStatus, id.closeabilityStatus = some s := by
  intro id hid
  cases id <;> first
    | exact ⟨_, rfl⟩
    | exact absurd hid (by decide)

/-- Every typed closed leaf has no closeability status. -/
theorem closeabilityStatus_none_of_closedLeaf :
    ∀ id : BSDLeafId,
      id ∈ bsd_closedLeafIds →
      id.closeabilityStatus = none := by
  intro id hid
  cases id <;> first
    | rfl
    | exact absurd hid (by decide)

end BSDBridgeC
