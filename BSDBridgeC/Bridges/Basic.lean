import BSDBridgeC.WhoWhere.Basic

/-!
# BSD Bridge layers

These structures mirror the Bridge A / A′ / B / C decomposition.
They are sockets: each field names exactly what a future proof or a
known theorem would have to supply.
-/

noncomputable section

namespace BSDBridgeC

/-- External modularity / automorphy supply. -/
structure ModularitySocket (E : EllipticCurveLike) where
  modularityWitness : Prop

/-- Bridge A: encode the arithmetic object into an L-function identity
layer. -/
structure BridgeA_Encode (E : EllipticCurveLike) (where_ : BSDWhereData) where
  modularity : ModularitySocket E
  eulerProductModel : Prop
  dirichletModel : Prop

/-- Bridge A′: logarithmic-derivative style companion. -/
structure BridgeAprime_LogDeriv (where_ : BSDWhereData) where
  logDerivativeModel : Prop
  poleResidueEncoding : Prop

/-- Iwasawa-main-conjecture style decode socket. -/
structure IwasawaMainSocket (E : EllipticCurveLike) where
  characteristicIdealComparison : Prop

/-- Bridge B: decode central Taylor data back into arithmetic data. -/
structure BridgeB_Decode
    (E : EllipticCurveLike) (who : BSDWhoData) (where_ : BSDWhereData) where
  iwasawaMain : IwasawaMainSocket E
  taylorToArithmetic : Prop
  normalizationCompatibility : Prop

/-- Bridge C: the rigidity / compatibility coupler at the center. -/
structure BridgeC_Rigidity
    (E : EllipticCurveLike) (who : BSDWhoData) (where_ : BSDWhereData) where
  whoWhere : BSDWhoWhereCompatible who where_
  encode : BridgeA_Encode E where_
  decode : BridgeB_Decode E who where_
  logDeriv : BridgeAprime_LogDeriv where_

def bridgeC_has_who_where
    {E : EllipticCurveLike} {who : BSDWhoData} {where_ : BSDWhereData}
    (C : BridgeC_Rigidity E who where_) :
    BSDWhoWhereCompatible who where_ :=
  C.whoWhere

/-! ## Bridge A internal socket projections

`BridgeA_Encode` exposes a modularity socket together with two
analytic-model socket fields.  No analytic content is discharged
here; each projection returns the existing field. -/

/-- Project the modularity socket from a Bridge A encode layer. -/
def bridgeA_has_modularity
    {E : EllipticCurveLike} {where_ : BSDWhereData}
    (A : BridgeA_Encode E where_) : ModularitySocket E :=
  A.modularity

/-- Project the Euler-product model socket from a Bridge A encode
layer.  This is a `Prop`-valued socket value, not a proof. -/
def bridgeA_has_eulerProductModel
    {E : EllipticCurveLike} {where_ : BSDWhereData}
    (A : BridgeA_Encode E where_) : Prop :=
  A.eulerProductModel

/-- Project the Dirichlet-series model socket from a Bridge A encode
layer.  This is a `Prop`-valued socket value, not a proof. -/
def bridgeA_has_dirichletModel
    {E : EllipticCurveLike} {where_ : BSDWhereData}
    (A : BridgeA_Encode E where_) : Prop :=
  A.dirichletModel

/-! ## Bridge A′ internal socket projections

The log-derivative companion records two analytic socket fields,
mirroring Bridge A′ of the Mathlib zeta architecture. -/

/-- Project the logarithmic-derivative model socket from a Bridge A′
layer. -/
def bridgeAprime_has_logDerivativeModel
    {where_ : BSDWhereData}
    (A' : BridgeAprime_LogDeriv where_) : Prop :=
  A'.logDerivativeModel

/-- Project the pole/residue encoding socket from a Bridge A′ layer. -/
def bridgeAprime_has_poleResidueEncoding
    {where_ : BSDWhereData}
    (A' : BridgeAprime_LogDeriv where_) : Prop :=
  A'.poleResidueEncoding

/-! ## Bridge B internal socket projections

`BridgeB_Decode` exposes the Iwasawa-main-conjecture style socket
together with two compatibility socket fields.  No decode is
performed here; each projection returns the existing field. -/

/-- Project the Iwasawa-main-conjecture socket from a Bridge B decode
layer. -/
def bridgeB_has_iwasawaMain
    {E : EllipticCurveLike} {who : BSDWhoData} {where_ : BSDWhereData}
    (B : BridgeB_Decode E who where_) : IwasawaMainSocket E :=
  B.iwasawaMain

/-- Project the Taylor-to-arithmetic compatibility socket from a
Bridge B decode layer. -/
def bridgeB_has_taylorToArithmetic
    {E : EllipticCurveLike} {who : BSDWhoData} {where_ : BSDWhereData}
    (B : BridgeB_Decode E who where_) : Prop :=
  B.taylorToArithmetic

/-- Project the normalization-compatibility socket from a Bridge B
decode layer. -/
def bridgeB_has_normalizationCompatibility
    {E : EllipticCurveLike} {who : BSDWhoData} {where_ : BSDWhereData}
    (B : BridgeB_Decode E who where_) : Prop :=
  B.normalizationCompatibility

/-! ## Bridge C internal projections

The `whoWhere` projection already exists above as
`bridgeC_has_who_where`.  The three remaining sub-bridges are exposed
in matching form. -/

/-- Project the Bridge A encode layer from a Bridge C rigidity
package. -/
def bridgeC_has_encode
    {E : EllipticCurveLike} {who : BSDWhoData} {where_ : BSDWhereData}
    (C : BridgeC_Rigidity E who where_) :
    BridgeA_Encode E where_ :=
  C.encode

/-- Project the Bridge B decode layer from a Bridge C rigidity
package. -/
def bridgeC_has_decode
    {E : EllipticCurveLike} {who : BSDWhoData} {where_ : BSDWhereData}
    (C : BridgeC_Rigidity E who where_) :
    BridgeB_Decode E who where_ :=
  C.decode

/-- Project the Bridge A′ log-derivative companion from a Bridge C
rigidity package. -/
def bridgeC_has_logDeriv
    {E : EllipticCurveLike} {who : BSDWhoData} {where_ : BSDWhereData}
    (C : BridgeC_Rigidity E who where_) :
    BridgeAprime_LogDeriv where_ :=
  C.logDeriv

end BSDBridgeC
