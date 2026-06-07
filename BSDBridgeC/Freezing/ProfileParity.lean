import BSDBridgeC.Profile.Basic
import BSDBridgeC.Freezing.Parity

/-!
# BSD Bridge C profile-level parity freezing

This file lifts the Where-layer parity freezing of
`BSDBridgeC.Freezing.Parity` to the BSD profile.  No new mathematical
content is introduced: the lift forwards the `where_` field of a
`BSDBridgeCProfile` into the Where-level wrapper.

A separate file (rather than an addition to `Freezing/Parity.lean`)
is used to avoid a circular import between `Profile.Basic` and
`Freezing.Parity`.
-/

noncomputable section

namespace BSDBridgeC

/-- A `BSDBridgeCProfile` has the negative-root-number functional
equation socket when its Where-side data does. -/
def BSDBridgeCProfileHasNegativeRootFunctionalEquation
    (P : BSDBridgeCProfile) : Prop :=
  BSDWhereHasNegativeRootFunctionalEquation P.where_

/-- A BSD profile whose Where-side has negative-root-number functional
equation forces the central value to vanish.  Profile-level wrapper
for `bsdWhereData_centralZero_of_negativeRootFunctionalEquation`. -/
theorem bsdBridgeCProfile_centralZero_of_negativeRootFunctionalEquation
    {P : BSDBridgeCProfile}
    (h : BSDBridgeCProfileHasNegativeRootFunctionalEquation P) :
    P.where_.L 1 = 0 :=
  bsdWhereData_centralZero_of_negativeRootFunctionalEquation h

end BSDBridgeC
