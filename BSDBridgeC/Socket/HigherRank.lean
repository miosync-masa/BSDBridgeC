import BSDBridgeC.Bridges.Basic

/-!
# Higher-rank arithmetic sockets

This is the v2 heart: the open BSD / higher-rank machinery is not an
opaque `Prop`.  It is decomposed into data-bearing structures whose
fields name Euler systems, Kolyvagin systems, derivative laws,
regulator compatibility, and Selmer control.

For rank `r ≥ 2`, inhabitation of `HigherRankSocket` is intentionally
left open.  No theorem in this file proves it.
-/

noncomputable section

namespace BSDBridgeC

/-- Higher Euler system socket. -/
structure HigherEulerSystem (T : GaloisRep) (r : ℕ) where
  classes : ∀ K : Type, WedgePower r (H1 K T)
  norm_compatibility : Prop

/-- Higher Kolyvagin system socket. -/
structure HigherKolyvaginSystem (T : GaloisRep) (r : ℕ) where
  classes : ∀ n : ℕ, WedgePower r (SelmerQuotient n T)
  local_relations : Prop

/-- Bridge D: Euler-system classes differentiate to Kolyvagin-system
classes. -/
structure HigherKolyvaginDerivative
    {T : GaloisRep} {r : ℕ}
    (ES : HigherEulerSystem T r) (KS : HigherKolyvaginSystem T r) where
  derivative_law : Prop

/-- Fully typed higher-rank arithmetic bridge. -/
structure HigherRankArithmeticBridge (E : EllipticCurveLike) (r : ℕ) where
  ES : HigherEulerSystem (TateModule E) r
  KS : HigherKolyvaginSystem (TateModule E) r
  D : HigherKolyvaginDerivative ES KS
  regulator_compatibility : Prop
  selmer_control : Prop
  core_rank_matches_bsd_rank : Prop

/-- The visible higher-rank socket.  For `r ≥ 2`, this is consumed as
a hypothesis and is not proved in this scaffold. -/
def HigherRankSocket (E : EllipticCurveLike) (r : ℕ) : Prop :=
  Nonempty (HigherRankArithmeticBridge E r)

/-- Socket genealogy: a higher-rank bridge exposes an Euler system. -/
def higherRankBridge_has_eulerSystem
    {E : EllipticCurveLike} {r : ℕ}
    (B : HigherRankArithmeticBridge E r) :
    HigherEulerSystem (TateModule E) r :=
  B.ES

/-- Socket genealogy: a higher-rank bridge exposes a Kolyvagin system. -/
def higherRankBridge_has_kolyvaginSystem
    {E : EllipticCurveLike} {r : ℕ}
    (B : HigherRankArithmeticBridge E r) :
    HigherKolyvaginSystem (TateModule E) r :=
  B.KS

/-- Socket genealogy: a higher-rank bridge exposes the derivative law. -/
def higherRankBridge_has_derivative
    {E : EllipticCurveLike} {r : ℕ}
    (B : HigherRankArithmeticBridge E r) :
    HigherKolyvaginDerivative B.ES B.KS :=
  B.D

/-! ## HigherEulerSystem internal projections

The classes are an indexed family of wedge powers; the norm
compatibility is a `Prop`-valued socket.  Neither is discharged. -/

/-- Project the indexed family of higher Euler-system wedge classes. -/
def higherEulerSystem_classes
    {T : GaloisRep} {r : ℕ}
    (ES : HigherEulerSystem T r) :
    ∀ K : Type, WedgePower r (H1 K T) :=
  ES.classes

/-- Project the norm-compatibility socket of a higher Euler system. -/
def higherEulerSystem_normCompatibility
    {T : GaloisRep} {r : ℕ}
    (ES : HigherEulerSystem T r) : Prop :=
  ES.norm_compatibility

/-! ## HigherKolyvaginSystem internal projections -/

/-- Project the indexed family of higher Kolyvagin-system wedge
classes. -/
def higherKolyvaginSystem_classes
    {T : GaloisRep} {r : ℕ}
    (KS : HigherKolyvaginSystem T r) :
    ∀ n : ℕ, WedgePower r (SelmerQuotient n T) :=
  KS.classes

/-- Project the local-relations socket of a higher Kolyvagin system. -/
def higherKolyvaginSystem_localRelations
    {T : GaloisRep} {r : ℕ}
    (KS : HigherKolyvaginSystem T r) : Prop :=
  KS.local_relations

/-! ## HigherKolyvaginDerivative internal projection -/

/-- Project the derivative-law socket from a Bridge D witness. -/
def higherKolyvaginDerivative_law
    {T : GaloisRep} {r : ℕ}
    {ES : HigherEulerSystem T r}
    {KS : HigherKolyvaginSystem T r}
    (D : HigherKolyvaginDerivative ES KS) : Prop :=
  D.derivative_law

/-! ## HigherRankArithmeticBridge remaining socket projections

The Euler / Kolyvagin / derivative projections are above.  The three
remaining socket fields — regulator compatibility, Selmer control,
and core/BSD rank matching — are exposed here as separately
addressable `Prop`-valued sockets. -/

/-- Project the regulator-compatibility socket from a higher-rank
arithmetic bridge. -/
def higherRankBridge_has_regulatorCompatibility
    {E : EllipticCurveLike} {r : ℕ}
    (B : HigherRankArithmeticBridge E r) : Prop :=
  B.regulator_compatibility

/-- Project the Selmer-control socket from a higher-rank arithmetic
bridge. -/
def higherRankBridge_has_selmerControl
    {E : EllipticCurveLike} {r : ℕ}
    (B : HigherRankArithmeticBridge E r) : Prop :=
  B.selmer_control

/-- Project the core/BSD rank-matching socket from a higher-rank
arithmetic bridge. -/
def higherRankBridge_has_coreRankMatchesBSDRank
    {E : EllipticCurveLike} {r : ℕ}
    (B : HigherRankArithmeticBridge E r) : Prop :=
  B.core_rank_matches_bsd_rank

/-! ## Higher-rank socket genealogy bundle

A `Type`-side packaging structure that names all six socket
components of `HigherRankArithmeticBridge` at once: the three
data-bearing fields (`ES`, `KS`, `D`) plus the three `Prop`-valued
sockets.  No new content; the bundle is a forgetful repackaging. -/

/-- Type-side bundle of every component named by a higher-rank
arithmetic bridge.  Inhabitation of this bundle for `r ≥ 2` requires
the same data that inhabits `HigherRankArithmeticBridge`; this
scaffold does not provide it. -/
structure HigherRankSocketBundle
    (E : EllipticCurveLike) (r : ℕ) where
  ES : HigherEulerSystem (TateModule E) r
  KS : HigherKolyvaginSystem (TateModule E) r
  D : HigherKolyvaginDerivative ES KS
  regulatorCompatibility_socket : Prop
  selmerControl_socket : Prop
  coreRankMatchesBSDRank_socket : Prop

/-- Forgetful constructor: every higher-rank arithmetic bridge
produces its socket bundle by forwarding each field. -/
def higherRankBridge_to_socketBundle
    {E : EllipticCurveLike} {r : ℕ}
    (B : HigherRankArithmeticBridge E r) :
    HigherRankSocketBundle E r :=
  { ES := B.ES
    KS := B.KS
    D := B.D
    regulatorCompatibility_socket := B.regulator_compatibility
    selmerControl_socket := B.selmer_control
    coreRankMatchesBSDRank_socket := B.core_rank_matches_bsd_rank }

/-! ## V3 decomposed socket structures

The V2 `HigherRankArithmeticBridge` already exposes a socket
genealogy, but its three compatibility fields are bare `Prop`s.  V3
refines them into named `structure`s, so that the *kind* of each
socket is itself addressable at the type level.

V3 is added non-destructively: the V2 definitions above are
preserved, and a forgetful map plus a migration theorem record how
V3 specializes to V2.  Future renaming (e.g. `HigherRankSocket :=
HigherRankSocketV3`) can be done once V3 stabilizes. -/

/-- Regulator compatibility socket, named instead of a bare `Prop`.
The `compatibility_law` field is the underlying assertion; the
structure itself records that the assertion is parameterized by the
Euler system to which it refers. -/
structure RegulatorCompatibility
    (E : EllipticCurveLike) (r : ℕ)
    (_ES : HigherEulerSystem (TateModule E) r) where
  compatibility_law : Prop

/-- Selmer control socket, named instead of a bare `Prop`.  The
underlying assertion is the `control_law` field, parameterized by
the Kolyvagin system whose Selmer behavior it constrains. -/
structure SelmerControl
    (E : EllipticCurveLike) (r : ℕ)
    (_KS : HigherKolyvaginSystem (TateModule E) r) where
  control_law : Prop

/-- Core-rank / BSD-rank matching socket, named explicitly.

The three rank flavors (`CoreRank`, `AlgebraicRank`, `AnalyticRank`)
are deliberately distinct `ℕ` abbreviations in `Basic.lean`.  This
socket records (i) a definite equality between the core rank and the
algebraic rank, and (ii) a named `Prop`-valued socket for the
analytic-vs-algebraic identification.  The latter is the
BSD-conjecture rank equality and is **not** discharged. -/
structure CoreRankBSDRankCompatibility
    (_E : EllipticCurveLike) (_r : ℕ) where
  core_rank : CoreRank
  algebraic_rank : AlgebraicRank
  analytic_rank : AnalyticRank
  core_matches_algebraic : core_rank = algebraic_rank
  analytic_matches_algebraic : Prop

/-- V3 type-side higher-rank socket structure.

This is the decomposed object whose inhabitation is open for
`r ≥ 2`.  It refines the V2 `HigherRankArithmeticBridge` shape by
replacing bare `Prop` fields with named socket structures
(`RegulatorCompatibility`, `SelmerControl`,
`CoreRankBSDRankCompatibility`). -/
structure HigherRankSocketStructure
    (E : EllipticCurveLike) (r : ℕ) where
  ES : HigherEulerSystem (TateModule E) r
  KS : HigherKolyvaginSystem (TateModule E) r
  D : HigherKolyvaginDerivative ES KS
  regulatorCompat : RegulatorCompatibility E r ES
  selmerControl : SelmerControl E r KS
  rankCompat : CoreRankBSDRankCompatibility E r

/-- V3 visible open socket: inhabitation of the decomposed
structure.  For `r ≥ 2` this is consumed as a hypothesis only,
exactly as the V2 socket was. -/
def HigherRankSocketV3 (E : EllipticCurveLike) (r : ℕ) : Prop :=
  Nonempty (HigherRankSocketStructure E r)

/-! ### V3 -> V2 forgetful migration

A V3 socket structure forgets its named sub-sockets back into the
V2 bare-`Prop` shape.  This map is purely forgetful and discharges
no assertion. -/

/-- Forget the named V3 sub-socket structures into the V2
`HigherRankArithmeticBridge` shape. -/
def higherRankSocketStructure_to_arithmeticBridge
    {E : EllipticCurveLike} {r : ℕ}
    (S : HigherRankSocketStructure E r) :
    HigherRankArithmeticBridge E r :=
  { ES := S.ES
    KS := S.KS
    D := S.D
    regulator_compatibility := S.regulatorCompat.compatibility_law
    selmer_control := S.selmerControl.control_law
    core_rank_matches_bsd_rank :=
      S.rankCompat.analytic_matches_algebraic }

/-- Migration: the V3 visible socket implies the V2 visible
socket.  No mathematical claim is added; this is purely the
forgetful direction. -/
theorem higherRankSocket_of_v3
    {E : EllipticCurveLike} {r : ℕ}
    (h : HigherRankSocketV3 E r) :
    HigherRankSocket E r := by
  rcases h with ⟨S⟩
  exact ⟨higherRankSocketStructure_to_arithmeticBridge S⟩

/-! ### V3 socket-structure projections -/

/-- Project the higher Euler system from a V3 socket structure. -/
def higherRankSocketStructure_has_eulerSystem
    {E : EllipticCurveLike} {r : ℕ}
    (S : HigherRankSocketStructure E r) :
    HigherEulerSystem (TateModule E) r :=
  S.ES

/-- Project the higher Kolyvagin system from a V3 socket structure. -/
def higherRankSocketStructure_has_kolyvaginSystem
    {E : EllipticCurveLike} {r : ℕ}
    (S : HigherRankSocketStructure E r) :
    HigherKolyvaginSystem (TateModule E) r :=
  S.KS

/-- Project the Kolyvagin derivative from a V3 socket structure. -/
def higherRankSocketStructure_has_derivative
    {E : EllipticCurveLike} {r : ℕ}
    (S : HigherRankSocketStructure E r) :
    HigherKolyvaginDerivative S.ES S.KS :=
  S.D

/-- Project the regulator-compatibility named sub-socket from a V3
socket structure. -/
def higherRankSocketStructure_has_regulatorCompatibility
    {E : EllipticCurveLike} {r : ℕ}
    (S : HigherRankSocketStructure E r) :
    RegulatorCompatibility E r S.ES :=
  S.regulatorCompat

/-- Project the Selmer-control named sub-socket from a V3 socket
structure. -/
def higherRankSocketStructure_has_selmerControl
    {E : EllipticCurveLike} {r : ℕ}
    (S : HigherRankSocketStructure E r) :
    SelmerControl E r S.KS :=
  S.selmerControl

/-- Project the rank-compatibility named sub-socket from a V3 socket
structure. -/
def higherRankSocketStructure_has_rankCompatibility
    {E : EllipticCurveLike} {r : ℕ}
    (S : HigherRankSocketStructure E r) :
    CoreRankBSDRankCompatibility E r :=
  S.rankCompat

end BSDBridgeC
