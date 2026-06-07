import BSDBridgeC.Basic

/-!
# BSD Who / Where layer

The Who side is deliberately heterogeneous: finite discrete data,
unknown Sha data, local Tamagawa factors, real regulator data, and
period data are not forced into a single artificial type.

The Where side records the center `s = 1`, a root number, and the
central Taylor data.  Functional-equation content is a named field,
not a hidden proof.
-/

noncomputable section

namespace BSDBridgeC

/-- Torsion data on the Who side. -/
structure TorsionData where
  order : ℕ

/-- Sha data is not computed here.  The field names the socket value
that a BSD formula would consume. -/
structure ShaData where
  order : ℕ

/-- Local Tamagawa factors, indexed abstractly by natural numbers. -/
structure TamagawaData where
  factor : ℕ → ℕ

/-- Regulator data. -/
structure RegulatorData where
  value : ℝ

/-- Period data.  We keep the value complex to avoid committing to a
normalization convention at the scaffold level. -/
structure PeriodData where
  value : ℂ

/-- The heterogeneous BSD Who package. -/
structure BSDWhoData where
  torsion : TorsionData
  sha : ShaData
  tamagawa : TamagawaData
  regulator : RegulatorData
  period : PeriodData

/-- A central Taylor profile at `s = 1`. -/
structure CentralTaylorData where
  order : ℕ
  leadingCoeff : ℂ

/-- BSD Where data: an L-function-like object, a root number, and
central Taylor data. -/
structure BSDWhereData where
  L : ℂ → ℂ
  rootNumber : ℂ
  centralTaylor : CentralTaylorData
  functionalEquationAtCenter : Prop

/-- The central point for BSD-normalized L-functions. -/
def bsdCenter : ℂ := 1

/-- Compatibility of heterogeneous Who data with central Where data.
This is a named socket bundle, not a theorem.  Its fields are the
statements that a genuine BSD proof would eventually have to supply. -/
structure BSDWhoWhereCompatible (who : BSDWhoData) (where_ : BSDWhereData) where
  leadingCoefficientFormula : Prop
  rankOrderCompatibility : Prop

/-- Project the leading-coefficient formula socket. -/
def compatible_leading_formula
    {who : BSDWhoData} {where_ : BSDWhereData}
    (h : BSDWhoWhereCompatible who where_) :
    Prop :=
  h.leadingCoefficientFormula

/-! ## Heterogeneous Who projections

Each of the five Who components is exposed as a named projection.
This makes the Who-side data heterogeneity visible at the theorem
level: torsion, Sha, Tamagawa, regulator, and period are five
genuinely distinct data shapes packaged into a single bundle.

These projections do **not** assert finiteness of Sha, do **not**
identify the regulator or the period, and do **not** discharge any
BSD-formula content.  They are field accessors. -/

/-- Project torsion data from a heterogeneous Who package. -/
def bsdWhoData_has_torsion (W : BSDWhoData) : TorsionData :=
  W.torsion

/-- Project Sha data from a heterogeneous Who package.  No claim of
finiteness, computability, or BSD identification. -/
def bsdWhoData_has_sha (W : BSDWhoData) : ShaData :=
  W.sha

/-- Project Tamagawa-factor data from a heterogeneous Who package. -/
def bsdWhoData_has_tamagawa (W : BSDWhoData) : TamagawaData :=
  W.tamagawa

/-- Project regulator data from a heterogeneous Who package.  No
identification with any analytic regulator, no positivity claim. -/
def bsdWhoData_has_regulator (W : BSDWhoData) : RegulatorData :=
  W.regulator

/-- Project period data from a heterogeneous Who package.  The period
value is complex; the scaffold commits to no normalization. -/
def bsdWhoData_has_period (W : BSDWhoData) : PeriodData :=
  W.period

/-- A typed witness that the heterogeneous Who bundle is fully
present.  This is a `Type`-side `structure`, not a `Prop`, because
its fields are data values.  It carries no further assertions beyond
the typed presence of each component. -/
structure BSDWhoHeterogeneousBundle (_W : BSDWhoData) where
  torsion_present : TorsionData
  sha_present : ShaData
  tamagawa_present : TamagawaData
  regulator_present : RegulatorData
  period_present : PeriodData

/-- Every BSD Who package produces its heterogeneous bundle by
forwarding each field.  No new data is introduced. -/
def bsdWhoData_to_heterogeneousBundle
    (W : BSDWhoData) : BSDWhoHeterogeneousBundle W :=
  { torsion_present := W.torsion
    sha_present := W.sha
    tamagawa_present := W.tamagawa
    regulator_present := W.regulator
    period_present := W.period }

/-! ## Where-side central-Taylor projections

The Where side concentrates analytic information at the center
`s = 1`: an L-function-like object, a root number, the central
Taylor order and leading coefficient, and a named functional-equation
socket.  These projections expose the fields verbatim; no analytic
continuation, no critical-line claim, no BSD identification, and no
proof of the functional equation is introduced. -/

/-- Project the Taylor order from a central Taylor profile. -/
def centralTaylor_order (T : CentralTaylorData) : ℕ :=
  T.order

/-- Project the leading Taylor coefficient at the center. -/
def centralTaylor_leadingCoeff (T : CentralTaylorData) : ℂ :=
  T.leadingCoeff

/-- Project the L-function-like object from a Where package.  No
analytic-continuation or modularity claim is made. -/
def bsdWhereData_has_L (W : BSDWhereData) : ℂ → ℂ :=
  W.L

/-- Project the root number from a Where package. -/
def bsdWhereData_has_rootNumber (W : BSDWhereData) : ℂ :=
  W.rootNumber

/-- Project the central Taylor profile from a Where package. -/
def bsdWhereData_has_centralTaylor (W : BSDWhereData) : CentralTaylorData :=
  W.centralTaylor

/-- Project the named functional-equation socket from a Where package.
The returned `Prop` is the socket itself; this projection does not
prove it. -/
def bsdWhereData_has_functionalEquationSocket (W : BSDWhereData) : Prop :=
  W.functionalEquationAtCenter

/-- A typed witness that the Where-side central bundle is fully
present.  `Type`-side `structure`; the `functionalEquation_socket`
field is a `Prop` value (a named socket), not a proof obligation
discharged here. -/
structure BSDWhereCentralBundle (_W : BSDWhereData) where
  L_present : ℂ → ℂ
  center_present : ℂ
  rootNumber_present : ℂ
  taylorOrder_present : ℕ
  leadingCoeff_present : ℂ
  functionalEquation_socket : Prop

/-- Every BSD Where package produces its central bundle by forwarding
each field.  The center is supplied as `bsdCenter`.  No new data and
no new assertions are introduced. -/
def bsdWhereData_to_centralBundle
    (W : BSDWhereData) : BSDWhereCentralBundle W :=
  { L_present := W.L
    center_present := bsdCenter
    rootNumber_present := W.rootNumber
    taylorOrder_present := W.centralTaylor.order
    leadingCoeff_present := W.centralTaylor.leadingCoeff
    functionalEquation_socket := W.functionalEquationAtCenter }

/-! ## Who/Where compatibility socket decomposition

`BSDWhoWhereCompatible` carries two named sockets: the
leading-coefficient formula and the rank/order compatibility.  These
projections expose each socket as a separately addressable `Prop`.
The sockets are **not** discharged here; they are returned verbatim. -/

/-- Project the leading-coefficient formula socket as a `Prop`. -/
def bsdWhoWhereCompatible_has_leadingCoefficientFormula
    {who : BSDWhoData} {where_ : BSDWhereData}
    (C : BSDWhoWhereCompatible who where_) : Prop :=
  C.leadingCoefficientFormula

/-- Project the rank/order compatibility socket as a `Prop`.  No
identification of analytic and algebraic rank is performed. -/
def bsdWhoWhereCompatible_has_rankOrderCompatibility
    {who : BSDWhoData} {where_ : BSDWhereData}
    (C : BSDWhoWhereCompatible who where_) : Prop :=
  C.rankOrderCompatibility

/-- A `Type`-side bundle naming the two compatibility sockets.  The
fields are `Prop` values (socket statements), but the structure
itself lives in `Type` so we may carry data-bearing extensions
later without changing the universe. -/
structure BSDCompatibilitySocketBundle
    (_who : BSDWhoData) (_where_ : BSDWhereData) where
  leadingCoefficientFormula_socket : Prop
  rankOrderCompatibility_socket : Prop

/-- Every compatibility witness produces its socket bundle by
forwarding each socket field.  No new content. -/
def bsdWhoWhereCompatible_to_socketBundle
    {who : BSDWhoData} {where_ : BSDWhereData}
    (C : BSDWhoWhereCompatible who where_) :
    BSDCompatibilitySocketBundle who where_ :=
  { leadingCoefficientFormula_socket := C.leadingCoefficientFormula
    rankOrderCompatibility_socket := C.rankOrderCompatibility }

/-- The compatibility socket pair as a flat `Prop × Prop` value.
Convenient for downstream pattern-matching on the two sockets
without unfolding the structure. -/
def bsdWhoWhereCompatible_socketPair
    {who : BSDWhoData} {where_ : BSDWhereData}
    (C : BSDWhoWhereCompatible who where_) :
    Prop × Prop :=
  (C.leadingCoefficientFormula, C.rankOrderCompatibility)

/-! ## V3 Sha decomposition

The V2 `ShaData` carries only an `order : ℕ`.  V3 refines the Sha
leaf into a Selmer/Sha exact-sequence package.  The exact sequence

```
0 → E(K)/nE(K) → Sel_n(E) → Sha(E)[n] → 0
```

is recorded as typed carriers (Mordell--Weil mod `n`, Selmer group,
`n`-torsion of Sha) together with three named `Prop`-valued
exactness sockets and a single global Sha-finiteness socket.

Boundaries (none of which this file proves):

- finiteness of Sha,
- exactness of the Selmer/Sha sequence,
- existence of the Mordell--Weil / Selmer / Sha objects in any
  concrete arithmetic-geometry sense.

V3 is added non-destructively: the V2 `ShaData` is preserved, and a
forgetful map records the V3 → V2 direction.  The reverse direction
is not derivable, by design. -/

/-- Abstract Mordell--Weil group-like object. -/
structure MordellWeilLike (_E : EllipticCurveLike) where
  carrier : Type

/-- Abstract Selmer group-like object at level `n`. -/
structure SelmerGroupLike (_E : EllipticCurveLike) (_n : ℕ) where
  carrier : Type

/-- Abstract `n`-torsion component of Sha. -/
structure ShaTorsionLike (_E : EllipticCurveLike) (_n : ℕ) where
  carrier : Type

/-- Selmer/Sha exact-sequence package at level `n`.

This records the BSD-relevant shape

```
0 → E(K)/nE(K) → Sel_n(E) → Sha(E)[n] → 0
```

as typed data plus three named `Prop` sockets.  Exactness is **not**
proved here. -/
structure SelmerShaExactPackage
    (E : EllipticCurveLike) (n : ℕ) where
  mordellWeilMod : MordellWeilLike E
  selmer : SelmerGroupLike E n
  shaTorsion : ShaTorsionLike E n
  injection_socket : Prop
  surjection_socket : Prop
  exactness_socket : Prop

/-- V3 Sha data: the global Sha object as a typed carrier, an
indexed family of `n`-torsion components and Selmer/Sha exact
packages, and a single finiteness socket.

The finiteness of Sha is **not** proved; it is exposed as the
`finiteSocket` field. -/
structure ShaDataV3 (E : EllipticCurveLike) where
  shaCarrier : Type
  torsionAt : ∀ n : ℕ, ShaTorsionLike E n
  selmerShaPackage : ∀ n : ℕ, SelmerShaExactPackage E n
  finiteSocket : Prop

/-- V3 Sha data augmented with an explicit order, so that the
forgetful map to the V2 `ShaData` does not need to invent a fake
zero. -/
structure ShaDataWithOrderV3 (E : EllipticCurveLike)
    extends ShaDataV3 E where
  order : ℕ

/-- Forget a V3 Sha-with-order package down to the V2 `ShaData`
shape.  No new content; only the `order` field survives. -/
def shaData_of_v3
    {E : EllipticCurveLike}
    (S : ShaDataWithOrderV3 E) :
    ShaData :=
  { order := S.order }

/-! ### V3 Sha projections -/

/-- Project the Sha carrier from a V3 Sha package. -/
def shaDataV3_carrier
    {E : EllipticCurveLike}
    (S : ShaDataV3 E) : Type :=
  S.shaCarrier

/-- Project the indexed family of `n`-torsion components. -/
def shaDataV3_torsionAt
    {E : EllipticCurveLike}
    (S : ShaDataV3 E) :
    ∀ n : ℕ, ShaTorsionLike E n :=
  S.torsionAt

/-- Project the indexed family of Selmer/Sha exact packages. -/
def shaDataV3_selmerShaPackage
    {E : EllipticCurveLike}
    (S : ShaDataV3 E) :
    ∀ n : ℕ, SelmerShaExactPackage E n :=
  S.selmerShaPackage

/-- Project the Sha-finiteness socket from a V3 Sha package. -/
def shaDataV3_finiteSocket
    {E : EllipticCurveLike}
    (S : ShaDataV3 E) : Prop :=
  S.finiteSocket

/-! ### Selmer/Sha exact-package projections -/

/-- Project the Mordell--Weil component from a Selmer/Sha exact
package. -/
def selmerShaExactPackage_mordellWeilMod
    {E : EllipticCurveLike} {n : ℕ}
    (P : SelmerShaExactPackage E n) : MordellWeilLike E :=
  P.mordellWeilMod

/-- Project the Selmer-group component. -/
def selmerShaExactPackage_selmer
    {E : EllipticCurveLike} {n : ℕ}
    (P : SelmerShaExactPackage E n) : SelmerGroupLike E n :=
  P.selmer

/-- Project the Sha `n`-torsion component. -/
def selmerShaExactPackage_shaTorsion
    {E : EllipticCurveLike} {n : ℕ}
    (P : SelmerShaExactPackage E n) : ShaTorsionLike E n :=
  P.shaTorsion

/-- Project the injection socket
`E(K)/nE(K) ↪ Sel_n(E)`. -/
def selmerShaExactPackage_injectionSocket
    {E : EllipticCurveLike} {n : ℕ}
    (P : SelmerShaExactPackage E n) : Prop :=
  P.injection_socket

/-- Project the surjection socket
`Sel_n(E) ↠ Sha(E)[n]`. -/
def selmerShaExactPackage_surjectionSocket
    {E : EllipticCurveLike} {n : ℕ}
    (P : SelmerShaExactPackage E n) : Prop :=
  P.surjection_socket

/-- Project the exactness socket of the Selmer/Sha sequence. -/
def selmerShaExactPackage_exactnessSocket
    {E : EllipticCurveLike} {n : ℕ}
    (P : SelmerShaExactPackage E n) : Prop :=
  P.exactness_socket

end BSDBridgeC
