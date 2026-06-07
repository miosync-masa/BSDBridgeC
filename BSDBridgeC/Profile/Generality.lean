import BSDBridgeC.Profile.Basic
import BSDBridgeC.Freezing.ProfileParity

/-!
# Bridge C generality profile

A lightweight type-level registry of the three Bridge C branches
currently documented in `docs/BridgeCGenerality.md`:

- Hermite–Pochhammer (C-HP),
- zeta (C-zeta),
- BSD (C-BSD).

This file does **not** import `GaussianWhoWhere`.  The HP and zeta
branches are referenced here purely as registry entries — strings and
branch tags — without any cross-package dependency.  The
mathematical content of those branches remains in their own
packages; this file only fixes the classification used by the
generality document.

No new mathematical claim is made.  The registry is a label table,
not a coupling theorem.
-/

noncomputable section

namespace BSDBridgeC

/-- The three currently documented Bridge C branches. -/
inductive BridgeCBranch where
  | hermitePochhammer
  | zeta
  | bsd
deriving DecidableEq, Repr

/-- A branch is internal to this package exactly when it is the BSD
branch. -/
def BridgeCBranch.isInternalBSD : BridgeCBranch → Prop
  | .bsd => True
  | _ => False

/-- A branch is external/reference-only for this package. -/
def BridgeCBranch.isExternalReference : BridgeCBranch → Prop
  | .hermitePochhammer => True
  | .zeta => True
  | .bsd => False

/-- Human-readable branch label, matching the section headings used
in `docs/BridgeCGenerality.md`. -/
def BridgeCBranch.label : BridgeCBranch → String
  | .hermitePochhammer => "C-HP"
  | .zeta => "C-zeta"
  | .bsd => "C-BSD"

/-- A lightweight registry entry describing one Bridge C branch.
The fields are descriptive strings, not mathematical objects; they
match the columns of the generality table in
`docs/BridgeCGenerality.md` §3. -/
structure BridgeCBranchProfile where
  branch : BridgeCBranch
  objectLayer : String
  whoLayer : String
  whereLayer : String
  bridgeNode : String
  closedPart : String
  explicitSocket : String

/-- Registry entry for the Hermite–Pochhammer branch, reference-only
inside `BSDBridgeC`.  The substantive Lean content lives in the
`GaussianWhoWhere` package and is not imported here. -/
def bridgeC_HP_profile : BridgeCBranchProfile :=
  { branch := .hermitePochhammer
    objectLayer := "Hermite-Pochhammer deformation factor Q"
    whoLayer := "sampled translation / multiplicativity"
    whereLayer := "reflection Q(1 - z) = Q(z)"
    bridgeNode := "log-derivative / exponential rigidity"
    closedPart := "Q ≡ 1 conditional on JensenCartwrightLinearZeroBound"
    explicitSocket := "JensenCartwrightLinearZeroBound" }

/-- Registry entry for the zeta branch, reference-only inside
`BSDBridgeC`.  The substantive Lean content lives in
`GaussianWhoWhere/ZetaBridge/Basic.lean` and is not imported here. -/
def bridgeC_zeta_profile : BridgeCBranchProfile :=
  { branch := .zeta
    objectLayer := "riemannZeta / completed zeta / log derivative"
    whoLayer := "Dirichlet and Euler identity layers"
    whereLayer := "completed functional equation"
    bridgeNode := "ZetaBridgeCProfile"
    closedPart := "Dirichlet side Mathlib-backed; other layers typed"
    explicitSocket := "Euler product and Bridge A' wrappers deferred" }

/-- Registry entry for the BSD branch, internal to this package. -/
def bridgeC_BSD_profile : BridgeCBranchProfile :=
  { branch := .bsd
    objectLayer := "elliptic-curve-like L-function profile"
    whoLayer := "torsion / Sha / Tamagawa / regulator / period"
    whereLayer := "central Taylor data at s = 1"
    bridgeNode := "BSDConstraintTriangle / BridgeC_Rigidity"
    closedPart := "rank-one socket from witness; root-number parity freezing"
    explicitSocket := "HigherRankSocket E r for r >= 2" }

/-- The current registry of documented Bridge C branches. -/
def bridgeC_generality_registry : List BridgeCBranchProfile :=
  [bridgeC_HP_profile, bridgeC_zeta_profile, bridgeC_BSD_profile]

/-- The BSD branch profile is marked as the internal branch. -/
theorem bridgeC_BSD_profile_internal :
    BridgeCBranch.isInternalBSD bridgeC_BSD_profile.branch := by
  simp [bridgeC_BSD_profile, BridgeCBranch.isInternalBSD]

/-- The HP branch is reference-only in this package. -/
theorem bridgeC_HP_profile_external :
    BridgeCBranch.isExternalReference bridgeC_HP_profile.branch := by
  simp [bridgeC_HP_profile, BridgeCBranch.isExternalReference]

/-- The zeta branch is reference-only in this package. -/
theorem bridgeC_zeta_profile_external :
    BridgeCBranch.isExternalReference bridgeC_zeta_profile.branch := by
  simp [bridgeC_zeta_profile, BridgeCBranch.isExternalReference]

end BSDBridgeC
