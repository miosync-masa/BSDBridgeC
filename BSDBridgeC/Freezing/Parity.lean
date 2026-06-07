import BSDBridgeC.WhoWhere.Basic

/-!
# BSD parity freezing

This file proves only the algebraic root-number consequence:
if a central functional equation has sign `-1`, then the central
value vanishes.  It does not prove BSD, parity, or analytic
continuation.
-/

noncomputable section

namespace BSDBridgeC

/-- A center-`1` functional equation with root number `w`, expressed
in local coordinates around the center. -/
def RootNumberFunctionalEquation (L : ℂ → ℂ) (w : ℂ) : Prop :=
  ∀ t : ℂ, L (1 + t) = w * L (1 - t)

/-- If the root number is `-1`, the center value is forced to vanish. -/
theorem bsd_where_rootNumber_forces_centralZero
    {L : ℂ → ℂ}
    (hFE : RootNumberFunctionalEquation L (-1))
    : L 1 = 0 := by
  have h0 : L 1 = -L 1 := by
    simpa using hFE 0
  have hsum : L 1 + L 1 = 0 := by
    exact eq_neg_iff_add_eq_zero.mp h0
  have hmul : (2 : ℂ) * L 1 = 0 := by
    rw [← hsum]
    ring
  exact (mul_eq_zero.mp hmul).resolve_left (by norm_num)

/-- Application-flavored alias: Where sign `-1` freezes the central
coefficient at order at least one. -/
theorem bsd_where_sign_neg_one_forces_vanishing
    {L : ℂ → ℂ}
    (hFE : RootNumberFunctionalEquation L (-1)) :
    L 1 = 0 :=
  bsd_where_rootNumber_forces_centralZero hFE

/-! ## WhereData-level wrapper

The algebraic theorem above is now packaged against the
`BSDWhereData` scaffold: a Where-side package satisfies the
"negative root number with sign `-1` functional equation" predicate
when its declared root number is `-1` and the functional equation
itself holds.  Neither component is discharged; both are supplied as
a hypothesis. -/

/-- A `BSDWhereData` package has the negative-root-number functional
equation socket if its `rootNumber` field is `-1` and the
`RootNumberFunctionalEquation` holds for its `L`. -/
def BSDWhereHasNegativeRootFunctionalEquation
    (W : BSDWhereData) : Prop :=
  W.rootNumber = -1 ∧ RootNumberFunctionalEquation W.L (-1)

/-- A `BSDWhereData` package with negative-root-number functional
equation forces the central value to vanish.  This is the parity
freezing statement at the Where layer. -/
theorem bsdWhereData_centralZero_of_negativeRootFunctionalEquation
    {W : BSDWhereData}
    (h : BSDWhereHasNegativeRootFunctionalEquation W) :
    W.L 1 = 0 :=
  bsd_where_rootNumber_forces_centralZero h.2

end BSDBridgeC
