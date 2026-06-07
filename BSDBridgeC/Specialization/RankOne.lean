import BSDBridgeC.Socket.HigherRank

/-!
# Rank-one specialization

We do not prove Gross--Zagier or Kolyvagin.  Instead, a rank-one
Heegner/Kolyvagin witness is a data package.  Given such a witness,
the rank-one `HigherRankSocket` is inhabited by construction.
-/

noncomputable section

namespace BSDBridgeC

/-- Rank-one Heegner/Kolyvagin witness package. -/
structure RankOneHeegnerWitness (E : EllipticCurveLike) where
  ES : HigherEulerSystem (TateModule E) 1
  KS : HigherKolyvaginSystem (TateModule E) 1
  D : HigherKolyvaginDerivative ES KS
  regulator_compatibility : Prop
  selmer_control : Prop
  core_rank_matches_bsd_rank : Prop

/-- A supplied rank-one Heegner/Kolyvagin witness inhabits the
rank-one arithmetic bridge. -/
def rankOneArithmeticBridge_of_heegnerWitness
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitness E) :
    HigherRankArithmeticBridge E 1 :=
  { ES := W.ES
    KS := W.KS
    D := W.D
    regulator_compatibility := W.regulator_compatibility
    selmer_control := W.selmer_control
    core_rank_matches_bsd_rank := W.core_rank_matches_bsd_rank }

/-- Rank-one socket closure, conditional on the explicit witness. -/
theorem higherRankSocket_rankOne_of_heegnerWitness
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitness E) :
    HigherRankSocket E 1 :=
  ⟨rankOneArithmeticBridge_of_heegnerWitness W⟩

/-! ## Rank-one Heegner witness internal projections

`RankOneHeegnerWitness E` carries the same six components as a
`HigherRankArithmeticBridge E 1`, but it lives at the witness layer:
its inhabitation is the input to the rank-one closure of the higher
socket.  These projections expose each field as a `#check`-able name
without discharging any of the underlying socket statements. -/

/-- Project the higher Euler system from a rank-one Heegner witness. -/
def rankOneHeegnerWitness_has_eulerSystem
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitness E) :
    HigherEulerSystem (TateModule E) 1 :=
  W.ES

/-- Project the higher Kolyvagin system from a rank-one Heegner
witness. -/
def rankOneHeegnerWitness_has_kolyvaginSystem
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitness E) :
    HigherKolyvaginSystem (TateModule E) 1 :=
  W.KS

/-- Project the Kolyvagin derivative law from a rank-one Heegner
witness. -/
def rankOneHeegnerWitness_has_derivative
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitness E) :
    HigherKolyvaginDerivative W.ES W.KS :=
  W.D

/-- Project the regulator-compatibility socket from a rank-one Heegner
witness. -/
def rankOneHeegnerWitness_has_regulatorCompatibility
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitness E) : Prop :=
  W.regulator_compatibility

/-- Project the Selmer-control socket from a rank-one Heegner
witness. -/
def rankOneHeegnerWitness_has_selmerControl
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitness E) : Prop :=
  W.selmer_control

/-- Project the core/BSD rank-matching socket from a rank-one Heegner
witness. -/
def rankOneHeegnerWitness_has_coreRankMatchesBSDRank
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitness E) : Prop :=
  W.core_rank_matches_bsd_rank

/-! ## Rank-one witness genealogy bundle

A `Type`-side packaging structure naming all six components of a
rank-one Heegner witness at once.  Forgetful repackaging; no new
content. -/

/-- Type-side bundle of every component named by a rank-one Heegner
witness.  Its inhabitation is provided by the witness; this scaffold
does not prove the witness exists. -/
structure RankOneWitnessBundle (E : EllipticCurveLike) where
  ES : HigherEulerSystem (TateModule E) 1
  KS : HigherKolyvaginSystem (TateModule E) 1
  D : HigherKolyvaginDerivative ES KS
  regulatorCompatibility_socket : Prop
  selmerControl_socket : Prop
  coreRankMatchesBSDRank_socket : Prop

/-- Forgetful constructor: a rank-one Heegner witness produces its
witness bundle by forwarding each field. -/
def rankOneHeegnerWitness_to_bundle
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitness E) :
    RankOneWitnessBundle E :=
  { ES := W.ES
    KS := W.KS
    D := W.D
    regulatorCompatibility_socket := W.regulator_compatibility
    selmerControl_socket := W.selmer_control
    coreRankMatchesBSDRank_socket := W.core_rank_matches_bsd_rank }

/-! ## Link to the general higher-rank socket bundle

A rank-one witness routes through the rank-one arithmetic bridge into
the general `HigherRankSocketBundle E 1`.  This composition records
explicitly that rank `1` lives inside the same socket-bundle universe
as rank `r ≥ 2`; the only difference is that rank `1` has a supplied
witness, while rank `r ≥ 2` does not. -/

/-- Compose a rank-one Heegner witness with the general socket-bundle
forgetful: `W ↦ HigherRankSocketBundle E 1`. -/
def rankOneHeegnerWitness_to_higherRankSocketBundle
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitness E) :
    HigherRankSocketBundle E 1 :=
  higherRankBridge_to_socketBundle
    (rankOneArithmeticBridge_of_heegnerWitness W)

/-! ## V3 rank-one Heegner witness

The V2 `RankOneHeegnerWitness` package carries three bare `Prop`
fields (`regulator_compatibility`, `selmer_control`,
`core_rank_matches_bsd_rank`).  V3 refines them into the named
sub-socket structures introduced in
`Socket/HigherRank.lean`.

The migration is **asymmetric**: a V3 witness forgets to a V2
witness (or to the V2 arithmetic bridge), but the reverse direction
is not derivable, because reconstructing the named V3 sub-socket
structures from bare V2 `Prop`s would require additional choices
that are not present in V2.  This asymmetry is honest: it records
that V3 carries strictly more typed information. -/

/-- V3 rank-one Heegner / Kolyvagin witness with named sub-sockets,
mirroring the V3 socket structure `HigherRankSocketStructure E 1`. -/
structure RankOneHeegnerWitnessV3 (E : EllipticCurveLike) where
  ES : HigherEulerSystem (TateModule E) 1
  KS : HigherKolyvaginSystem (TateModule E) 1
  D : HigherKolyvaginDerivative ES KS
  regulatorCompat : RegulatorCompatibility E 1 ES
  selmerControl : SelmerControl E 1 KS
  rankCompat : CoreRankBSDRankCompatibility E 1

/-- Promote a V3 rank-one witness to the V3 socket structure at
rank `1`. -/
def rankOneHeegnerWitnessV3_to_higherRankSocketStructure
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitnessV3 E) :
    HigherRankSocketStructure E 1 :=
  { ES := W.ES
    KS := W.KS
    D := W.D
    regulatorCompat := W.regulatorCompat
    selmerControl := W.selmerControl
    rankCompat := W.rankCompat }

/-- A V3 rank-one witness discharges the V3 visible socket at rank
`1`.  Gross--Zagier and Kolyvagin's theorems are not proved; the
witness is consumed as data. -/
theorem higherRankSocketV3_rankOne_of_heegnerWitnessV3
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitnessV3 E) :
    HigherRankSocketV3 E 1 :=
  ⟨rankOneHeegnerWitnessV3_to_higherRankSocketStructure W⟩

/-! ### V3 -> V2 forgetful migration at the witness layer -/

/-- Forget a V3 rank-one witness into the V2 rank-one witness shape.
The bare V2 `Prop` fields are extracted from the named V3 sub-socket
structures.  No new content. -/
def rankOneHeegnerWitness_of_v3
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitnessV3 E) :
    RankOneHeegnerWitness E :=
  { ES := W.ES
    KS := W.KS
    D := W.D
    regulator_compatibility := W.regulatorCompat.compatibility_law
    selmer_control := W.selmerControl.control_law
    core_rank_matches_bsd_rank := W.rankCompat.analytic_matches_algebraic }

/-- A V3 rank-one witness produces a V2 higher-rank arithmetic
bridge at rank `1`.  Equal to forgetting through the V3 socket
structure and then taking the V2 forgetful map. -/
def rankOneHeegnerWitnessV3_to_arithmeticBridge
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitnessV3 E) :
    HigherRankArithmeticBridge E 1 :=
  higherRankSocketStructure_to_arithmeticBridge
    (rankOneHeegnerWitnessV3_to_higherRankSocketStructure W)

/-- A V3 rank-one witness discharges the V2 visible socket at rank
`1`.  Routes through V3 to V2 via `higherRankSocket_of_v3`. -/
theorem higherRankSocket_rankOne_of_heegnerWitnessV3
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitnessV3 E) :
    HigherRankSocket E 1 :=
  higherRankSocket_of_v3
    (higherRankSocketV3_rankOne_of_heegnerWitnessV3 W)

/-! ### V3 rank-one witness projections -/

/-- Project the higher Euler system from a V3 rank-one witness. -/
def rankOneHeegnerWitnessV3_has_eulerSystem
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitnessV3 E) :
    HigherEulerSystem (TateModule E) 1 :=
  W.ES

/-- Project the higher Kolyvagin system from a V3 rank-one witness. -/
def rankOneHeegnerWitnessV3_has_kolyvaginSystem
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitnessV3 E) :
    HigherKolyvaginSystem (TateModule E) 1 :=
  W.KS

/-- Project the Kolyvagin derivative from a V3 rank-one witness. -/
def rankOneHeegnerWitnessV3_has_derivative
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitnessV3 E) :
    HigherKolyvaginDerivative W.ES W.KS :=
  W.D

/-- Project the regulator-compatibility named sub-socket from a V3
rank-one witness. -/
def rankOneHeegnerWitnessV3_has_regulatorCompatibility
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitnessV3 E) :
    RegulatorCompatibility E 1 W.ES :=
  W.regulatorCompat

/-- Project the Selmer-control named sub-socket from a V3 rank-one
witness. -/
def rankOneHeegnerWitnessV3_has_selmerControl
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitnessV3 E) :
    SelmerControl E 1 W.KS :=
  W.selmerControl

/-- Project the rank-compatibility named sub-socket from a V3
rank-one witness. -/
def rankOneHeegnerWitnessV3_has_rankCompatibility
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitnessV3 E) :
    CoreRankBSDRankCompatibility E 1 :=
  W.rankCompat

/-! ### V3 rank-one witness bundle -/

/-- Type-side V3 bundle naming all six components of a rank-one
witness with the V3 sub-socket structures in place.  Forgetful
repackaging of `RankOneHeegnerWitnessV3`. -/
structure RankOneWitnessBundleV3 (E : EllipticCurveLike) where
  ES : HigherEulerSystem (TateModule E) 1
  KS : HigherKolyvaginSystem (TateModule E) 1
  D : HigherKolyvaginDerivative ES KS
  regulatorCompat : RegulatorCompatibility E 1 ES
  selmerControl : SelmerControl E 1 KS
  rankCompat : CoreRankBSDRankCompatibility E 1

/-- Forgetful constructor from V3 witness to V3 bundle. -/
def rankOneHeegnerWitnessV3_to_bundleV3
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitnessV3 E) :
    RankOneWitnessBundleV3 E :=
  { ES := W.ES
    KS := W.KS
    D := W.D
    regulatorCompat := W.regulatorCompat
    selmerControl := W.selmerControl
    rankCompat := W.rankCompat }

end BSDBridgeC
