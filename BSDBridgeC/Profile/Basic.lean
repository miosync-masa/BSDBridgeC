import BSDBridgeC.Specialization.RankOne
import BSDBridgeC.Freezing.Parity

/-!
# BSD Bridge C profile

This profile packages the BSD Bridge C architecture without claiming
to inhabit the hard higher-rank sockets.
-/

noncomputable section

namespace BSDBridgeC

/-- Full BSD Bridge C profile for one elliptic-curve-like object. -/
structure BSDBridgeCProfile where
  E : EllipticCurveLike
  who : BSDWhoData
  where_ : BSDWhereData
  bridgeC : BridgeC_Rigidity E who where_
  higherRankSocket : ∀ r : ℕ, 2 ≤ r → HigherRankSocket E r → HigherRankSocket E r

/-- Project the central Bridge C rigidity package. -/
def bsdBridgeCProfile_has_bridgeC
    (P : BSDBridgeCProfile) :
    BridgeC_Rigidity P.E P.who P.where_ :=
  P.bridgeC

/-- Project Who/Where compatibility from a BSD profile. -/
def bsdBridgeCProfile_has_whoWhere
    (P : BSDBridgeCProfile) :
    BSDWhoWhereCompatible P.who P.where_ :=
  P.bridgeC.whoWhere

/-- Project the Bridge A encode layer (modularity / Dirichlet / Euler
product model) from a BSD profile.  This is a structural genealogy
projection; no new analytic content. -/
def bsdBridgeCProfile_has_encode
    (P : BSDBridgeCProfile) :
    BridgeA_Encode P.E P.where_ :=
  P.bridgeC.encode

/-- Project the Bridge B decode layer (Iwasawa-main socket plus the
Taylor-to-arithmetic and normalization fields) from a BSD profile. -/
def bsdBridgeCProfile_has_decode
    (P : BSDBridgeCProfile) :
    BridgeB_Decode P.E P.who P.where_ :=
  P.bridgeC.decode

/-- Project the Bridge A′ logarithmic-derivative companion from a BSD
profile.  Mirrors Bridge A′ of the GaussianWhoWhere zeta scaffold. -/
def bsdBridgeCProfile_has_logDeriv
    (P : BSDBridgeCProfile) :
    BridgeAprime_LogDeriv P.where_ :=
  P.bridgeC.logDeriv

/-- The higher-rank socket is *not* discharged by the profile.  It is
consumed as a hypothesis and returned unchanged.  This projection
exposes that fact at the theorem level: BSD Bridge C does **not**
prove inhabitation of `HigherRankSocket E r` for `r ≥ 2`. -/
theorem bsdBridgeCProfile_has_higherRankSocket_as_hypothesis
    (P : BSDBridgeCProfile) {r : ℕ} (hr : 2 ≤ r)
    (h : HigherRankSocket P.E r) :
    HigherRankSocket P.E r :=
  P.higherRankSocket r hr h

/-- Rank-one specialization at the profile level: a concrete
`RankOneHeegnerWitness E` discharges the rank-one
`HigherRankSocket E 1`.  This is a profile-namespace alias for
`higherRankSocket_rankOne_of_heegnerWitness`. -/
theorem rankOneProfileSocket_of_heegnerWitness
    {E : EllipticCurveLike}
    (W : RankOneHeegnerWitness E) :
    HigherRankSocket E 1 :=
  higherRankSocket_rankOne_of_heegnerWitness W

/-! ## Constraint-triangle witnesses

The three forgetful bundles of `WhoWhere/Basic.lean` are exposed at
the profile level.  Together they witness the constraint-satisfaction
reading of BSD recorded in `docs/BSDSerializationEngine.md`: Who-data,
Where-data, and their compatibility, each as a separately addressable
typed package.  No new mathematical content is introduced; each
definition is a forgetful forwarding of an existing field. -/

/-- Project the heterogeneous Who bundle from a BSD profile. -/
def bsdBridgeCProfile_whoBundle
    (P : BSDBridgeCProfile) :
    BSDWhoHeterogeneousBundle P.who :=
  bsdWhoData_to_heterogeneousBundle P.who

/-- Project the central Where bundle from a BSD profile. -/
def bsdBridgeCProfile_whereBundle
    (P : BSDBridgeCProfile) :
    BSDWhereCentralBundle P.where_ :=
  bsdWhereData_to_centralBundle P.where_

/-- Project the compatibility-socket bundle from a BSD profile.  This
forwards the Who/Where compatibility witness carried by the Bridge C
field. -/
def bsdBridgeCProfile_compatibilityBundle
    (P : BSDBridgeCProfile) :
    BSDCompatibilitySocketBundle P.who P.where_ :=
  bsdWhoWhereCompatible_to_socketBundle P.bridgeC.whoWhere

/-- The constraint triangle witnessed by a BSD profile: Who bundle,
Where bundle, and the compatibility socket bundle, packaged as a
single `Type`-side record indexed by the profile.  This is the Lean
counterpart of the triangle described in
`docs/BSDSerializationEngine.md` §3. -/
structure BSDConstraintTriangle (P : BSDBridgeCProfile) where
  whoBundle : BSDWhoHeterogeneousBundle P.who
  whereBundle : BSDWhereCentralBundle P.where_
  compatibilityBundle : BSDCompatibilitySocketBundle P.who P.where_

/-- Every BSD profile produces its constraint triangle by forwarding
each of the three forgetful bundles.  No new data, no new
assertions. -/
def bsdBridgeCProfile_constraintTriangle
    (P : BSDBridgeCProfile) : BSDConstraintTriangle P :=
  { whoBundle := bsdBridgeCProfile_whoBundle P
    whereBundle := bsdBridgeCProfile_whereBundle P
    compatibilityBundle := bsdBridgeCProfile_compatibilityBundle P }

end BSDBridgeC
