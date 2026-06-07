import BSDBridgeC.Profile.Generality
import BSDBridgeC.Specialization.RankOne

/-!
# Leaf localization

Structure refinement of a Bridge C profile turns a mathematical
problem into a typed dependency DAG.  When refinement is iterated to
its bottom, each path terminates at a *leaf*.  A leaf is classified
as either

- **closed**: at the present scaffold level, it is intended to
  connect to Mathlib, concrete data, or a finite computation, and is
  therefore not the residual open core; or

- **open**: it does not connect anywhere, and represents a genuine
  unsolved mathematical socket of the BSD branch.

This file records that classification.  It is **not** a BSD proof,
**not** a discharge of any open leaf, and **not** an assertion that
the closed leaves are formally proved in Mathlib at the time of
writing.  The classification is the scaffold's own
self-documentation: at this layer, which leaves carry the residual
open content, and which do not.

The methodological slogan is recorded in
`docs/LeafLocalization.md`:

> The contribution is not to remove the open leaves, but to prove
> that the remaining openness has been localized to named leaves of
> the typed dependency DAG.
-/

noncomputable section

namespace BSDBridgeC

/-- The status of a leaf in the refinement DAG. -/
inductive LeafStatus where
  /-- The leaf connects to Mathlib, concrete data, or a finite
  computation; it is not the residual open core. -/
  | closed
  /-- The leaf has no such connection; it is a genuine open
  socket. -/
  | «open»
deriving DecidableEq, Repr

/-- A lightweight named leaf in a refinement DAG. -/
structure RefinementLeaf where
  name : String
  status : LeafStatus
  description : String

/-- A leaf is closed if its status is `LeafStatus.closed`. -/
def RefinementLeaf.IsClosed (L : RefinementLeaf) : Prop :=
  L.status = .closed

/-- A leaf is open if its status is `LeafStatus.open`. -/
def RefinementLeaf.IsOpen (L : RefinementLeaf) : Prop :=
  L.status = .«open»

/-- A leaf-localization profile is a list of named leaves attached
to a Bridge C branch. -/
structure LeafLocalizationProfile where
  branch : BridgeCBranch
  leaves : List RefinementLeaf

/-! ## Closed leaves of the BSD branch

These leaves are classified as closed at the present scaffold
level.  "Closed" here means **not a residual BSD-conjecture
socket**, not "fully formalized in Mathlib today". -/

/-- Torsion data is treated as a closed leaf at this scaffold
level. -/
def torsion_closed_leaf : RefinementLeaf :=
  { name := "torsion"
    status := .closed
    description :=
      "finite torsion data; intended to connect to concrete algebraic computation" }

/-- Tamagawa data is treated as a closed leaf at this scaffold
level. -/
def tamagawa_closed_leaf : RefinementLeaf :=
  { name := "tamagawa"
    status := .closed
    description :=
      "local Tamagawa factors; intended to connect to local computation" }

/-- Regulator data is treated as a closed leaf at this scaffold
level. -/
def regulator_closed_leaf : RefinementLeaf :=
  { name := "regulator"
    status := .closed
    description :=
      "height/regulator data; analytic normalization may be refined later" }

/-- Period data is treated as a closed leaf at this scaffold
level. -/
def period_closed_leaf : RefinementLeaf :=
  { name := "period"
    status := .closed
    description :=
      "period data; normalization choices are explicit but not an open BSD socket" }

/-! ## Open leaves of the BSD branch -/

/-- Sha finiteness is an open leaf: it remains a genuine BSD-side
socket and is not discharged by this scaffold. -/
def sha_finiteness_open_leaf : RefinementLeaf :=
  { name := "Sha finiteness"
    status := .«open»
    description :=
      "the finiteness / exact arithmetic content of Sha remains a genuine BSD socket" }

/-- Higher Euler systems in rank ≥ 2 are an open leaf: their
existence is the rank-≥-2 socket of `HigherRankSocket`. -/
def higher_euler_system_open_leaf : RefinementLeaf :=
  { name := "higher Euler systems r >= 2"
    status := .«open»
    description :=
      "inhabitation of higher-rank Euler/Kolyvagin system sockets remains open" }

/-! ## BSD-branch leaf profile -/

/-- BSD branch leaf-localization profile. -/
def bsd_leafLocalizationProfile : LeafLocalizationProfile :=
  { branch := .bsd
    leaves :=
      [ torsion_closed_leaf,
        tamagawa_closed_leaf,
        regulator_closed_leaf,
        period_closed_leaf,
        sha_finiteness_open_leaf,
        higher_euler_system_open_leaf ] }

/-! ## Closure / openness facts about the named leaves -/

/-- `sha_finiteness_open_leaf` is open. -/
theorem sha_finiteness_leaf_is_open :
    sha_finiteness_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, sha_finiteness_open_leaf]

/-- `higher_euler_system_open_leaf` is open. -/
theorem higher_euler_system_leaf_is_open :
    higher_euler_system_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, higher_euler_system_open_leaf]

/-- `torsion_closed_leaf` is closed at this scaffold level. -/
theorem torsion_leaf_is_closed :
    torsion_closed_leaf.IsClosed := by
  simp [RefinementLeaf.IsClosed, torsion_closed_leaf]

/-! ## Refined Sha sub-leaves (post V3 Sha decomposition)

After the V3 Sha decomposition recorded in `WhoWhere/Basic.lean`
(see `ShaDataV3` and `SelmerShaExactPackage`), the single coarse
leaf `sha_finiteness_open_leaf` decomposes into four named open
sub-leaves.  The coarse leaf is preserved above for backward
compatibility; the refined leaves below populate the refined
profile `bsd_refinedShaLeafLocalizationProfile`. -/

/-- Refined open leaf: Sha finite socket after V3 Sha
decomposition.  Corresponds to the `finiteSocket : Prop` field of
`ShaDataV3`. -/
def sha_finiteSocket_open_leaf : RefinementLeaf :=
  { name := "Sha finiteSocket"
    status := .«open»
    description :=
      "the finiteSocket field of ShaDataV3; Sha finiteness remains open" }

/-- Refined open leaf: injection in the Selmer/Sha exact package.
Corresponds to the `injection_socket : Prop` field of
`SelmerShaExactPackage`. -/
def sha_selmer_injection_open_leaf : RefinementLeaf :=
  { name := "Selmer-Sha injection socket"
    status := .«open»
    description :=
      "the injection_socket field in SelmerShaExactPackage" }

/-- Refined open leaf: surjection in the Selmer/Sha exact package.
Corresponds to the `surjection_socket : Prop` field of
`SelmerShaExactPackage`. -/
def sha_selmer_surjection_open_leaf : RefinementLeaf :=
  { name := "Selmer-Sha surjection socket"
    status := .«open»
    description :=
      "the surjection_socket field in SelmerShaExactPackage" }

/-- Refined open leaf: exactness in the Selmer/Sha exact package.
Corresponds to the `exactness_socket : Prop` field of
`SelmerShaExactPackage`. -/
def sha_selmer_exactness_open_leaf : RefinementLeaf :=
  { name := "Selmer-Sha exactness socket"
    status := .«open»
    description :=
      "the exactness_socket field in SelmerShaExactPackage" }

/-- Refined BSD-branch profile in which the coarse Sha leaf is
replaced by the four named Sha sub-leaves.  The coarse
`bsd_leafLocalizationProfile` above is preserved unchanged. -/
def bsd_refinedShaLeafLocalizationProfile : LeafLocalizationProfile :=
  { branch := .bsd
    leaves :=
      [ torsion_closed_leaf,
        tamagawa_closed_leaf,
        regulator_closed_leaf,
        period_closed_leaf,
        sha_finiteSocket_open_leaf,
        sha_selmer_injection_open_leaf,
        sha_selmer_surjection_open_leaf,
        sha_selmer_exactness_open_leaf,
        higher_euler_system_open_leaf ] }

/-- `sha_finiteSocket_open_leaf` is open. -/
theorem sha_finiteSocket_leaf_is_open :
    sha_finiteSocket_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, sha_finiteSocket_open_leaf]

/-- `sha_selmer_injection_open_leaf` is open. -/
theorem sha_selmer_injection_leaf_is_open :
    sha_selmer_injection_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, sha_selmer_injection_open_leaf]

/-- `sha_selmer_surjection_open_leaf` is open. -/
theorem sha_selmer_surjection_leaf_is_open :
    sha_selmer_surjection_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, sha_selmer_surjection_open_leaf]

/-- `sha_selmer_exactness_open_leaf` is open. -/
theorem sha_selmer_exactness_leaf_is_open :
    sha_selmer_exactness_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, sha_selmer_exactness_open_leaf]

/-! ## Compatibility-node open leaves

The Bridge C compatibility node `BSDWhoWhereCompatible` exposes two
bare `Prop`-valued socket fields:

- `leadingCoefficientFormula : Prop`
- `rankOrderCompatibility : Prop`

Neither is discharged anywhere in the package; both are genuine
open content of the BSD formula.  This subsection records each as
a named open leaf, parallel to the Sha and higher-rank leaves
above.  No new mathematical claim is introduced. -/

/-- Open leaf: BSD leading-coefficient formula socket.
Corresponds to the `leadingCoefficientFormula : Prop` field of
`BSDWhoWhereCompatible`. -/
def bsd_leadingCoefficientFormula_open_leaf : RefinementLeaf :=
  { name := "BSD leading coefficient formula"
    status := .«open»
    description :=
      "the leadingCoefficientFormula field of BSDWhoWhereCompatible" }

/-- Open leaf: BSD rank/order compatibility socket.  Corresponds to
the `rankOrderCompatibility : Prop` field of
`BSDWhoWhereCompatible`. -/
def bsd_rankOrderCompatibility_open_leaf : RefinementLeaf :=
  { name := "BSD rank/order compatibility"
    status := .«open»
    description :=
      "the rankOrderCompatibility field of BSDWhoWhereCompatible" }

/-- Compatibility-refined BSD-branch profile.  Extends
`bsd_refinedShaLeafLocalizationProfile` by adding the two
compatibility-node leaves.  The two earlier profiles are preserved
unchanged. -/
def bsd_refinedShaAndCompatibilityLeafLocalizationProfile :
    LeafLocalizationProfile :=
  { branch := .bsd
    leaves :=
      [ torsion_closed_leaf,
        tamagawa_closed_leaf,
        regulator_closed_leaf,
        period_closed_leaf,
        sha_finiteSocket_open_leaf,
        sha_selmer_injection_open_leaf,
        sha_selmer_surjection_open_leaf,
        sha_selmer_exactness_open_leaf,
        bsd_leadingCoefficientFormula_open_leaf,
        bsd_rankOrderCompatibility_open_leaf,
        higher_euler_system_open_leaf ] }

/-- `bsd_leadingCoefficientFormula_open_leaf` is open. -/
theorem bsd_leadingCoefficientFormula_leaf_is_open :
    bsd_leadingCoefficientFormula_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, bsd_leadingCoefficientFormula_open_leaf]

/-- `bsd_rankOrderCompatibility_open_leaf` is open. -/
theorem bsd_rankOrderCompatibility_leaf_is_open :
    bsd_rankOrderCompatibility_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, bsd_rankOrderCompatibility_open_leaf]

/-! ## Higher-rank sub-leaves (post V3 higher-rank decomposition)

The V3 higher-rank refinement of `Socket/HigherRank.lean`
(`HigherRankSocketStructure`, `RegulatorCompatibility`,
`SelmerControl`, `CoreRankBSDRankCompatibility`) decomposes the
coarse `higher_euler_system_open_leaf` into six named open
sub-leaves: three from the data carriers (`HigherEulerSystem`,
`HigherKolyvaginSystem`, `HigherKolyvaginDerivative`) and three
from the V3 sub-socket structures.

The coarse leaf and the earlier profiles are preserved unchanged. -/

/-- Refined open leaf: higher Euler-system norm compatibility.
Corresponds to the `norm_compatibility : Prop` field of
`HigherEulerSystem`. -/
def higherEuler_normCompatibility_open_leaf : RefinementLeaf :=
  { name := "higher Euler norm compatibility"
    status := .«open»
    description :=
      "the norm_compatibility field of HigherEulerSystem" }

/-- Refined open leaf: higher Kolyvagin local relations.
Corresponds to the `local_relations : Prop` field of
`HigherKolyvaginSystem`. -/
def higherKolyvagin_localRelations_open_leaf : RefinementLeaf :=
  { name := "higher Kolyvagin local relations"
    status := .«open»
    description :=
      "the local_relations field of HigherKolyvaginSystem" }

/-- Refined open leaf: higher Kolyvagin derivative law.
Corresponds to the `derivative_law : Prop` field of
`HigherKolyvaginDerivative`. -/
def higherKolyvagin_derivativeLaw_open_leaf : RefinementLeaf :=
  { name := "higher Kolyvagin derivative law"
    status := .«open»
    description :=
      "the derivative_law field of HigherKolyvaginDerivative" }

/-- Refined open leaf: higher-rank regulator compatibility.
Corresponds to the `compatibility_law : Prop` field of
`RegulatorCompatibility`. -/
def higherRank_regulatorCompatibility_open_leaf : RefinementLeaf :=
  { name := "higher-rank regulator compatibility"
    status := .«open»
    description :=
      "the compatibility_law field of RegulatorCompatibility" }

/-- Refined open leaf: higher-rank Selmer control.  Corresponds to
the `control_law : Prop` field of `SelmerControl`. -/
def higherRank_selmerControl_open_leaf : RefinementLeaf :=
  { name := "higher-rank Selmer control"
    status := .«open»
    description :=
      "the control_law field of SelmerControl" }

/-- Refined open leaf: higher-rank analytic/algebraic rank
compatibility.  Corresponds to the `analytic_matches_algebraic :
Prop` field of `CoreRankBSDRankCompatibility`.  This is the BSD
rank-equality socket; it is **not** discharged. -/
def higherRank_analyticRankCompatibility_open_leaf : RefinementLeaf :=
  { name := "higher-rank analytic/algebraic rank compatibility"
    status := .«open»
    description :=
      "the analytic_matches_algebraic field of CoreRankBSDRankCompatibility" }

/-- Fully refined BSD-branch profile.  Replaces the single coarse
higher-rank open leaf by the six named higher-rank sub-leaves above,
keeping the four Sha sub-leaves and the two compatibility-node
leaves in place.  All earlier profiles are preserved unchanged. -/
def bsd_fullyRefinedLeafLocalizationProfile :
    LeafLocalizationProfile :=
  { branch := .bsd
    leaves :=
      [ torsion_closed_leaf,
        tamagawa_closed_leaf,
        regulator_closed_leaf,
        period_closed_leaf,
        sha_finiteSocket_open_leaf,
        sha_selmer_injection_open_leaf,
        sha_selmer_surjection_open_leaf,
        sha_selmer_exactness_open_leaf,
        bsd_leadingCoefficientFormula_open_leaf,
        bsd_rankOrderCompatibility_open_leaf,
        higherEuler_normCompatibility_open_leaf,
        higherKolyvagin_localRelations_open_leaf,
        higherKolyvagin_derivativeLaw_open_leaf,
        higherRank_regulatorCompatibility_open_leaf,
        higherRank_selmerControl_open_leaf,
        higherRank_analyticRankCompatibility_open_leaf ] }

/-- `higherEuler_normCompatibility_open_leaf` is open. -/
theorem higherEuler_normCompatibility_leaf_is_open :
    higherEuler_normCompatibility_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, higherEuler_normCompatibility_open_leaf]

/-- `higherKolyvagin_localRelations_open_leaf` is open. -/
theorem higherKolyvagin_localRelations_leaf_is_open :
    higherKolyvagin_localRelations_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, higherKolyvagin_localRelations_open_leaf]

/-- `higherKolyvagin_derivativeLaw_open_leaf` is open. -/
theorem higherKolyvagin_derivativeLaw_leaf_is_open :
    higherKolyvagin_derivativeLaw_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, higherKolyvagin_derivativeLaw_open_leaf]

/-- `higherRank_regulatorCompatibility_open_leaf` is open. -/
theorem higherRank_regulatorCompatibility_leaf_is_open :
    higherRank_regulatorCompatibility_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, higherRank_regulatorCompatibility_open_leaf]

/-- `higherRank_selmerControl_open_leaf` is open. -/
theorem higherRank_selmerControl_leaf_is_open :
    higherRank_selmerControl_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, higherRank_selmerControl_open_leaf]

/-- `higherRank_analyticRankCompatibility_open_leaf` is open. -/
theorem higherRank_analyticRankCompatibility_leaf_is_open :
    higherRank_analyticRankCompatibility_open_leaf.IsOpen := by
  simp [RefinementLeaf.IsOpen, higherRank_analyticRankCompatibility_open_leaf]

/-! ## Boolean discriminators on `LeafStatus`

Lightweight `Bool`-valued versions of the `IsOpen` / `IsClosed`
`Prop` predicates above.  These are needed to make
`List.filter` work over a `RefinementLeaf` list, which in turn
lets us count open and closed leaves of a profile. -/

/-- `Bool` discriminator: true iff the status is open. -/
def LeafStatus.isOpen : LeafStatus → Bool
  | .«open» => true
  | .closed => false

/-- `Bool` discriminator: true iff the status is closed. -/
def LeafStatus.isClosed : LeafStatus → Bool
  | .closed => true
  | .«open» => false

/-! ## Counting open and closed leaves of a profile

These counts measure the granularity of the current typed
decomposition, not mathematical difficulty.  Refining one coarse
open leaf into named sub-leaves *increases* the open count without
changing the closed count and without discharging any leaf. -/

/-- Count open leaves in a localization profile. -/
def LeafLocalizationProfile.openCount
    (P : LeafLocalizationProfile) : ℕ :=
  (P.leaves.filter (fun L => L.status.isOpen)).length

/-- Count closed leaves in a localization profile. -/
def LeafLocalizationProfile.closedCount
    (P : LeafLocalizationProfile) : ℕ :=
  (P.leaves.filter (fun L => L.status.isClosed)).length

/-! ### Concrete open-leaf counts -/

/-- The coarse BSD profile carries `2` open leaves. -/
theorem bsd_leafLocalizationProfile_openCount :
    bsd_leafLocalizationProfile.openCount = 2 := by
  decide

/-- After the V3 Sha decomposition, the BSD profile carries `5`
open leaves. -/
theorem bsd_refinedShaLeafLocalizationProfile_openCount :
    bsd_refinedShaLeafLocalizationProfile.openCount = 5 := by
  decide

/-- Adding the two compatibility-node leaves brings the open count
to `7`. -/
theorem bsd_refinedShaAndCompatibilityLeafLocalizationProfile_openCount :
    bsd_refinedShaAndCompatibilityLeafLocalizationProfile.openCount = 7 := by
  decide

/-- The fully refined BSD profile carries `12` open leaves. -/
theorem bsd_fullyRefinedLeafLocalizationProfile_openCount :
    bsd_fullyRefinedLeafLocalizationProfile.openCount = 12 := by
  decide

/-! ### Concrete closed-leaf counts

The closed-leaf count is invariant across the refinement chain: it
remains `4` (`torsion`, `tamagawa`, `regulator`, `period`) at every
profile. -/

/-- Coarse BSD profile has `4` closed leaves. -/
theorem bsd_leafLocalizationProfile_closedCount :
    bsd_leafLocalizationProfile.closedCount = 4 := by
  decide

/-- Sha-refined BSD profile has `4` closed leaves. -/
theorem bsd_refinedShaLeafLocalizationProfile_closedCount :
    bsd_refinedShaLeafLocalizationProfile.closedCount = 4 := by
  decide

/-- Sha+compatibility-refined BSD profile has `4` closed leaves. -/
theorem bsd_refinedShaAndCompatibilityLeafLocalizationProfile_closedCount :
    bsd_refinedShaAndCompatibilityLeafLocalizationProfile.closedCount = 4 := by
  decide

/-- Fully refined BSD profile has `4` closed leaves. -/
theorem bsd_fullyRefinedLeafLocalizationProfile_closedCount :
    bsd_fullyRefinedLeafLocalizationProfile.closedCount = 4 := by
  decide

/-! ### The open-count refinement chain

Concrete monotone chain `2 ≤ 5 ≤ 7 ≤ 12` of the four BSD
profiles' open counts.  This is not a general monotonicity theorem;
it is the witness that the four currently registered profiles
satisfy the inequality concretely. -/

theorem bsd_leafLocalization_openCount_chain :
    bsd_leafLocalizationProfile.openCount
      ≤ bsd_refinedShaLeafLocalizationProfile.openCount ∧
    bsd_refinedShaLeafLocalizationProfile.openCount
      ≤ bsd_refinedShaAndCompatibilityLeafLocalizationProfile.openCount ∧
    bsd_refinedShaAndCompatibilityLeafLocalizationProfile.openCount
      ≤ bsd_fullyRefinedLeafLocalizationProfile.openCount := by
  decide

/-! ## Typed leaf identifiers

The `RefinementLeaf`-based registry above identifies leaves by
their `name : String` field.  That is enough for documentation,
but Lean cannot compare two `RefinementLeaf` records for
identity-of-leaf without unfolding the string.

V4 adds a typed identifier `BSDLeafId` enumerating the leaves of
the fully refined BSD-branch profile.  This is **non-destructive**:
the string-based registry above is preserved.  The typed registry
is a layered overlay that makes leaf identity, leaf status, and
leaf partitions Lean-decidable. -/

/-- Typed identifier for each leaf of the fully refined BSD-branch
profile (`bsd_fullyRefinedLeafLocalizationProfile`).

The constructor names mirror the string-based leaf names of the
existing registry.  Constructors are listed closed-first then
open, matching the partition order used below. -/
inductive BSDLeafId where
  -- Closed leaves (4)
  | torsion
  | tamagawa
  | regulator
  | period
  -- Sha sub-leaves (4 open)
  | shaFiniteSocket
  | shaSelmerInjection
  | shaSelmerSurjection
  | shaSelmerExactness
  -- Compatibility-node leaves (2 open)
  | bsdLeadingCoefficientFormula
  | bsdRankOrderCompatibility
  -- Higher-rank sub-leaves (6 open)
  | higherEulerNormCompatibility
  | higherKolyvaginLocalRelations
  | higherKolyvaginDerivativeLaw
  | higherRankRegulatorCompatibility
  | higherRankSelmerControl
  | higherRankAnalyticRankCompatibility
deriving DecidableEq, Repr

/-- Closed / `«open»` status of each typed leaf identifier. -/
def BSDLeafId.status : BSDLeafId → LeafStatus
  | .torsion => .closed
  | .tamagawa => .closed
  | .regulator => .closed
  | .period => .closed
  | .shaFiniteSocket => .«open»
  | .shaSelmerInjection => .«open»
  | .shaSelmerSurjection => .«open»
  | .shaSelmerExactness => .«open»
  | .bsdLeadingCoefficientFormula => .«open»
  | .bsdRankOrderCompatibility => .«open»
  | .higherEulerNormCompatibility => .«open»
  | .higherKolyvaginLocalRelations => .«open»
  | .higherKolyvaginDerivativeLaw => .«open»
  | .higherRankRegulatorCompatibility => .«open»
  | .higherRankSelmerControl => .«open»
  | .higherRankAnalyticRankCompatibility => .«open»

/-- Human-readable label for a typed leaf identifier.  Strings here
match the `name` fields of the corresponding `RefinementLeaf`
values declared earlier in this file. -/
def BSDLeafId.label : BSDLeafId → String
  | .torsion => "torsion"
  | .tamagawa => "tamagawa"
  | .regulator => "regulator"
  | .period => "period"
  | .shaFiniteSocket => "Sha finiteSocket"
  | .shaSelmerInjection => "Selmer-Sha injection socket"
  | .shaSelmerSurjection => "Selmer-Sha surjection socket"
  | .shaSelmerExactness => "Selmer-Sha exactness socket"
  | .bsdLeadingCoefficientFormula => "BSD leading coefficient formula"
  | .bsdRankOrderCompatibility => "BSD rank/order compatibility"
  | .higherEulerNormCompatibility => "higher Euler norm compatibility"
  | .higherKolyvaginLocalRelations => "higher Kolyvagin local relations"
  | .higherKolyvaginDerivativeLaw => "higher Kolyvagin derivative law"
  | .higherRankRegulatorCompatibility =>
      "higher-rank regulator compatibility"
  | .higherRankSelmerControl => "higher-rank Selmer control"
  | .higherRankAnalyticRankCompatibility =>
      "higher-rank analytic/algebraic rank compatibility"

/-- `Bool` discriminator: true iff the typed leaf is `«open»`. -/
def BSDLeafId.isOpen (id : BSDLeafId) : Bool :=
  id.status.isOpen

/-- `Bool` discriminator: true iff the typed leaf is `closed`. -/
def BSDLeafId.isClosed (id : BSDLeafId) : Bool :=
  id.status.isClosed

/-! ### Typed partitions

Three concrete `List BSDLeafId` values record the closed / open /
fully-refined partitions of the BSD branch, in the same order as
the `RefinementLeaf` lists used by
`bsd_fullyRefinedLeafLocalizationProfile`. -/

/-- Closed typed leaf identifiers (4). -/
def bsd_closedLeafIds : List BSDLeafId :=
  [ .torsion, .tamagawa, .regulator, .period ]

/-- Open typed leaf identifiers (12). -/
def bsd_openLeafIds : List BSDLeafId :=
  [ .shaFiniteSocket,
    .shaSelmerInjection,
    .shaSelmerSurjection,
    .shaSelmerExactness,
    .bsdLeadingCoefficientFormula,
    .bsdRankOrderCompatibility,
    .higherEulerNormCompatibility,
    .higherKolyvaginLocalRelations,
    .higherKolyvaginDerivativeLaw,
    .higherRankRegulatorCompatibility,
    .higherRankSelmerControl,
    .higherRankAnalyticRankCompatibility ]

/-- Fully refined typed leaf identifiers: closed first, then open. -/
def bsd_fullyRefinedLeafIds : List BSDLeafId :=
  bsd_closedLeafIds ++ bsd_openLeafIds

/-! ### Concrete count theorems

These are closed by `rfl` because the lists are literal and
`List.length` reduces definitionally. -/

/-- The closed-leaf list has `4` entries. -/
theorem bsd_closedLeafIds_count :
    bsd_closedLeafIds.length = 4 := rfl

/-- The open-leaf list has `12` entries. -/
theorem bsd_openLeafIds_count :
    bsd_openLeafIds.length = 12 := rfl

/-- The fully refined list has `16` entries. -/
theorem bsd_fullyRefinedLeafIds_count :
    bsd_fullyRefinedLeafIds.length = 16 := rfl

/-! ## Typed-to-string registry bridge

`BSDLeafId` is the typed identity; `RefinementLeaf` is the
human-readable registry cell.  V4 Task 9 connects them through a
forgetful map that takes each typed identifier to the
`RefinementLeaf` value already declared earlier in this file.

Two consistency theorems (status and label) record that the
bridge respects both the closed/`«open»` classification and the
human-readable name.  The bridge is non-destructive: every
existing `RefinementLeaf` value remains unchanged. -/

/-- Convert a typed BSD leaf identifier into its corresponding
string-based `RefinementLeaf` value. -/
def BSDLeafId.toRefinementLeaf : BSDLeafId → RefinementLeaf
  | .torsion => torsion_closed_leaf
  | .tamagawa => tamagawa_closed_leaf
  | .regulator => regulator_closed_leaf
  | .period => period_closed_leaf
  | .shaFiniteSocket => sha_finiteSocket_open_leaf
  | .shaSelmerInjection => sha_selmer_injection_open_leaf
  | .shaSelmerSurjection => sha_selmer_surjection_open_leaf
  | .shaSelmerExactness => sha_selmer_exactness_open_leaf
  | .bsdLeadingCoefficientFormula =>
      bsd_leadingCoefficientFormula_open_leaf
  | .bsdRankOrderCompatibility =>
      bsd_rankOrderCompatibility_open_leaf
  | .higherEulerNormCompatibility =>
      higherEuler_normCompatibility_open_leaf
  | .higherKolyvaginLocalRelations =>
      higherKolyvagin_localRelations_open_leaf
  | .higherKolyvaginDerivativeLaw =>
      higherKolyvagin_derivativeLaw_open_leaf
  | .higherRankRegulatorCompatibility =>
      higherRank_regulatorCompatibility_open_leaf
  | .higherRankSelmerControl =>
      higherRank_selmerControl_open_leaf
  | .higherRankAnalyticRankCompatibility =>
      higherRank_analyticRankCompatibility_open_leaf

/-! ### Consistency theorems -/

/-- The bridge respects the closed/`«open»` status: the typed
`BSDLeafId.status` agrees with the underlying
`RefinementLeaf.status`. -/
theorem BSDLeafId.toRefinementLeaf_status (id : BSDLeafId) :
    id.toRefinementLeaf.status = id.status := by
  cases id <;> rfl

/-- The bridge respects the human-readable name: the typed
`BSDLeafId.label` agrees with the underlying
`RefinementLeaf.name`. -/
theorem BSDLeafId.toRefinementLeaf_label (id : BSDLeafId) :
    id.toRefinementLeaf.name = id.label := by
  cases id <;> rfl

/-- Closed-typed-leaf bridges to a closed `RefinementLeaf`. -/
theorem BSDLeafId.toRefinementLeaf_closed_iff (id : BSDLeafId) :
    id.toRefinementLeaf.IsClosed ↔ id.status = .closed := by
  cases id <;> rfl

/-- Open-typed-leaf bridges to an `«open»` `RefinementLeaf`. -/
theorem BSDLeafId.toRefinementLeaf_open_iff (id : BSDLeafId) :
    id.toRefinementLeaf.IsOpen ↔ id.status = .«open» := by
  cases id <;> rfl

/-! ### List-level bridge

The typed `BSDLeafId` partitions can be mapped pointwise into
lists of `RefinementLeaf` values. -/

/-- All sixteen typed leaves, mapped into the string registry. -/
def bsd_fullyRefinedLeavesFromIds : List RefinementLeaf :=
  bsd_fullyRefinedLeafIds.map BSDLeafId.toRefinementLeaf

/-- The list-level bridge has `16` entries, matching
`bsd_fullyRefinedLeafIds.length`. -/
theorem bsd_fullyRefinedLeavesFromIds_count :
    bsd_fullyRefinedLeavesFromIds.length = 16 := rfl

/-- The open-leaf list mapped into the string registry has `12`
entries. -/
theorem bsd_openLeavesFromIds_count :
    (bsd_openLeafIds.map BSDLeafId.toRefinementLeaf).length = 12 :=
  rfl

/-- The closed-leaf list mapped into the string registry has `4`
entries. -/
theorem bsd_closedLeavesFromIds_count :
    (bsd_closedLeafIds.map BSDLeafId.toRefinementLeaf).length = 4 :=
  rfl

end BSDBridgeC
