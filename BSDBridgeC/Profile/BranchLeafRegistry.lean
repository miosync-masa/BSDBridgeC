import BSDBridgeC.Profile.LeafLocalization
import BSDBridgeC.Profile.Generality

/-!
# Branch-leaf registry

This file lifts the typed leaf-identifier discipline used for the
BSD branch (`BSDLeafId` of `Profile/LeafLocalization.lean`) to all
four currently documented Bridge C branches:

- C-HP (Hermite--Pochhammer),
- C-zeta (Mathlib zeta scaffold),
- C-BSD (this package's main branch),
- C-freezing (local algebraic / response branch).

For each branch, a typed inductive enumerates the leaves of the
fully refined methodology profile, a status function tags each
constructor as `closed` or `«open»` (in the leaf-localization
sense, *not* the closeability sense), and a forgetful
`toBranchLeaf` constructor lifts the identifier into a generic
`BranchLeaf` record.

The HP and zeta branches are recorded **reference-only**: this
file does **not** import `GaussianWhoWhere`.  The typed leaves
for those branches are scaffolding labels, not links to the
external `GaussianWhoWhere` Lean development.  See the
discipline note in `docs/BranchLeafRegistry.md` for why
cross-package import is deliberately avoided.

No new mathematical claim is introduced.  The Jensen socket,
Euler product, Bridge A', analytic continuation, zero location,
Riemann Hypothesis, and BSD itself remain undischarged.
-/

noncomputable section

namespace BSDBridgeC

/-! ## Method branches -/

/-- Four currently documented Bridge C methodology branches. -/
inductive BridgeCMethodBranch where
  /-- Hermite--Pochhammer rigidity branch. -/
  | hermitePochhammer
  /-- Zeta architecture scaffold branch. -/
  | zeta
  /-- BSD constraint-node branch (this package). -/
  | bsd
  /-- First-order freezing / response branch. -/
  | freezing
deriving DecidableEq, Repr

/-! ## Generic branch leaf -/

/-- A typed branch leaf: a `BridgeCMethodBranch` plus a
human-readable name, a `LeafStatus`, and a description string. -/
structure BranchLeaf where
  branch : BridgeCMethodBranch
  name : String
  status : LeafStatus
  description : String

/-- A branch leaf is open if its status is `«open»`. -/
def BranchLeaf.IsOpen (L : BranchLeaf) : Prop :=
  L.status = .«open»

/-- A branch leaf is closed if its status is `closed`. -/
def BranchLeaf.IsClosed (L : BranchLeaf) : Prop :=
  L.status = .closed

/-! ## C-HP typed leaves

Reference-only.  The substantive Lean content for these leaves
lives in the `GaussianWhoWhere` package and is **not** imported
here. -/

/-- Typed identifier for the C-HP branch leaves. -/
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
deriving DecidableEq, Repr

/-- Status of an HP leaf.  Only `jensenCartwrightLinearZeroBound`
is open (the named analytic socket); all others are closed in
the corresponding `GaussianWhoWhere` development. -/
def HPLeafId.status : HPLeafId → LeafStatus
  | .jensenCartwrightLinearZeroBound => .«open»
  | _ => .closed

/-- Human-readable label for an HP leaf. -/
def HPLeafId.label : HPLeafId → String
  | .finitePolynomialRigidity => "finite polynomial rigidity"
  | .finiteGeneralUniqueness => "finite general uniqueness"
  | .finiteHermitePochhammerReflection =>
      "finite Hermite-Pochhammer reflection"
  | .finiteP2nRecurrence => "finite P2n recurrence"
  | .finiteExponentialTypeClosure =>
      "finite exponential type closure"
  | .logSampleDensity => "log sample density"
  | .kroneckerDensity => "Kronecker density"
  | .realAxisToGlobal => "real-axis to global continuation"
  | .logDerivReconstruction => "log-derivative reconstruction"
  | .functionWhereLift => "function-level Where lift"
  | .jensenCartwrightLinearZeroBound =>
      "JensenCartwrightLinearZeroBound"

/-- Forgetful conversion HP leaf -> generic `BranchLeaf`. -/
def HPLeafId.toBranchLeaf (id : HPLeafId) : BranchLeaf :=
  { branch := .hermitePochhammer
    name := id.label
    status := id.status
    description :=
      "C-HP leaf (reference-only label; substantive Lean content lives in GaussianWhoWhere)" }

/-- HP closed leaves (10). -/
def hp_closedLeafIds : List HPLeafId :=
  [ .finitePolynomialRigidity,
    .finiteGeneralUniqueness,
    .finiteHermitePochhammerReflection,
    .finiteP2nRecurrence,
    .finiteExponentialTypeClosure,
    .logSampleDensity,
    .kroneckerDensity,
    .realAxisToGlobal,
    .logDerivReconstruction,
    .functionWhereLift ]

/-- HP open leaves (1: the Jensen socket). -/
def hp_openLeafIds : List HPLeafId :=
  [ .jensenCartwrightLinearZeroBound ]

/-- All HP leaves (closed first, then open). -/
def hp_allLeafIds : List HPLeafId :=
  hp_closedLeafIds ++ hp_openLeafIds

theorem hp_closedLeafIds_count :
    hp_closedLeafIds.length = 10 := rfl

theorem hp_openLeafIds_count :
    hp_openLeafIds.length = 1 := rfl

theorem hp_allLeafIds_count :
    hp_allLeafIds.length = 11 := rfl

/-! ## C-zeta typed leaves

Reference-only.  "closed" here means concrete (Mathlib-backed or
concrete-predicate-shape); after V's promotion of the Euler-product
and log-derivative leaves, "open" means *explicit non-claim* at the
scaffold level (analytic continuation, zero-location / RH) — **not**
mathematically open at the frontier. -/

/-- Typed identifier for the C-zeta branch leaves. -/
inductive ZetaLeafId where
  | dirichletBridgeConcrete
  | completedWherePredicate
  | eulerProductInterface
  | logDerivativeInterface
  | analyticContinuationNotClaimed
  | zeroLocationNotClaimed
deriving DecidableEq, Repr

/-- Status of a zeta leaf in the scaffold sense.  See the
file-level docstring: after V's promotion, `«open»` here means
*explicit non-claim* (analytic continuation, zero-location / RH),
not frontier-open mathematics.

Post-promotion: `eulerProductInterface` and
`logDerivativeInterface` are marked `closed` because
`GaussianWhoWhere` now provides concrete Mathlib-backed
witnesses (`riemannZeta_eulerProductBridge`,
`riemannZeta_logDerivativeBridge`).  `BSDBridgeC` does not
import `GaussianWhoWhere`; this status update is a
classification-only change justified by the external repo
state and recorded in `docs/BranchLeafRegistry.md`. -/
def ZetaLeafId.status : ZetaLeafId → LeafStatus
  | .dirichletBridgeConcrete => .closed
  | .completedWherePredicate => .closed
  | .eulerProductInterface => .closed
  | .logDerivativeInterface => .closed
  | .analyticContinuationNotClaimed => .«open»
  | .zeroLocationNotClaimed => .«open»

/-- Human-readable label for a zeta leaf. -/
def ZetaLeafId.label : ZetaLeafId → String
  | .dirichletBridgeConcrete =>
      "Dirichlet bridge concrete (Mathlib-backed)"
  | .completedWherePredicate =>
      "Completed Where predicate"
  | .eulerProductInterface =>
      "Euler-product bridge concrete (Mathlib-backed in GaussianWhoWhere)"
  | .logDerivativeInterface =>
      "Bridge A' log-derivative concrete (Mathlib-backed in GaussianWhoWhere)"
  | .analyticContinuationNotClaimed =>
      "analytic continuation (non-claim)"
  | .zeroLocationNotClaimed =>
      "zero-location / RH (non-claim)"

/-- Forgetful conversion zeta leaf -> generic `BranchLeaf`. -/
def ZetaLeafId.toBranchLeaf (id : ZetaLeafId) : BranchLeaf :=
  { branch := .zeta
    name := id.label
    status := id.status
    description :=
      "C-zeta leaf; post-promotion, 'open' means explicit non-claim, not frontier-open" }

/-- Zeta closed leaves (4 after V's promotion: Dirichlet,
completed-Where, Euler product, log-derivative). -/
def zeta_closedLeafIds : List ZetaLeafId :=
  [ .dirichletBridgeConcrete,
    .completedWherePredicate,
    .eulerProductInterface,
    .logDerivativeInterface ]

/-- Zeta open (non-claim) leaves (2 after V's promotion:
analytic continuation and zero-location remain explicit
non-claims). -/
def zeta_openLeafIds : List ZetaLeafId :=
  [ .analyticContinuationNotClaimed,
    .zeroLocationNotClaimed ]

/-- All zeta leaves. -/
def zeta_allLeafIds : List ZetaLeafId :=
  zeta_closedLeafIds ++ zeta_openLeafIds

theorem zeta_closedLeafIds_count :
    zeta_closedLeafIds.length = 4 := rfl

theorem zeta_openLeafIds_count :
    zeta_openLeafIds.length = 2 := rfl

theorem zeta_allLeafIds_count :
    zeta_allLeafIds.length = 6 := rfl

/-! ## C-freezing typed leaves

All currently closed: the freezing branch consists of small
algebraic theorems and their `BSDWhereData` / profile wrappers,
all internalized in this package or in `GaussianWhoWhere`. -/

/-- Typed identifier for the C-freezing branch leaves. -/
inductive FreezingLeafId where
  /-- Pure-imaginary first-order response algebra
  (zeta / HP side). -/
  | pureImagResponseAlgebra
  /-- The first-order freezing theorem shared by HP and zeta. -/
  | hpZetaFirstOrderFreezing
  /-- BSD parity freezing wrapper. -/
  | bsdParityFreezing
deriving DecidableEq, Repr

/-- Status of a freezing leaf: all closed. -/
def FreezingLeafId.status : FreezingLeafId → LeafStatus
  | _ => .closed

/-- Human-readable label for a freezing leaf. -/
def FreezingLeafId.label : FreezingLeafId → String
  | .pureImagResponseAlgebra =>
      "pure-imaginary response algebra"
  | .hpZetaFirstOrderFreezing =>
      "first-order freezing (HP / zeta)"
  | .bsdParityFreezing => "BSD parity freezing"

/-- Forgetful conversion freezing leaf -> generic `BranchLeaf`. -/
def FreezingLeafId.toBranchLeaf
    (id : FreezingLeafId) : BranchLeaf :=
  { branch := .freezing
    name := id.label
    status := id.status
    description :=
      "C-freezing leaf: algebraic / wrapper theorem at first-order level" }

/-- Freezing closed leaves (3). -/
def freezing_closedLeafIds : List FreezingLeafId :=
  [ .pureImagResponseAlgebra,
    .hpZetaFirstOrderFreezing,
    .bsdParityFreezing ]

/-- Freezing open leaves: none. -/
def freezing_openLeafIds : List FreezingLeafId := []

/-- All freezing leaves. -/
def freezing_allLeafIds : List FreezingLeafId :=
  freezing_closedLeafIds ++ freezing_openLeafIds

theorem freezing_closedLeafIds_count :
    freezing_closedLeafIds.length = 3 := rfl

theorem freezing_openLeafIds_count :
    freezing_openLeafIds.length = 0 := rfl

theorem freezing_allLeafIds_count :
    freezing_allLeafIds.length = 3 := rfl

/-! ## BSD branch: forgetful into `BranchLeaf`

`BSDLeafId` is already typed by `Profile/LeafLocalization.lean`.
Here we add only the forgetful conversion into the generic
`BranchLeaf`. -/

/-- Forgetful conversion BSD leaf -> generic `BranchLeaf`.
Description is forwarded from the existing `RefinementLeaf`
value via `BSDLeafId.toRefinementLeaf`. -/
def BSDLeafId.toBranchLeaf (id : BSDLeafId) : BranchLeaf :=
  { branch := .bsd
    name := id.label
    status := id.status
    description := id.toRefinementLeaf.description }

/-! ## Combined `BridgeCAnyLeafId` -/

/-- Sum type collecting all four branch-leaf identifier
inductives. -/
inductive BridgeCAnyLeafId where
  | hp : HPLeafId → BridgeCAnyLeafId
  | zeta : ZetaLeafId → BridgeCAnyLeafId
  | bsd : BSDLeafId → BridgeCAnyLeafId
  | freezing : FreezingLeafId → BridgeCAnyLeafId
deriving Repr

/-- Branch of any branch-leaf identifier. -/
def BridgeCAnyLeafId.branch :
    BridgeCAnyLeafId → BridgeCMethodBranch
  | .hp _ => .hermitePochhammer
  | .zeta _ => .zeta
  | .bsd _ => .bsd
  | .freezing _ => .freezing

/-- Status of any branch-leaf identifier (per its branch's
own `status` function). -/
def BridgeCAnyLeafId.status :
    BridgeCAnyLeafId → LeafStatus
  | .hp id => id.status
  | .zeta id => id.status
  | .bsd id => id.status
  | .freezing id => id.status

/-- `BranchLeaf` projection of any branch-leaf identifier. -/
def BridgeCAnyLeafId.toBranchLeaf :
    BridgeCAnyLeafId → BranchLeaf
  | .hp id => id.toBranchLeaf
  | .zeta id => id.toBranchLeaf
  | .bsd id => id.toBranchLeaf
  | .freezing id => id.toBranchLeaf

/-- All HP leaves lifted into `BridgeCAnyLeafId`. -/
def bridgeC_allHPLeafIds : List BridgeCAnyLeafId :=
  hp_allLeafIds.map BridgeCAnyLeafId.hp

/-- All zeta leaves lifted into `BridgeCAnyLeafId`. -/
def bridgeC_allZetaLeafIds : List BridgeCAnyLeafId :=
  zeta_allLeafIds.map BridgeCAnyLeafId.zeta

/-- All BSD leaves lifted into `BridgeCAnyLeafId`. -/
def bridgeC_allBSDLeafIds : List BridgeCAnyLeafId :=
  bsd_fullyRefinedLeafIds.map BridgeCAnyLeafId.bsd

/-- All freezing leaves lifted into `BridgeCAnyLeafId`. -/
def bridgeC_allFreezingLeafIds : List BridgeCAnyLeafId :=
  freezing_allLeafIds.map BridgeCAnyLeafId.freezing

/-- Concatenated registry of all branch-leaf identifiers. -/
def bridgeC_allLeafIds : List BridgeCAnyLeafId :=
  bridgeC_allHPLeafIds ++ bridgeC_allZetaLeafIds ++
    bridgeC_allBSDLeafIds ++ bridgeC_allFreezingLeafIds

/-- Total count: `11 + 6 + 16 + 3 = 36`. -/
theorem bridgeC_allLeafIds_count :
    bridgeC_allLeafIds.length = 36 := rfl

/-! ## Branch-leaf profile

A small per-branch summary record used by docs and registry
lookups.  Fields are descriptive strings + cached counts. -/

/-- A summary record of a Bridge C branch's leaf-localization
state. -/
structure BridgeCBranchLeafProfile where
  branch : BridgeCMethodBranch
  closedCount : ℕ
  openCount : ℕ
  summary : String

/-- C-HP branch-leaf profile. -/
def hp_branchLeafProfile : BridgeCBranchLeafProfile :=
  { branch := .hermitePochhammer
    closedCount := hp_closedLeafIds.length
    openCount := hp_openLeafIds.length
    summary :=
      "C-HP: all internalized except JensenCartwrightLinearZeroBound" }

/-- C-zeta branch-leaf profile.  Note: `«open»` here means
non-claim at the scaffold level, not frontier-open. -/
def zeta_branchLeafProfile : BridgeCBranchLeafProfile :=
  { branch := .zeta
    closedCount := zeta_closedLeafIds.length
    openCount := zeta_openLeafIds.length
    summary :=
      "C-zeta: Dirichlet / Euler / log-deriv concrete; continuation + RH non-claims" }

/-- C-BSD branch-leaf profile.  Uses the
`bsd_fullyRefinedLeafIds` partition counts. -/
def bsd_branchLeafProfile : BridgeCBranchLeafProfile :=
  { branch := .bsd
    closedCount := bsd_closedLeafIds.length
    openCount := bsd_openLeafIds.length
    summary :=
      "C-BSD: 4 closed leaves; 12 typed open leaves audited along four orthogonal axes" }

/-- C-freezing branch-leaf profile. -/
def freezing_branchLeafProfile : BridgeCBranchLeafProfile :=
  { branch := .freezing
    closedCount := freezing_closedLeafIds.length
    openCount := freezing_openLeafIds.length
    summary :=
      "C-freezing: all three first-order / response leaves closed" }

/-- Registry of all four branch-leaf profiles. -/
def bridgeC_branchLeafProfiles :
    List BridgeCBranchLeafProfile :=
  [ hp_branchLeafProfile,
    zeta_branchLeafProfile,
    bsd_branchLeafProfile,
    freezing_branchLeafProfile ]

/-! ### Profile / list-length consistency theorems -/

theorem hp_branchLeafProfile_openCount :
    hp_branchLeafProfile.openCount = hp_openLeafIds.length := rfl

theorem hp_branchLeafProfile_closedCount :
    hp_branchLeafProfile.closedCount = hp_closedLeafIds.length :=
  rfl

theorem zeta_branchLeafProfile_openCount :
    zeta_branchLeafProfile.openCount = zeta_openLeafIds.length :=
  rfl

theorem zeta_branchLeafProfile_closedCount :
    zeta_branchLeafProfile.closedCount =
      zeta_closedLeafIds.length := rfl

theorem bsd_branchLeafProfile_openCount :
    bsd_branchLeafProfile.openCount = bsd_openLeafIds.length :=
  rfl

theorem bsd_branchLeafProfile_closedCount :
    bsd_branchLeafProfile.closedCount =
      bsd_closedLeafIds.length := rfl

theorem freezing_branchLeafProfile_openCount :
    freezing_branchLeafProfile.openCount =
      freezing_openLeafIds.length := rfl

theorem freezing_branchLeafProfile_closedCount :
    freezing_branchLeafProfile.closedCount =
      freezing_closedLeafIds.length := rfl

end BSDBridgeC
