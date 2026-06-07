# Bridge C Generality: HP, zeta, and BSD

This document is the paper-facing presentation of the central claim
of the second `BridgeC` task: that **Bridge C is a reusable proof
architecture**, not a statement specific to one polynomial basis.
The argument is made by exhibiting the same Who / Where / central
compatibility pattern at three different mathematical addresses ---
Hermite–Pochhammer rigidity, the Mathlib zeta scaffold, and the BSD
constraint node --- and by recording, in each case, exactly which
parts are closed in Lean and which remain named open sockets.

It is **not** a claim that the Riemann Hypothesis, the BSD
conjecture, or any of the named open sockets has been discharged.

Companion documents:

- `/Users/iizumimamichi/GaussianWhoWhere/docs/BridgeCBranches.md`
- `/Users/iizumimamichi/GaussianWhoWhere/docs/LeanDAG.md`
- `/Users/iizumimamichi/BSDBridgeC/docs/LeanDAG.md`
- `/Users/iizumimamichi/BSDBridgeC/docs/BSDSerializationEngine.md`

---

## 1. Thesis

Bridge C is not a theorem about one special polynomial basis. It is
a reusable architecture: a typed coupler between **Who-data** (the
arithmetic / multiplicative side of an object) and a **Where
symmetry** (the analytic / reflective side), meeting at a **central
compatibility or rigidity node**. The same architecture appears in
three independent Lean developments. In each, the boundary between
what is formally closed and what is a named open socket is exposed
at the type level.

---

## 2. The three instances

### 2.1 C-HP: Hermite–Pochhammer rigidity

**Object.** A complex-valued deformation factor `Q : ℂ → ℂ` of
finite exponential type, used as the test class for an infinite
Hermite–Pochhammer rigidity pipeline.

**Who.** Sampled translation / multiplicativity. Two real-shift
sampled inputs with an irrational shift ratio, packaged as
`TwoIncommensurableSampledWhoInputs`.

**Where.** The function-level reflection `Q(1 - z) = Q(z)`,
encoded as `InfiniteWhere`.

**Bridge C node.** A finite-exponential-type log-derivative
backbone forces an exponential survivor, and Where kills it.

**Closed theorem (conditional).** Inside the
`GaussianWhoWhere` development:

```lean
where_rigidity_of_oddLogSample_from_jensenCartwright
  : JensenCartwrightLinearZeroBound →
    [regularity pack on Q] →
    InfiniteWhere Q →
    [two-incommensurable sampled Who-data on Q] →
    Q = fun _ => 1
```

(See `GaussianWhoWhere/Infinite/JensenFinalPipeline.lean`.)

**Local sibling theorem (unconditional).**
`bridgeC_where_firstOrder_freezes_Re` — a one-line algebraic
identity recording that Where freezes the real part of the
first-order zero displacement. It depends on no analytic socket,
and on no Hermite–Pochhammer machinery.

**Explicit socket.** `JensenCartwrightLinearZeroBound`, the
classical zero-counting upper bound for entire functions of finite
exponential type. It is consumed only as a hypothesis of the
conditional rigidity theorem. The development does not prove it.

**Boundary.** No claim about the Riemann Hypothesis. The identity
of `Q` with `riemannZeta` is not made.

### 2.2 C-zeta: the Mathlib zeta architecture

**Object.** Mathlib's analytic objects `riemannZeta`, the completed
forms `completedRiemannZeta` and `completedRiemannZeta₀`, and the
logarithmic-derivative companion.

**Who.** Dirichlet-series and Euler-product identity layers
supported on the half-plane `1 < Re(s)`. Both are typed as
`Set.EqOn`-style identifications with an explicit nonempty domain
and a model function.

**Bridge A′.** Logarithmic-derivative passage from the Euler-product
side to the von Mangoldt side.

**Where.** The completed functional equation `Λ(1 - s) = Λ(s)`,
abstracted as `CompletedWhereLike`.

**Purpose.** Interpretive and structural. The C-zeta branch records
that the same Who / Where / Bridge A′ layering already lives inside
Mathlib's `riemannZeta` infrastructure as a typed scaffold. It does
**not** prove rigidity, it does **not** identify `riemannZeta` with
a Hermite–Pochhammer deformation factor, and it does **not**
discharge the C-HP Jensen socket.

**Lean profile (in `GaussianWhoWhere/ZetaBridge/Basic.lean`).**

```lean
structure ZetaBridgeCProfile
  zetaLike, completedLike, logDerivLike : ℂ → ℂ
  bridgeA_dirichlet : BridgeA_DirichletLike zetaLike
  bridgeA_euler     : BridgeA_EulerProductLike zetaLike
  bridgeAprime      : BridgeAprime_LogDerivLike zetaLike logDerivLike
  where_completed   : CompletedWhereLike completedLike
```

**Concrete Mathlib-backed witness.** The Dirichlet layer is backed
by two equivalent Mathlib instances:

- `riemannZeta_bridgeA_dirichlet`, using
  `zeta_eq_tsum_one_div_nat_cpow`,
- `riemannZeta_bridgeA_dirichlet_natAddOne`, using
  `zeta_eq_tsum_one_div_nat_add_one_cpow`.

The Euler-product layer (`BridgeA_EulerProductLike`) and the
log-derivative layer (`BridgeAprime_LogDerivLike`) are retained as
typed interfaces of the same `Set.EqOn` existential shape; concrete
Mathlib backings would follow the same citation pattern and are not
constructed in the current development.

**Boundary.** No zero-location theorem. No HP_ft connection. No
identification between the analytic zeta object and the
Hermite–Pochhammer deformation class.

### 2.3 C-BSD: the BSD constraint node

**Object.** An elliptic-curve-like profile with an L-function-like
analytic object and a heterogeneous Who package.

**Who.** Five arithmetic invariants, deliberately heterogeneous:
torsion, Sha, Tamagawa factors, regulator, and period. Packaged in
`BSDWhoData` and projected through `BSDWhoHeterogeneousBundle`.

**Where.** A central Taylor profile at `s = 1`: an L-function-like
object `L`, a root number, the central Taylor order and leading
coefficient, and a named functional-equation socket. Packaged in
`BSDWhereData` and projected through `BSDWhereCentralBundle`.

**Bridge C node.** `BSDWhoWhereCompatible` carries the
leading-coefficient formula socket and the rank/order compatibility
socket. Both are `Prop` values; both remain undischarged in the
package. They are addressable through
`BSDCompatibilitySocketBundle` and aggregated at the profile level
through `BSDConstraintTriangle`.

**Higher-rank socket genealogy.** The rank-`r` arithmetic input is
not a single opaque assumption. It is the structure
`HigherRankArithmeticBridge E r`, with named fields for the higher
Euler system, the higher Kolyvagin system, the Kolyvagin
derivative, regulator compatibility, Selmer control, and the
core/BSD rank-matching socket. The corresponding `Prop`-valued
socket is

```lean
HigherRankSocket E r := Nonempty (HigherRankArithmeticBridge E r)
```

For `r ≥ 2` it is consumed as a hypothesis only, never discharged.

**Rank-one closure.** A supplied `RankOneHeegnerWitness E` produces
the rank-one socket mechanically:

```lean
higherRankSocket_rankOne_of_heegnerWitness
  : RankOneHeegnerWitness E → HigherRankSocket E 1
```

Gross–Zagier and Kolyvagin's theorems are **not** proved; the
witness is consumed as data.

**Parity freezing.** The algebraic root-number theorem of
`Freezing/Parity.lean` is wrapped to the Where layer and the
profile layer:

```lean
bsdWhereData_centralZero_of_negativeRootFunctionalEquation
  : BSDWhereHasNegativeRootFunctionalEquation W → W.L 1 = 0

bsdBridgeCProfile_centralZero_of_negativeRootFunctionalEquation
  : BSDBridgeCProfileHasNegativeRootFunctionalEquation P
    → P.where_.L 1 = 0
```

Neither theorem proves the functional equation. The functional
equation is one of the two conjuncts of the named hypothesis
predicate.

**Boundary.** No BSD proof. No Sha finiteness. No modularity proof
beyond what Mathlib provides. No higher Euler-system existence for
`r ≥ 2`. No analytic-rank = algebraic-rank theorem.

#### V3 refinement and leaf localization

The BSD branch has evolved past a static scaffold into a typed
dependency-DAG **observer**. Three additions, recorded in detail
in `docs/LeanDAG.md` §§3.1, 5.1, 6.1, 8.1, 8.2 and in the
companion notes `docs/LeafLocalization.md` and
`docs/PartialClosureAudit.md`:

- **V3 structural decomposition.** The bare-`Prop` fields of the
  higher-rank arithmetic bridge, the rank-one Heegner witness, and
  `ShaData` are refined into named sub-socket structures
  (`RegulatorCompatibility`, `SelmerControl`,
  `CoreRankBSDRankCompatibility`, `SelmerShaExactPackage`,
  `ShaDataV3`). V3 → V2 forgetful migration is provided; V2 → V3
  is not, by design.

- **Leaf localization.** Four BSD-branch profiles form a monotone
  refinement chain with concrete open-leaf counts: the fully
  refined profile carries `12` named open leaves. The closed-leaf
  count is invariant at `4`. The increase across the chain is a
  refinement of granularity, not an increase in difficulty.

- **Partial closure audit + pending registry.** The current
  representative audit registry classifies four entries into the
  partition `(open = 2, knownButUninternalized = 1,
  structuralCandidate = 1, closed = 0)`. A separate
  pending-audit registry records `10` refined leaves whose
  closure status has not yet been assigned.

- **Closeability audit.** A fourth orthogonal registry,
  recorded in `docs/CloseabilityAudit.md`, asks **why** each leaf
  is not closed yet. Its seven entries partition into
  `(mathematicallyOpen = 4, technicallyHard = 1,
  technicallyHeavy = 1, blockedByModeling = 1,
  closeableNow = 0)`. This distinguishes genuinely open
  mathematics from leaves that are open only because
  formalization, modeling, or engineering work is still pending.

Together the four registries
(`LeafLocalization`, `PartialClosureAudit`,
`PendingClosureAudit`, `CloseabilityAudit`) form **four
independent observation axes**. The four counts
`12`, `(2, 1, 1, 0)`, `10`, `(4, 1, 1, 1, 0)` are not a
partition of one another.

- **V4 typed-identifier layer.** The string-labeled refined
  leaves are now also values of a typed inductive
  `BSDLeafId` (`4` closed + `12` open). The audit and
  closeability registries each receive a typed `covers : List
  BSDLeafId` overlay (`AuditCoverage`,
  `CloseabilityCoverage`); membership-consistency theorems
  (disjointness, subset, `Nodup`, covers-iff-open) hold by
  `cases id <;> decide`. Two leaf-indexed lookup functions
  (`BSDLeafId.partialClosureAuditStatus`,
  `BSDLeafId.closeabilityStatus`) invert the coverage
  relations and answer queries of the form "what is the
  closeability status of this typed leaf?" in constant time.
  A bridge `BSDLeafId.toRefinementLeaf` connects the typed
  identifier back to the string registry; its four consistency
  theorems make typed/string drift a type-check failure rather
  than a documentation drift.

- **V5 branch-leaf registry.** The typed leaf-identifier
  discipline used for BSD is lifted to all four documented
  Bridge C branches. The Lean file
  `BSDBridgeC/Profile/BranchLeafRegistry.lean` declares
  `BridgeCMethodBranch` (four branches), three new typed leaf
  inductives `HPLeafId` (11 = 10 closed + 1 open),
  `ZetaLeafId` (6 = 2 closed + 4 open) and `FreezingLeafId`
  (3 = 3 closed), a forgetful conversion
  `BSDLeafId.toBranchLeaf`, and a sum type
  `BridgeCAnyLeafId` whose total registry has
  `bridgeC_allLeafIds_count = 36`. Per-branch summary records
  (`hp_branchLeafProfile`, `zeta_branchLeafProfile`,
  `bsd_branchLeafProfile`, `freezing_branchLeafProfile`) and
  the cross-branch registry `bridgeC_branchLeafProfiles`
  expose the four branches under one typed vocabulary. The
  file does **not** import `GaussianWhoWhere`; the HP and ζ
  leaves are reference-only labels at the methodology level.
  This is the V5 evidence that Bridge C is one reusable typed
  leaf-localization language applied to several objects.

The methodological slogans, recorded in
`docs/PartialClosureAudit.md`, `docs/CloseabilityAudit.md`,
and `docs/LeafLocalization.md`:

> Leaf localization is not a difficulty amplifier. It is a
> boundary detector.

> Open is not a single color.

> The V4 layer turns the observer into an index.

This is not a BSD proof. It is honest boundary detection: the
unsolved content of the BSD branch is localized to a finite,
named, count-witnessed family of leaves, with the non-exhaustivity
of the audit registry itself recorded as the Lean theorem
`bsd_partialAudit_is_not_exhaustive`.

---

## 3. Common pattern

| Branch | Object | Who | Where | Bridge C node | Closed theorem | Explicit socket |
|---|---|---|---|---|---|---|
| **HP** | deformation `Q` | sampled translations (`TwoIncommensurableSampledWhoInputs`) | reflection `Q(1−z)=Q(z)` (`InfiniteWhere`) | log-deriv backbone + exponential survivor + Where kill | `where_rigidity_of_oddLogSample_from_jensenCartwright`: `Q ≡ 1` (conditional) | `JensenCartwrightLinearZeroBound` |
| **zeta** | `riemannZeta`, `completedRiemannZeta₀` | `BridgeA_DirichletLike` + `BridgeA_EulerProductLike` (half-plane identifications) | `CompletedWhereLike` (`Λ(1−s)=Λ(s)`) | architecture profile `ZetaBridgeCProfile` | Dirichlet side concrete (`riemannZeta_bridgeA_dirichlet`) | Euler / Bridge A′ concrete instantiations deferred |
| **BSD** | elliptic-curve profile, `L(E,s)` | torsion / Sha / Tamagawa / regulator / period (`BSDWhoData`, V3-refined into `ShaDataV3` + `SelmerShaExactPackage`) | central Taylor data at `s=1` + root number (`BSDWhereData`) | `BSDWhoWhereCompatible` (leading-coefficient + rank/order sockets) | parity freezing: `negative root number ⇒ L 1 = 0` | `HigherRankSocketV3 E r` / `HigherRankSocket E r` for `r ≥ 2`; fully refined leaf profile has 12 open leaves; audit registry currently non-exhaustive |

In all three rows the table reads the same way: Who supplies
multiplicative / heterogeneous data, Where supplies a reflection or
symmetry constraint, and the central node is the typed coupler that
records what they jointly determine. The right-hand column always
contains the open mathematical content that the development
deliberately exposes rather than hides.

---

## 4. Why this is not overclaiming

The three columns are different in mathematical depth, and the
closed content is correspondingly different in each row. We do not
treat the entries as equivalent. The following bullets make the
boundaries explicit.

- The C-HP closed theorem is **conditional** on
  `JensenCartwrightLinearZeroBound`. The development isolates this
  socket; it does not prove it.
- The C-zeta branch does **not** prove the Riemann Hypothesis,
  does **not** prove zero-location, and does **not** discharge the
  C-HP Jensen socket. It records a typed scaffold matching the
  layer structure of Mathlib's `riemannZeta` infrastructure.
- The C-BSD branch does **not** prove the BSD conjecture, does
  **not** prove finiteness of `Sha`, does **not** prove modularity,
  and does **not** prove the existence of higher Euler / Kolyvagin
  systems for `r ≥ 2`. It records a socket genealogy whose open
  parts are named structure fields.
- Parity freezing in BSD is a **single algebraic identity** with
  a hypothesis-form functional equation; it is not a parity theorem
  in the modular-forms sense.
- The current C-BSD audit registry is **non-exhaustive**. The
  theorem `bsd_partialAudit_is_not_exhaustive` records that
  `bsd_pendingClosureAudit` is nonempty; ten refined leaves of
  `bsd_fullyRefinedLeafLocalizationProfile` have not yet been
  audited.
- The three count quantities reported on the BSD branch — the
  refined leaf-localization `openCount = 12`, the audit
  `«open»` count `= 2`, and the pending count `= 10` — are
  **three independent observation axes**, not a partition of one
  another. The closeability audit adds a fourth axis with
  partition `(4, 1, 1, 1, 0)`; none of the four is a refinement
  of the others. Conflating them is the standard misreading this
  document is designed to prevent.
- The closeability-audit statuses `technicallyHard`,
  `technicallyHeavy`, and `blockedByModeling` **distinguish**
  genuinely open mathematics from engineering / formalization /
  modeling work that has not yet been done. The scaffold does
  not present an under-modeled leaf as a frontier mathematical
  problem.
- The V4 typed-identifier layer (`BSDLeafId`, typed coverage,
  lookup functions, and `toRefinementLeaf` bridge) records
  **registry consistency** only. None of its theorems
  discharges any audit-`«open»` or
  closeability-`mathematicallyOpen` status. The typed layer
  is a queryable index that prevents drift between the typed
  and string registries; it is not a closure proof.

The contribution claimed across the three instances is a **typed
decomposition** and a **reusable architectural pattern**, not a
discharge of any of the named open sockets.

---

## 5. The methodological claim

Lean is used in this project not only to prove closed theorems, but
to enforce honest boundaries. The discipline followed in every
file is uniform:

- if a component is closed, it is a `theorem` whose proof body uses
  no `sorry`, no `admit`, and no `axiom`;
- if a component is open, it is either a `structure` field or a
  hypothesis in a theorem signature;
- conjectures are never spelled into `axiom`s;
- typed analytic gaps are named `Prop`s, never anonymous goals.

The slogan for this discipline is:

> **Bridge C is a proof architecture with typed exits.**

Each exit (the C-HP Jensen socket; the deferred Euler / Bridge A′
instantiations in C-zeta; the rank `≥ 2` higher-rank sockets and
the leading-coefficient / rank-order sockets in C-BSD) is visible
in the type signature of every theorem that depends on it. The
reader can determine what remains open by reading types.

---

## 6. One-sentence summary

> Across Hermite–Pochhammer, zeta, and BSD, Bridge C identifies the
> same structural pattern — heterogeneous Who-data meeting a Where
> constraint at a central compatibility node — and Lean records
> exactly which parts of that pattern are closed and which remain
> named sockets.

---

End of Bridge C generality note.
