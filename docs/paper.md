# Bridge C and Recursive Leaf Localization

**Working title.** *Bridge C and Recursive Leaf Localization: A Lean 4
Discipline for the Openness of Large Mathematical Theorems —
demonstrated across Hermite--Pochhammer rigidity, the Mathlib zeta
scaffold, and BSD*

**Target venue.** Journal of Automated Reasoning.

**Repositories.**

- `GaussianWhoWhere`: <https://github.com/miosync-masa/GaussianWhoWhere>
- `BSDBridgeC`: <https://github.com/miosync-masa/BSDBridgeC>
- cited only: `ck-hopf-formalization`,
  <https://github.com/miosync-masa/ck-hopf-formalization>
- cited only: `NSBarrier`, <https://github.com/miosync-masa/NSBarrier>

## 1. Introduction

The introduction is maintained separately as `introduction_v2.tex`.
This working Markdown file begins with Section 2 and will be expanded
section by section.

## 2. Mathlib Layer Separation and the Origin of Bridge C

The first observation behind Bridge C is not a new theorem about
zeta.  It is a proof-engineering observation about how Mathlib already
organizes the Riemann zeta function.  The informal expression

\[
  \zeta(s)=\sum_{n\ge 1}n^{-s}
  =\prod_p(1-p^{-s})^{-1}
\]

looks like a single mathematical object carrying several equivalent
faces.  In Lean, those faces are not silently identified.  They live
in different definitions, files, theorem statements, and convergence
domains.  The analytic object, the Dirichlet-series model, the Euler
product, the completed functional equation, and the logarithmic
derivative passage are all separately typed and connected by named
theorems.

This is the architectural seed of Bridge C.  Lean does not merely
transcribe the classical zeta notation into formal syntax.  It exposes
that the zeta infrastructure is a family of typed layers glued by
conditional bridges.  The rest of this paper abstracts that
organization into the Who/Where vocabulary and then demonstrates that
the same vocabulary can be applied to three independent settings:
Hermite--Pochhammer rigidity, the Mathlib zeta scaffold, and the BSD
dependency DAG.

### 2.1. The two typed sides

Mathlib separates the analytic side of zeta from its arithmetic
presentations.

On the analytic side, the file
`Mathlib/NumberTheory/LSeries/RiemannZeta.lean` defines
`riemannZeta : ℂ → ℂ` through the Hurwitz-zeta infrastructure rather
than as an Euler product.  The same file defines the completed zeta
objects

```lean
completedRiemannZeta₀ : ℂ → ℂ
completedRiemannZeta  : ℂ → ℂ
```

and proves the completed functional-equation statements

```lean
completedRiemannZeta₀_one_sub :
  completedRiemannZeta₀ (1 - s) = completedRiemannZeta₀ s

completedRiemannZeta_one_sub :
  completedRiemannZeta (1 - s) = completedRiemannZeta s
```

as well as the uncompleted functional-equation descendant
`riemannZeta_one_sub` under its own side conditions.  This analytic
side also contains the formal proposition

```lean
RiemannHypothesis : Prop
```

which is deliberately only a proposition.  Mathlib does not prove it,
and no part of this paper treats it as proved.

On the arithmetic side, Mathlib provides Dirichlet-series and Euler
product identities on the convergence half-plane.  The Dirichlet
series is not the global definition of `riemannZeta`; it is a theorem
with a hypothesis:

```lean
zeta_eq_tsum_one_div_nat_cpow :
  1 < s.re →
  riemannZeta s = ∑' n : ℕ, 1 / (n : ℂ) ^ s

zeta_eq_tsum_one_div_nat_add_one_cpow :
  1 < s.re →
  riemannZeta s = ∑' n : ℕ, 1 / (n + 1 : ℂ) ^ s
```

The same half-plane, \(1 < \operatorname{Re}(s)\), supports the Euler
product identities developed in
`Mathlib/NumberTheory/EulerProduct/DirichletLSeries.lean`.  Thus the
analytic object and the arithmetic presentations are not collapsed
into one definition.  They are two typed sides, connected on a shared
domain by named theorems.

This separation is the key proof-engineering fact.  The proof
assistant requires the user to distinguish:

- the globally defined analytic function;
- the Dirichlet-series model on \(1<\operatorname{Re}(s)\);
- the Euler-product model on \(1<\operatorname{Re}(s)\);
- the completed reflective object;
- the propositions asserting that these layers agree where their
  hypotheses permit.

Bridge C begins by taking this separation seriously.

### 2.2. The arithmetic bridge family: design rationale

The Euler product layer is not represented in just one form.  Mathlib
keeps several shapes because they serve different downstream
purposes.  In
`Mathlib/NumberTheory/EulerProduct/DirichletLSeries.lean`, the zeta
Euler product appears as:

```lean
riemannZeta_eulerProduct_hasProd :
  1 < s.re →
  HasProd (fun p : Primes ↦ (1 - (p : ℂ) ^ (-s))⁻¹)
    (riemannZeta s)
```

```lean
riemannZeta_eulerProduct_tprod :
  1 < s.re →
  ∏' p : Primes, (1 - (p : ℂ) ^ (-s))⁻¹ = riemannZeta s
```

and also in finite-partial-product convergence form:

```lean
riemannZeta_eulerProduct :
  1 < s.re →
  Tendsto
    (fun n : ℕ ↦ ∏ p ∈ primesBelow n,
      (1 - (p : ℂ) ^ (-s))⁻¹)
    atTop
    (𝓝 (riemannZeta s))
```

The exp-log form provides a further presentation:

```lean
riemannZeta_eulerProduct_exp_log :
  1 < s.re →
  exp (∑' p : Nat.Primes,
    -Complex.log (1 - p ^ (-s))) = riemannZeta s
```

These are not redundant from the point of view of formal proof
engineering.  The `HasProd` form packages convergence and product
value together.  The `tprod` form is an equational endpoint suitable
for rewriting.  The finite-product `Tendsto` form exposes the
approximation-by-primes structure.  The exp-log form is the gateway to
logarithmic differentiation and prime-power expansions.

The important point is that Mathlib does not hide these choices behind
one overloaded equality.  It keeps the bridge family explicit.  Each
member of the family carries the same domain hypothesis
\(1 < \operatorname{Re}(s)\), but each has a different type because
each is meant for a different proof consumer.

This is the design rationale that Bridge C later reuses.  Arithmetic
content is not a monolith.  It comes in typed forms, and the useful
form depends on the bridge one wants to build next.

### 2.3. The exp-log hinge and Bridge A′

The exp-log Euler product is the hinge between multiplicative
arithmetic and additive logarithmic data.  In classical notation, one
passes from

\[
  \prod_p(1-p^{-s})^{-1}
\]

to logarithms, differentiates, and obtains a series involving the von
Mangoldt function.  Mathlib records this passage on the same
half-plane through the theorem

```lean
LSeries_vonMangoldt_eq_deriv_riemannZeta_div :
  1 < s.re →
  L ↗Λ s = - deriv riemannZeta s / riemannZeta s
```

in `Mathlib/NumberTheory/LSeries/Dirichlet.lean`.

From the Bridge C point of view, this is the prototype of what we call
Bridge A′.  Bridge A connects an analytic object to an arithmetic
identity layer, such as a Dirichlet series or Euler product.  Bridge A′
is the derivative/logarithmic companion that exposes arithmetic data
through a different analytic lens.  For zeta, the passage can be read
as the chain

```text
analytic object riemannZeta
  → Dirichlet-series identity on 1 < Re(s)
  → Euler-product identity on 1 < Re(s)
  → exp-log Euler product
  → logarithmic derivative
  → von Mangoldt L-series
```

The chain is not asserted as one massive theorem.  It is assembled
from separately typed theorems, each with its own domain and
downstream use.  This is the proof-engineering pattern that the later
formal developments imitate: large mathematical structures are made
legible by exposing their bridges as named interfaces.

This section makes no claim about zero locations.  The logarithmic
derivative is relevant to zero geometry because zeros and poles
control logarithmic derivatives, but the Mathlib theorem above is a
half-plane identity.  It is part of the arithmetic bridge family, not
a proof of the Riemann Hypothesis.

### 2.4. Where in the completed analytic layer

The Where side is the reflective analytic layer.  For zeta, Mathlib
places this layer on the completed functions.  The theorem

```lean
completedRiemannZeta₀_one_sub :
  completedRiemannZeta₀ (1 - s) = completedRiemannZeta₀ s
```

is the clean entire-function version.  The theorem

```lean
completedRiemannZeta_one_sub :
  completedRiemannZeta (1 - s) = completedRiemannZeta s
```

is the corresponding statement for the completed zeta object itself.
The uncompleted theorem `riemannZeta_one_sub` descends this symmetry
to the uncompleted zeta function with additional side conditions.

The map \(s \mapsto 1-s\) has fixed axis
\(\operatorname{Re}(s)=1/2\).  In informal analytic number theory this
is the geometric origin of the critical line.  In Lean, this geometry
is not silently transformed into RH.  Mathlib defines
`RiemannHypothesis : Prop` as a formal proposition about the zeros of
`riemannZeta`, excluding the trivial zeros and the pole at \(s=1\).
Constructing a term of this proposition is exactly what is not done.

This distinction is essential for the present paper.  Where provides
reflection symmetry.  It does not, by itself, prove that all zeros lie
on the fixed axis.  Bridge C is the discipline of keeping the
reflective constraint visible without overclaiming the zero-location
conclusion.

The same discipline reappears later in two different guises.  In the
Hermite--Pochhammer branch, a Where condition `Q(1 - z) = Q z` is
combined with Who data to force rigidity, conditional on a single
Jensen--Cartwright zero-density socket.  In the BSD branch, the
functional-equation center \(s=1\) is treated as a Where node for
central Taylor data and root-number parity.  Neither reuse claims RH
or BSD; both reuse the same typed separation between arithmetic
identity and reflective geometry.

### 2.5. Layer separation summary and the Who/Where vocabulary

The Mathlib zeta infrastructure motivates the vocabulary used in the
rest of the paper.

We call the arithmetic/multiplicative side **Who**.  In the zeta
case, Who consists of the Dirichlet-series theorem, the Euler product
family, the exp-log hinge, and the von Mangoldt logarithmic-derivative
passage.  These are the theorems that identify what the analytic
object is on a convergence domain.

We call the reflective analytic side **Where**.  In the zeta case,
Where is the completed functional equation and the geometry of the
involution \(s \mapsto 1-s\).  It constrains where symmetric analytic
features must live, but it does not by itself solve the zero-location
problem.

This gives the guiding slogan:

```text
Who identifies the object.
Where constrains the geometry.
Bridge C records their typed interaction.
```

The point of the slogan is not to introduce informal metaphors in
place of proof.  It is to name a layer separation that Lean already
forces.  Once this separation is visible, it can be transported to
other settings.

In the Hermite--Pochhammer branch, Who becomes sampled
translation/multiplicativity data for a deformation factor \(Q\), and
Where becomes reflection \(Q(1-z)=Q(z)\).  In the BSD branch, Who is a
heterogeneous arithmetic package consisting of torsion, Sha, Tamagawa
factors, regulator, and period data, while Where is central Taylor
data at \(s=1\), root number, and the functional-equation center.  In
the zeta branch, the same distinction is already present in Mathlib
itself.

Thus Section 2 establishes the methodological hook for a Journal of
Automated Reasoning audience: Lean is not used merely to formalize a
classical definition of zeta.  Lean reveals that the classical object
is already organized as a typed dependency graph.  Bridge C is the
general discipline extracted from that graph.

## 3. Bridge C as a Typed Coupler with Named Exits

Bridge C is not a new equation.  It is a typed coupler.  It receives
Who and Where as separately typed inputs, composes them through a
specified theorem schema, and exposes every non-trivial analytic step
as a named exit in the type signature.  The purpose of the phrase
"Bridge C" is therefore not to name a special function, and not to
assert a hidden identification between zeta, Hermite--Pochhammer
deformations, and BSD.  It is to name a proof architecture.

The guiding design rule is:

```text
If a mathematical step is not formalized, it must appear as a named
socket in the type signature.
```

This rule is the reason Bridge C is suitable for large mathematical
theorems.  It permits the development to assemble closed theorem
fragments without pretending that the remaining analytic or arithmetic
content has disappeared.  In later sections this becomes the recursive
leaf-localization discipline.  At the present stage, it first appears
as a typed coupler with named exits.

### 3.1. From vocabulary to Lean predicates

The lightest layer of the Lean formalization is in
`GaussianWhoWhere/BridgeStructure.lean`.  This file deliberately
introduces names before machinery.  The relevant definitions are:

```lean
ReflectedZeroSymmetry : (ℂ → ℂ) → Prop
CriticalLineProperty : (ℂ → ℂ) → Prop
FunctionalSymmetry   : (ℂ → ℂ) → Prop
ArithmeticIdentity   : (ℂ → ℂ) → Prop
WhoWhereCompatible   : (ℂ → ℂ) → Prop
```

The definitions are intentionally lightweight.  `ArithmeticIdentity`
is a placeholder for arithmetic identity content such as Euler
products, Dirichlet series, multiplicativity, or sampled translation
relations.  `FunctionalSymmetry` records reflection symmetry of the
zero locus.  `WhoWhereCompatible` is merely the conjunction of the two
roles.  It is not a theorem and it is not used to prove the critical
line property.

The first structural lemma is tautological:

```lean
where_gives_reflected_zero_geometry :
  FunctionalSymmetry F → ReflectedZeroSymmetry F
```

This lemma matters precisely because it is small.  It says that the
Where side gives reflected zero geometry, but it does not say that
reflected zero geometry implies that all zeros lie on the critical
line.  That stronger statement would be RH-strength in the zeta
setting and is not asserted.

This first layer therefore fixes the vocabulary:

- **Who** is an arithmetic identity role;
- **Where** is a reflective geometry role;
- **Bridge C** is the coupler that will later combine the two.

The file is not meant to solve anything.  It is meant to stop the
paper from using one informal word for several distinct typed roles.

### 3.2. The data-bearing infinite interface

The next layer is
`GaussianWhoWhere/InfiniteCoupler.lean`.  Here Bridge C becomes a
theorem schema.  The file introduces the following objects:

```lean
HPftLike
InfiniteWho
InfiniteWhere
TwoTranslationExponentialRigidity
WhereKillsExponential
infinite_who_where_rigidity
```

The interface is deliberately asymmetric.  `InfiniteWho Q` is
data-bearing.  It contains two shifts, two eigenvalues, nonzero
conditions, an incommensurability condition, and two translation
eigen-relations:

```lean
structure InfiniteWho (Q : ℂ → ℂ) where
  shift2 : ℂ
  shift3 : ℂ
  A2 : ℂ
  A3 : ℂ
  hshift2_ne_zero : shift2 ≠ 0
  hshift3_ne_zero : shift3 ≠ 0
  hincommensurable : ∀ q : ℚ, shift2 ≠ (q : ℂ) * shift3
  trans2 : ∀ z : ℂ, Q (z + shift2) = A2 * Q z
  trans3 : ∀ z : ℂ, Q (z + shift3) = A3 * Q z
```

By contrast, `InfiniteWhere Q` is propositional:

```lean
structure InfiniteWhere (Q : ℂ → ℂ) : Prop where
  reflect : ∀ z : ℂ, Q (1 - z) = Q z
```

This asymmetry is not accidental.  Who is the part of the interface
that must carry witnesses: shifts, eigenvalues, and translation laws.
Where is the reflective constraint.  The former is a data package; the
latter is a proposition.

The analytic class itself is kept abstract:

```lean
HPftLike Q
```

and the two non-trivial analytic exits are named:

```lean
TwoTranslationExponentialRigidity Q
WhereKillsExponential Q
```

The first exit says that `HPftLike Q` plus `InfiniteWho Q` forces an
exponential survivor.  The second says that `InfiniteWhere Q` kills
that exponential survivor and leaves the constant function `1`.  The
coupler theorem is:

```lean
infinite_who_where_rigidity :
  HPftLike Q →
  InfiniteWho Q →
  InfiniteWhere Q →
  TwoTranslationExponentialRigidity Q →
  WhereKillsExponential Q →
  Q = fun _ : ℂ => 1
```

This theorem is closed, but it is not a Jensen--Cartwright theorem.
It is the typed skeleton of the coupler.  The heavy analytic content
is not hidden.  It appears in the two named exits
`TwoTranslationExponentialRigidity` and `WhereKillsExponential`.

### 3.3. Bridge C as a theorem schema, not a special function

The abstract infinite schema can be displayed as:

```text
HPftLike Q + InfiniteWho Q
  ──[TwoTranslationExponentialRigidity]──▶
  ∃ c, Q(z) = exp(c z)

InfiniteWhere Q
  ──[WhereKillsExponential]──▶
  the exponential survivor is killed

therefore
  Q ≡ 1.
```

The first arrow is the Who side: translation structure and
finite-type analytic control produce a surviving exponential.  The
second arrow is the Where side: reflection symmetry eliminates the
survivor.  The conclusion is rigidity.

This diagram is a theorem schema, not a definition of zeta and not a
claim about a special analytic function.  In particular, the symbol
`Q` in the Hermite--Pochhammer branch is a deformation factor.  It is
not `riemannZeta`.  The zeta branch, discussed in Section 2, supplies
the architectural motivation: Mathlib's zeta infrastructure already
shows Who, Bridge A′, and Where layers.  The HP branch is where the
coupler becomes a rigidity theorem.  The BSD branch is where the same
dependency-reading discipline becomes a leaf-localization and
closeability-audit discipline.

Thus Bridge C should be read as a reusable typed coupler:

```text
Bridge C = Who input + Where input + named exits.
```

It is not an additional equation of analytic number theory.  It is a
way to keep the equation-shaped parts, the symmetry-shaped parts, and
the unformalized exits separated.

### 3.4. The three branches

The paper uses Bridge C in three object branches and one local
mechanism branch.

```text
Bridge C
├── C-HP
│   Hermite--Pochhammer deformation factor Q
│   Who: sampled translation / multiplicativity
│   Where: Q(1 - z) = Q(z)
│   Output: Q ≡ 1, conditional on JensenCartwrightLinearZeroBound
│
├── C-zeta
│   Mathlib riemannZeta / completed zeta / log derivative
│   Who: Dirichlet, Euler, exp-log, von Mangoldt bridge family
│   Where: completed functional equation
│   Output: architecture scaffold, no zero-location theorem
│
├── C-BSD
│   BSD-shaped elliptic-curve L-function profile
│   Who: torsion, Sha, Tamagawa, regulator, period
│   Where: central Taylor data at s = 1 and root number
│   Output: typed dependency DAG, leaf localization, audit registries
│
└── C-freezing
    local algebraic response mechanism
    Output: first-order or parity-style freezing lemmas
```

The three object branches realize different aspects of the same
coupler.  C-HP carries the strongest closed rigidity theorem and the
single remaining Jensen--Cartwright analytic socket.  C-zeta records
the Mathlib architecture that motivates the vocabulary.  C-BSD shows
that the same vocabulary can be used as a dependency-DAG observer for
a large conjectural statement without pretending to prove it.
C-freezing isolates a local algebraic effect of Where: reflection
can freeze a real displacement or force a central value to vanish
under a negative root number.

The common vocabulary is therefore not a claim that these branches are
the same mathematics.  It is a claim that the same typed distinction
between Who, Where, bridges, and exits is useful in all three
addresses.

### 3.5. Shared machinery and independence

Because Bridge C is a coupler, the paper must keep the branches
independent.  Four confusions are especially important to avoid.

First, **C-HP is not zeta**.  The deformation factor \(Q\) in the
Hermite--Pochhammer branch is not `riemannZeta`.  The HP branch proves
finite rigidity theorems and builds an infinite pipeline conditional
on `JensenCartwrightLinearZeroBound`.  It does not import zeta
zero-location results.

Second, **the zeta scaffold is not a zero-location theorem**.  The
zeta branch records Dirichlet, Euler, exp-log, logarithmic-derivative,
and completed-Where layers.  The formal proposition
`RiemannHypothesis` remains unproved.  The scaffold explains why the
Who/Where language is natural; it does not prove RH.

Third, **a socket is not a hidden proof**.  When the development
requires zero-density input, higher-rank Euler-system input, Sha
finiteness, or BSD rank/order compatibility, the input appears as a
named structure field or hypothesis.  The type signature shows where
the proof exits.

Fourth, **numerics are not proof**.  Numerical root-tracking and
stiffness experiments may support the Bridge C interpretation, but
they do not replace any Lean theorem.  The formal artifact remains
the typed decomposition and the closed theorem nodes.

These independence rules are as important as the closed theorem
statements.  They keep Bridge C from becoming a slogan that silently
identifies different objects.  In Lean, the branches remain separated
by types, imports, and explicit hypotheses.  In the paper, the same
separation is maintained by the vocabulary of named exits.

This fixes the meaning of "Bridge C" for the rest of the paper:

```text
Bridge C is a typed coupler with named exits.
It is reusable because the roles are typed separately.
It is honest because the exits are visible.
```

## 4. The C-HP Instance: Hermite--Pochhammer Rigidity

The Hermite--Pochhammer branch is the first branch in which Bridge C
is not only an architectural vocabulary but an actual rigidity
pipeline.  The finite part is completely closed.  The infinite part
is conditional on exactly one named analytic socket:

```lean
JensenCartwrightLinearZeroBound
```

Everything downstream of that socket is mechanically composed in
Lean.  This is the important point for the present paper.  The C-HP
branch does not merely say that a future analytic theorem would be
useful.  It proves, in Lean, that once the Jensen--Cartwright
zero-counting input is supplied, the rest of the infinite
Hermite--Pochhammer rigidity argument is already wired all the way to
the conclusion \(Q \equiv 1\).

The relevant source files are:

```text
GaussianWhoWhere/HermitePochhammer.lean
GaussianWhoWhere/PolynomialRigidity.lean
GaussianWhoWhere/FiniteGeneralUniqueness.lean
GaussianWhoWhere/Infinite/JensenFinalPipeline.lean
GaussianWhoWhere/Infinite/JensenCartwrightInterface.lean
GaussianWhoWhere/Infinite/WhereKillsExponentialFunctionLevelConcrete.lean
```

Several auxiliary infinite-pipeline files sit between these endpoints:
`TranslationDefect.lean`, `TwoShiftCoupler.lean`,
`LogDerivativeAlgebra.lean`, `RealAxisConstToGlobalConcrete.lean`,
`GlobalLogDerivConstToExpConcrete.lean`, and the zero-density and
log-sample files discussed below.  The theorem map in
`GaussianWhoWhere/TheoremMap.lean` records the names used in this
section.

### 4.1. The deformation class: finite and infinite

The finite deformation class is implemented directly as a polynomial
family.  In `GaussianWhoWhere/FiniteGeneralUniqueness.lean` the
definition is:

```lean
def QFinitePoly (K : ℕ) (c : Fin K → ℝ) : Polynomial ℝ :=
  1 + ∑ k : Fin K, Polynomial.C (c k) * P2nPoly (2 * (k.val + 1))
```

Mathematically this is the finite Hermite--Pochhammer deformation

\[
  Q_K(x) = 1 + \sum_{k=1}^{K} c_k P_{4k}(x).
\]

The difference is only indexing.  Lean uses `c : Fin K → ℝ`, so the
summand indexed by `k : Fin K` is \(P_{4(k+1)}\).  The code comment
in `FiniteGeneralUniqueness.lean` records this convention explicitly.

The basis polynomials are built in
`GaussianWhoWhere/HermitePochhammer.lean`.  The central general
polynomial is

```lean
P2nPoly
```

together with structural lemmas such as

```lean
coeff_P2nPoly_top
natDegree_P2nPoly
leadingCoeff_P2nPoly
```

These identify the top coefficient and degree of the basis element.
That degree information is the finite proof's main algebraic
resource: the summands in `QFinitePoly K c` occupy separated top
degrees, so the top coefficient can be peeled off one coefficient at
a time.

The infinite branch deliberately does not formalize an infinite
coefficient sequence at this stage.  Instead, it works with a function

```lean
Q : ℂ → ℂ
```

equipped with the analytic and structural predicates needed by the
rigidity pipeline.  The most important class predicate is

```lean
FiniteExpType Q
```

from `GaussianWhoWhere/Infinite/FiniteExponentialType.lean`.  The
infinite argument therefore separates the intended motivating
Hermite--Pochhammer picture from the analytic interface actually
needed by the theorem.  The theorem does not require a formal
construction of \(Q\) from an infinite coefficient sequence.  It
requires finite exponential type, differentiability, nonvanishing,
normalization, an analytic log-derivative, sampled Who-data, and
Where symmetry.  That separation is part of the design discipline:
the coefficient-realization problem is not silently conflated with
the rigidity pipeline.

### 4.2. Finite rigidity: closed and unconditional

The finite theorem is:

```lean
finite_general_uniqueness
```

from `GaussianWhoWhere/FiniteGeneralUniqueness.lean`.  Its statement
is:

```lean
theorem finite_general_uniqueness
    (K : ℕ) (c : Fin K → ℝ)
    (hmul : ∀ x y : ℝ,
      (QFinitePoly K c).eval (x + y)
        = (QFinitePoly K c).eval x * (QFinitePoly K c).eval y) :
    ∀ k : Fin K, c k = 0
```

Thus every coefficient of the finite deformation is zero if the
polynomial satisfies the additive multiplicativity equation.  The
finite branch is unconditional.  It does not consume
`JensenCartwrightLinearZeroBound`, a zero-density principle, an
analytic continuation theorem, or any zeta input.

The proof has four named ingredients.

First, `GaussianWhoWhere/PolynomialRigidity.lean` supplies

```lean
polynomial_translation_rigidity
```

This is the abstract polynomial fact: if a real polynomial satisfies
a nontrivial translation-eigen relation and is normalized at zero,
then it is constant.  In the finite proof it is used through

```lean
QFinitePoly_eq_one_of_translation
```

which specializes the general rigidity lemma to `QFinitePoly K c`.

Second, the Hermite--Pochhammer basis has separated degree behavior.
The lemmas `natDegree_P2nPoly`, `leadingCoeff_P2nPoly`, and
`coeff_P2nPoly_top` show that the top term in the truncation is
visible at a degree where lower summands do not contribute.

Third, the file proves a descending coefficient-peeling lemma:

```lean
coeffs_zero_of_QFinitePoly_eq_one
```

If `QFinitePoly K c = 1`, then every coefficient `c k` is zero.
The proof is by induction on `K`; at the successor step it reads off
the top coefficient, forces the last coefficient to vanish, and then
applies the induction hypothesis to the shortened polynomial.

Fourth, the full multiplicativity hypothesis is reduced to the
translation-rigidity situation by a normalization dichotomy at
`x = 0`.  From

```lean
hmul 0 0
```

Lean obtains

```text
(QFinitePoly K c).eval 0 = 1
```

or

```text
(QFinitePoly K c).eval 0 = 0.
```

The first branch uses translation rigidity at the shift `1`.  The
second branch uses the multiplicative equation with `y = 0` to force
the polynomial to be identically zero, and then the coefficient
peeling argument against the constant polynomial `0` again forces all
coefficients to vanish.  This is implemented by the generalized
peeling lemma

```lean
coeffs_zero_of_QFinitePoly_eq_C
```

The finite conclusion is therefore a closed polynomial theorem.  It
is the C-HP branch in its simplest form: the Who equation alone
already kills every finite Hermite--Pochhammer deformation.

### 4.3. The infinite pipeline: top-level overview

The infinite C-HP branch is different.  A finite polynomial cannot
hide an exponential survivor.  An entire function of finite
exponential type can.  The infinite pipeline therefore has to
separate four roles:

```text
sampled translation defect
  → global translation eigen-relation
  → log-derivative constancy
  → global exponential survivor
  → Where kills the survivor
  → Q ≡ 1
```

The top-level concrete theorem before the Jensen specialization is

```lean
where_rigidity_concrete_full
```

in
`GaussianWhoWhere/Infinite/WhereKillsExponentialFunctionLevelConcrete.lean`.
It consumes an abstract zero-density principle

```lean
ZeroDensityForcesZero DenseEnough
```

plus the concrete regularity and Bridge C input pack on `Q`, and
concludes

```lean
Q = fun _ : ℂ => 1
```

The final paper-level theorem is one specialization beyond that:

```lean
where_rigidity_of_oddLogSample_from_jensenCartwright
```

in `GaussianWhoWhere/Infinite/JensenFinalPipeline.lean`.  It supplies
the needed `ZeroDensityForcesZero` argument from the single socket
`JensenCartwrightLinearZeroBound` and the internalized odd-log
counting machinery.

The infinite C-HP proof can be drawn as the following dependency DAG:

```text
JensenCartwrightLinearZeroBound
  → zeroDensityForcesZero_for_oddLogSample
  → translation defects vanish globally
  → two real translation eigen-relations
  → periods of complexLogDeriv Q
  → real-axis constancy of complexLogDeriv Q
  → global constancy by analytic identity theorem
  → Q = exp(c z) by log-derivative reconstruction
  → c = 0 by function-level Where
  → Q ≡ 1
```

The theorem body of
`where_rigidity_of_oddLogSample_from_jensenCartwright` is correspondingly
short: it invokes `where_rigidity_concrete_full`, supplies
`zeroDensityForcesZero_for_oddLogSample hJC`, and passes the remaining
hypotheses through.  That is the Lean expression of the statement
"everything downstream of Jensen--Cartwright is already composed."

### 4.4. The log-derivative backbone

The infinite pipeline begins with a defect.  In
`GaussianWhoWhere/Infinite/TranslationDefect.lean` the definition is:

```lean
def translationDefect (Q : ℂ → ℂ) (a A : ℂ) : ℂ → ℂ :=
  fun z => Q (z + a) - A * Q z
```

The real-log specialization is

```lean
realLogShiftDefect
```

which uses the shift `t : ℝ` and the eigenvalue `Q (t : ℂ)`.
The closure lemma

```lean
finiteExpType_translationDefect
```

says that finite exponential type is preserved by the defect
construction.  This is why a zero-density principle can be applied to
the defect rather than directly to `Q`.

The sampled Who side is packaged by `SampledWhoInput` and then by

```lean
TwoIncommensurableSampledWhoInputs
```

in `GaussianWhoWhere/Infinite/TwoShiftCoupler.lean`.  This structure
contains two sampled translation inputs and an incommensurability
witness.  In the final theorem the two complex shifts are identified
with real numbers `a` and `b` by the hypotheses

```lean
ha : I.inputs.input₁.a = (a : ℂ)
hb : I.inputs.input₂.a = (b : ℂ)
```

and the density of their integer span is supplied by

```lean
hirr : Irrational (a / b)
```

through the Kronecker pipeline.

Once sampled defect-vanishing is upgraded to global defect-vanishing,
the coupler obtains real translation eigen-relations.  The passage
from defect to eigen-relation is made explicit in
`GaussianWhoWhere/Infinite/TranslationDefectToEigenCoupler.lean`.

The logarithmic derivative used by the pipeline is

```lean
def complexLogDeriv (Q : ℂ → ℂ) : ℂ → ℂ :=
  fun z => deriv Q z / Q z
```

from `GaussianWhoWhere/Infinite/LogDerivativeAlgebra.lean`.  If
`Q(z+a) = A Q(z)` and the derivative transforms by the same
eigenvalue, then the eigenvalue cancels in the quotient \(Q'/Q\).
The project records the connection to Mathlib's `logDeriv` by

```lean
complexLogDeriv_eq_logDeriv
```

in `GaussianWhoWhere/Infinite/TranslationEigenDeriv.lean`.

Two incommensurable real periods of `complexLogDeriv Q` force
real-axis constancy.  The topological half is in the dense-period
files, and the arithmetic-density conversion is in the Kronecker
files.  The composition used by the headline pipeline has increasingly
concrete forms, culminating in

```lean
complexLogDeriv_const_on_real_of_twoIncomm_sampled_differentiable
```

from `GaussianWhoWhere/Infinite/LogDerivativeContinuityHolomorphic.lean`.
This theorem uses differentiability and nonvanishing of `Q` to supply
the continuity of `complexLogDeriv Q` needed by the dense-period
argument.

Real-axis constancy is then promoted to global constancy in
`GaussianWhoWhere/Infinite/RealAxisConstToGlobalConcrete.lean`.
The key Mathlib theorem used there is the analytic identity theorem

```lean
AnalyticOnNhd.eqOn_of_preconnected_of_mem_closure
```

The project-level theorem

```lean
logDerivRealAxisConstExtendsGlobally_of_analyticOnNhd
```

turns the hypothesis

```lean
AnalyticOnNhd ℂ (complexLogDeriv Q) Set.univ
```

into the global extension predicate needed by the pipeline.

Finally, global constancy of `complexLogDeriv Q` is reconstructed into
an exponential survivor.  The concrete reconstruction is in
`GaussianWhoWhere/Infinite/GlobalLogDerivConstToExpConcrete.lean`.
It uses Mathlib's

```lean
logDeriv_eqOn_iff
```

and the normalization

```lean
Q 0 = 1
```

to obtain a survivor of the form

\[
  Q(z) = \exp(cz).
\]

This is the only possible survivor left by the two-shift
log-derivative argument.

### 4.5. Where kills the exponential survivor

The Where side of the C-HP branch is:

```lean
InfiniteWhere Q
```

which records the function-level reflection symmetry

\[
  Q(1-z) = Q(z).
\]

The project first isolated the exponent-level core.  In
`GaussianWhoWhere/Infinite/WhereKillsExponentialConcrete.lean`, the
definitions

```lean
ExponentReflection
ConcreteExponentialSurvivor
```

and the theorem

```lean
whereKillsExponentLevel
```

show that exponent reflection forces the exponential parameter to
vanish.

The function-level lift is then internalized in
`GaussianWhoWhere/Infinite/WhereKillsExponentialFunctionLevelConcrete.lean`.
The key theorem is

```lean
functionWhereForcesExponentReflection_concrete
```

It proves that if \(Q(z) = \exp(cz)\) and `InfiniteWhere Q` holds,
then the exponent-level reflection condition follows.  The proof
differentiates

\[
  \exp(c(1-z)) = \exp(cz)
\]

at \(z = 0\).  Evaluation at \(z = 0\) gives \(\exp(c)=1\), and the
derivative comparison gives \(-c\exp(c)=c\), hence \(c=0\).  This is
the point where the branch uses Where not merely as a slogan but as
an algebraic eliminator of the exponential survivor.

The final concrete coupler is:

```lean
where_rigidity_concrete_full
```

Its important feature is that it no longer asks for an abstract
`WhereKillsExponential Q` interface or a
`FunctionWhereForcesExponentReflection Q` hypothesis.  The
function-level Where lift has been internalized.  The theorem accepts
`InfiniteWhere Q` directly.

### 4.6. The Jensen--Cartwright socket

The remaining analytic input is zero-density.  The final socket is
defined in `GaussianWhoWhere/Infinite/JensenCartwrightInterface.lean`:

```lean
def JensenCartwrightLinearZeroBound : Prop :=
  FiniteExpTypeLinearZeroBound
```

This is not an axiom.  It is a named proposition.  The file does not
prove it.  It gives the proposition a descriptive name and connects
it to the already-built zero-density and log-sample machinery.

The underlying refined socket is

```lean
FiniteExpTypeLinearZeroBound
```

from `GaussianWhoWhere/Infinite/ZeroDensityForcesZeroRefined.lean`.
It states, in nonzero form, that if `F : ℂ → ℂ` is of finite
exponential type and is not identically zero, then the real zeros of
`F` in `[0,R]` admit a linear counting bound.  This is the classical
Jensen--Cartwright-style input:

```text
nonzero finite exponential type
  → at most linearly many real zeros
```

The lower-bound and contradiction side is internalized.  The odd-log
sample is handled in:

```text
GaussianWhoWhere/Infinite/LogSampleDensity.lean
GaussianWhoWhere/Infinite/LogSampleZeroContradiction.lean
GaussianWhoWhere/Infinite/OddLogLinearZeroBoundBeating.lean
```

The key point is that the project proves the sample-side theorem:
the odd-log sample beats any linear bound.  The growth lemma uses
Mathlib's

```lean
Real.isLittleO_log_id_atTop
```

and yields

```lean
oddLogLinearZeroBoundBeating
```

From there, the contradiction layer produces

```lean
zeroDensityForcesZero_for_oddLogSample
```

once `JensenCartwrightLinearZeroBound` is supplied.  The intended
picture is:

```text
JensenCartwrightLinearZeroBound
  → linear upper bound for zeros
  + odd-log sample beats every linear bound
  → ZeroDensityForcesZero for the odd-log sample
```

Thus the remaining analytic gap is exactly the classical upper-bound
theorem.  The counting collision, the odd-log beating lemma, and the
composition into `ZeroDensityForcesZero` are formalized downstream of
that socket.

### 4.7. The headline theorem

The final theorem of the C-HP branch is in
`GaussianWhoWhere/Infinite/JensenFinalPipeline.lean`:

```lean
theorem where_rigidity_of_oddLogSample_from_jensenCartwright
    (hJC : JensenCartwrightLinearZeroBound)
    {Q : ℂ → ℂ}
    (hQ : FiniteExpType Q)
    (hQdiff : Differentiable ℂ Q)
    (hQnz : ∀ z : ℂ, Q z ≠ 0)
    (hQ0 : Q 0 = 1)
    (hLog : AnalyticOnNhd ℂ (complexLogDeriv Q) Set.univ)
    (hWhere : InfiniteWhere Q)
    (I :
      TwoIncommensurableSampledWhoInputs Q
        (fun u : ℕ → ℂ =>
          Nonempty (LinearZeroBoundBeatingLogSample u)))
    {a b : ℝ}
    (ha : I.inputs.input₁.a = (a : ℂ))
    (hb : I.inputs.input₂.a = (b : ℂ))
    (hA : I.inputs.input₁.A ≠ 0) (hB : I.inputs.input₂.A ≠ 0)
    (hirr : Irrational (a / b)) :
    Q = fun _ : ℂ => 1
```

The hypothesis list is intentionally readable as a dependency
profile.

There is one named analytic socket:

```lean
hJC : JensenCartwrightLinearZeroBound
```

There are five regularity and normalization hypotheses on `Q`:

```lean
FiniteExpType Q
Differentiable ℂ Q
∀ z : ℂ, Q z ≠ 0
Q 0 = 1
AnalyticOnNhd ℂ (complexLogDeriv Q) Set.univ
```

There is one Where hypothesis:

```lean
InfiniteWhere Q
```

There is one data-bearing Who bundle:

```lean
TwoIncommensurableSampledWhoInputs Q
  (fun u : ℕ → ℂ =>
    Nonempty (LinearZeroBoundBeatingLogSample u))
```

and five accompanying pieces of Who-data:

```lean
ha : I.inputs.input₁.a = (a : ℂ)
hb : I.inputs.input₂.a = (b : ℂ)
hA : I.inputs.input₁.A ≠ 0
hB : I.inputs.input₂.A ≠ 0
hirr : Irrational (a / b)
```

So the theorem has the following stratification:

```text
1 Jensen--Cartwright socket
5 regularity / normalization hypotheses on Q
1 function-level Where hypothesis
6 pieces of sampled Who data
```

The conclusion is the function equality \(Q \equiv 1\).

The theorem body is the best possible kind of proof-engineering
evidence: it is a direct composition of named earlier nodes.  In the
source file, the proof invokes `where_rigidity_concrete_full` and
supplies

```lean
zeroDensityForcesZero_for_oddLogSample hJC
```

as the zero-density input.  This is exactly the claim of the section:
once the Jensen--Cartwright socket is provided, the rest of the
rigidity pipeline is already closed in Lean.

### 4.8. Status of the analytic gap

The analytic gap in the C-HP branch is therefore not vague.  It is not
spread across the proof.  It is the single named proposition

```lean
JensenCartwrightLinearZeroBound
```

whose intended mathematical content is the standard linear real-zero
counting theorem for nonzero entire functions of finite exponential
type.

This socket is deliberately not internalized in the present
development.  Internalizing it would be a classical-analysis project:
one would have to supply a Jensen or Cartwright zero-counting theorem
in Mathlib style, connect it to the project predicate
`HasAtMostLinearRealZeros`, and then prove
`FiniteExpTypeLinearZeroBound`.  The current paper does not claim to
do that.

What the current Lean development does prove is the surrounding
composition:

```text
finite C-HP:
  finite_general_uniqueness
  closed, unconditional

infinite C-HP:
  JensenCartwrightLinearZeroBound
    → where_rigidity_of_oddLogSample_from_jensenCartwright
  all downstream steps closed
```

This is why the C-HP branch is useful for a paper about proof
architecture.  It is strong enough to contain a real rigidity theorem,
but disciplined enough to expose the one classical analytic socket
that remains outside the formalized development.  The result is a
Lean proof with a named exit, not a verbal claim with a hidden gap.

## 5. The C-ζ Instance: the Mathlib Zeta Scaffold

The C-HP branch of §4 is a rigidity theorem.  The C-zeta branch is
not.  Its purpose is to record that the same Bridge C architecture is
already visible in Mathlib's zeta infrastructure as a typed scaffold.
The branch registers an architectural fact: zeta is organized into
Dirichlet, Euler, logarithmic-derivative, and completed-Where layers
connected by named theorems and domains.  It does not prove any
zero-location statement about `riemannZeta`.

The Lean file for this branch is

```text
GaussianWhoWhere/ZetaBridge/Basic.lean
```

It is intentionally short.  The file does not connect zeta to the
Hermite--Pochhammer deformation factor \(Q\).  It does not discharge
`JensenCartwrightLinearZeroBound`.  It does not prove RH.  It gives
the zeta-side architecture a typed record and provides one concrete
Mathlib-backed witness: the Dirichlet-series side of Bridge A.

### 5.1. The `ZetaBridgeCProfile` structure

The zeta branch introduces four layer predicates in the namespace
`GaussianWhoWhere.ZetaBridge`:

```lean
BridgeA_DirichletLike
BridgeA_EulerProductLike
BridgeAprime_LogDerivLike
CompletedWhereLike
```

The first three have the same `Set.EqOn`-style shape.  For example:

```lean
def BridgeA_DirichletLike (F : ℂ → ℂ) : Prop :=
  ∃ (domain : Set ℂ) (model : ℂ → ℂ),
    domain.Nonempty ∧ Set.EqOn F model domain
```

`BridgeA_EulerProductLike F` has the same shape, with the intended
model read as an Euler product.  `BridgeAprime_LogDerivLike F L` also
has the same shape, but applies to the logarithmic-derivative
companion `L` rather than directly to `F`.  This uniform typing is
deliberate: the zeta branch records a family of model-agreement
claims on explicit domains, not a global equality asserted without
side conditions.

The fourth predicate is different:

```lean
def CompletedWhereLike (Λ : ℂ → ℂ) : Prop :=
  ∀ s : ℂ, Λ (1 - s) = Λ s
```

This is not a `True` placeholder and not an `EqOn` model witness.  It
is the completed-Where reflection condition itself.  In other words,
the three Who/A′ layers are typed as "there exists a model and a
domain on which the model agrees"; the Where layer is typed as the
reflection equation.

The profile structure packages these layers:

```lean
structure ZetaBridgeCProfile where
  zetaLike : ℂ → ℂ
  completedLike : ℂ → ℂ
  logDerivLike : ℂ → ℂ
  bridgeA_dirichlet : BridgeA_DirichletLike zetaLike
  bridgeA_euler : BridgeA_EulerProductLike zetaLike
  bridgeAprime : BridgeAprime_LogDerivLike zetaLike logDerivLike
  where_completed : CompletedWhereLike completedLike
```

The structure has three object fields and four layer fields.  The
object fields name the zeta-like function, its completed companion,
and a logarithmic-derivative-like companion.  The layer fields record
the four architectural exits.

The file also provides four projection theorems:

```lean
zetaBridgeCProfile_has_where
zetaBridgeCProfile_has_who_dirichlet
zetaBridgeCProfile_has_who_euler
zetaBridgeCProfile_has_logDeriv_bridge
```

These are not new mathematical content.  They are one-line
projections from the profile.  Their purpose is proof-engineering:
they make each layer of a `ZetaBridgeCProfile` separately addressable
by downstream code and by theorem-map documentation.

The `ZetaBridge.Basic` file does not itself construct a full
`ZetaBridgeCProfile` instance for `riemannZeta`; it provides the
Dirichlet-side concrete witness and leaves the Euler-product, A′
log-derivative, and bundled-profile layers to a separate package
directory `GaussianWhoWhere/LFunctionBridge/`.  That separation
is intentional: the predicates and the `ZetaBridgeCProfile`
structure live in `ZetaBridge.Basic`; concrete witnesses and the
full bundled instance live in `LFunctionBridge`.  The combined
result — described in §5.2 below — is a concrete fully-bound
`ZetaBridgeCProfile riemannZeta` instance with all four field
witnesses Mathlib-backed, not a hidden theorem.

### 5.2. The concrete Dirichlet-side witness

The concrete content of the zeta branch is the Dirichlet-series side.
The file defines the right half-plane

```lean
rightHalfPlane_gt_one : Set ℂ
```

as the domain

\[
  \{s : \mathbb C \mid 1 < \operatorname{Re}(s)\}.
\]

It also defines two Dirichlet-series models:

```lean
zetaDirichletModel
zetaDirichletModelNatAddOne
```

The first is the direct `n : ℕ` form

\[
  s \mapsto \sum_{n:\mathbb N}' \frac{1}{n^s},
\]

matching Mathlib's theorem

```lean
zeta_eq_tsum_one_div_nat_cpow
```

The second is the conventional positive-integer form

\[
  s \mapsto \sum_{n:\mathbb N}' \frac{1}{(n+1)^s},
\]

matching

```lean
zeta_eq_tsum_one_div_nat_add_one_cpow
```

The two concrete witnesses are:

```lean
riemannZeta_bridgeA_dirichlet :
  BridgeA_DirichletLike riemannZeta
```

and

```lean
riemannZeta_bridgeA_dirichlet_natAddOne :
  BridgeA_DirichletLike riemannZeta
```

There is also an application-flavored alias:

```lean
riemannZeta_has_dirichlet_bridge
```

Both witnesses are backed by existing Mathlib theorems.  In each
case, the proof supplies `rightHalfPlane_gt_one` as the domain,
supplies the corresponding model function, proves the domain is
nonempty by taking \(s=2\), and then uses the appropriate Mathlib
Dirichlet-series theorem to prove `Set.EqOn riemannZeta model
rightHalfPlane_gt_one`.

This is the precise sense in which the C-zeta branch is not merely a
string label.  Its Bridge A layer is tied to Mathlib content.

#### Euler-product and log-derivative concrete witnesses

The Euler-product and Bridge A′ log-derivative layers now also have
typed concrete witnesses, supplied by a separate package directory
`GaussianWhoWhere/LFunctionBridge/`.  These are Type-side
refinements of the existing `Prop`-side `ZetaBridge` scaffold; the
predicate definitions of `ZetaBridge.Basic` are unchanged.

The Euler-product side is supplied by

```lean
riemannZeta_eulerProductBridge :
  EulerProductBridge riemannZeta

riemannZeta_bridgeA_eulerProduct :
  BridgeA_EulerProductLike riemannZeta
```

backed by Mathlib's `riemannZeta_eulerProduct_tprod` on the right
half-plane `Re(s) > 1`.  The typed `EulerProductBridge riemannZeta`
carries the local-factor field
`zetaEulerLocalFactor : ℕ → ℂ → ℂ` (returning `(1 − n^(−s))⁻¹` for
prime `n` and `1` otherwise) and the product model
`zetaEulerProductModel = ∏' (p : Nat.Primes), (1 − p^(−s))⁻¹`.
The `eqOn` field is discharged directly by the Mathlib theorem; the
formal link between the documentation-flavored `localFactor` field
and the `Nat.Primes`-indexed `productModel` is deferred.

The Bridge A′ log-derivative side is supplied by

```lean
riemannZeta_logDerivativeBridge :
  LogDerivativeBridge riemannZeta zetaVonMangoldtModel

riemannZeta_bridgeAprime_logDerivative :
  BridgeAprime_LogDerivLike riemannZeta zetaVonMangoldtModel
```

backed by Mathlib's
`ArithmeticFunction.LSeries_vonMangoldt_eq_deriv_riemannZeta_div`,
pairing the von Mangoldt L-series
`zetaVonMangoldtModel = LSeries (Λ : ℂ → ...)` as the arithmetic
companion with the analytic log-derivative
`zetaLogDerivativeModel = s ↦ −ζ'(s)/ζ(s)` as the bridge's
`model` field on the right half-plane `Re(s) > 1`.

In summary, all three arithmetic-side layers of the C-ζ branch
(Dirichlet series, Euler product, log-derivative) are now
Mathlib-backed at the typed-bridge level.  The completed Where
layer retains its predicate-level reflection scaffold.  The
remaining unwitnessed content of the branch lives in two
explicitly named non-claims, analytic continuation beyond the
right half-plane and zero-location / RH, neither of which this
branch attempts to discharge.

### 5.3. What the scaffold asserts and does not assert

The C-zeta branch asserts an architectural correspondence:

```text
Dirichlet side       → Bridge A / Who-style model agreement
Euler side           → Bridge A / Who-style model agreement
log-derivative side  → Bridge A′ model agreement
completed reflection → Where-style symmetry
```

It also proves, concretely, that all four layers of this
architecture (Dirichlet, Euler product, log-derivative,
completed Where) apply to `riemannZeta` on the half-plane
\(1 < \operatorname{Re}(s)\), and bundles them into a single
concrete `ZetaBridgeCProfile` instance
`riemannZeta_zetaBridgeCProfile` (see §5.2).

It does **not** assert any of the following:

- it does not prove `RiemannHypothesis`;
- it does not prove any zero-location theorem for `riemannZeta`;
- it does not identify `riemannZeta` with the
  Hermite--Pochhammer deformation factor `Q`;
- it does not import or discharge the C-HP socket
  `JensenCartwrightLinearZeroBound`;
- it does not prove analytic continuation of `riemannZeta`
  beyond what Mathlib already provides;
- it does not claim Selberg-class content.

This negative list is part of the formal meaning of the branch.  The
C-zeta instance now packages four concrete Mathlib-backed witnesses
into the typed `ZetaBridgeCProfile` shape; it does not extend
Mathlib's underlying analytic content.  Its role in the paper is to connect
the observation of §2 to a Lean-level typed record.  It explains why
Bridge C is not an arbitrary name introduced for the
Hermite--Pochhammer proof: the same separation of arithmetic model,
completed reflection, and logarithmic-derivative bridge is already
visible in the zeta infrastructure.

The branch is therefore intentionally modest.  It contributes
architecture, not a new zeta theorem.  That modesty is what makes it
useful for the methodology of the paper: Bridge C is presented as a
reusable proof-engineering shape, not as a disguised route to RH.

## 6. The C-BSD Instance: Heterogeneous Who, Central Where

The BSD branch is the paper's third instantiation of Bridge C.  Unlike
the C-HP branch, it is not a rigidity theorem.  Unlike the C-zeta
branch, it is not a scaffold extracted from an existing Mathlib
function.  It is a typed dependency-DAG observer for the shape of BSD.

The main thesis of the branch is:

```text
BSD is represented as a Bridge C constraint node.
Heterogeneous Who-data meets central Taylor Where-data at a
compatibility node carrying two named sockets.
```

The source files for this section are:

```text
BSDBridgeC/Basic.lean
BSDBridgeC/WhoWhere/Basic.lean
BSDBridgeC/Bridges/Basic.lean
BSDBridgeC/Profile/Basic.lean
BSDBridgeC/Socket/HigherRank.lean
BSDBridgeC/Specialization/RankOne.lean
BSDBridgeC/Freezing/Parity.lean
BSDBridgeC/Freezing/ProfileParity.lean
```

This branch does not prove BSD, Sha finiteness, modularity, the
Iwasawa main conjecture, Gross--Zagier, Kolyvagin, or higher Euler
system existence.  Its contribution is to name the dependency exits
and to make their structure inspectable in Lean.

### 6.1. The elliptic-curve profile

The basic object of the BSD branch is an abstract elliptic-curve-like
carrier:

```lean
structure EllipticCurveLike where
  name : Type
```

from `BSDBridgeC/Basic.lean`.  This is intentionally lightweight.
The current package does not formalize Weierstrass equations, Neron
models, schemes, modular forms, or actual elliptic curves over
\(\mathbb Q\).  It records the Bridge C shape around an abstract
elliptic-curve-like object.

The top-level profile is:

```lean
structure BSDBridgeCProfile where
  E : EllipticCurveLike
  who : BSDWhoData
  where_ : BSDWhereData
  bridgeC : BridgeC_Rigidity E who where_
  higherRankSocket :
    ∀ r : ℕ, 2 ≤ r → HigherRankSocket E r → HigherRankSocket E r
```

The first three conceptual roles are:

```text
Who          : BSDWhoData
Where        : BSDWhereData
compatibility: BSDWhoWhereCompatible who where_
```

In the implementation, the compatibility witness is carried inside
the `bridgeC` field:

```lean
BridgeC_Rigidity E who where_
```

whose `whoWhere` field has type

```lean
BSDWhoWhereCompatible who where_
```

The projection

```lean
bsdBridgeCProfile_has_whoWhere
```

extracts it from a profile.

The remaining fields of `BridgeC_Rigidity` expose the surrounding
bridge genealogy:

```lean
encode : BridgeA_Encode E where_
decode : BridgeB_Decode E who where_
logDeriv : BridgeAprime_LogDeriv where_
```

and the profile-level projections

```lean
bsdBridgeCProfile_has_encode
bsdBridgeCProfile_has_decode
bsdBridgeCProfile_has_logDeriv
```

return those layers.  These are field projections, not proofs of
modularity, Iwasawa theory, or logarithmic-derivative identities.

Finally, the `higherRankSocket` field of the profile is deliberately
a hypothesis-preserving map:

```lean
∀ r : ℕ, 2 ≤ r →
  HigherRankSocket E r → HigherRankSocket E r
```

The theorem

```lean
bsdBridgeCProfile_has_higherRankSocket_as_hypothesis
```

makes this explicit.  For rank \(r \ge 2\), the profile consumes a
`HigherRankSocket E r` as a hypothesis and returns it unchanged.  It
does not prove that such a socket is inhabited.

The profile also exposes a constraint triangle:

```lean
BSDConstraintTriangle
bsdBridgeCProfile_constraintTriangle
```

This packages the Who bundle, the Where bundle, and the compatibility
socket bundle at the profile level.  It is the Lean counterpart of the
constraint-satisfaction reading developed in
`docs/BSDSerializationEngine.md`.

### 6.2. Heterogeneous Who-data

The Who side of BSD is deliberately heterogeneous.  In
`BSDBridgeC/WhoWhere/Basic.lean`, the five basic data structures are:

```lean
TorsionData
ShaData
TamagawaData
RegulatorData
PeriodData
```

with the combined package:

```lean
structure BSDWhoData where
  torsion : TorsionData
  sha : ShaData
  tamagawa : TamagawaData
  regulator : RegulatorData
  period : PeriodData
```

The fields have different shapes:

```lean
structure TorsionData where
  order : ℕ

structure ShaData where
  order : ℕ

structure TamagawaData where
  factor : ℕ → ℕ

structure RegulatorData where
  value : ℝ

structure PeriodData where
  value : ℂ
```

This is not an accident.  The point of the BSD branch is precisely
that the Who side is not a homogeneous input vector.  It mixes finite
discrete data, an abstract Sha component, local Tamagawa factors,
real regulator data, and period data.  The package does not pretend
these have the same computational or mathematical status.

The file exposes each field by projection:

```lean
bsdWhoData_has_torsion
bsdWhoData_has_sha
bsdWhoData_has_tamagawa
bsdWhoData_has_regulator
bsdWhoData_has_period
```

and then packages them in a Type-side bundle:

```lean
structure BSDWhoHeterogeneousBundle (_W : BSDWhoData) where
  torsion_present : TorsionData
  sha_present : ShaData
  tamagawa_present : TamagawaData
  regulator_present : RegulatorData
  period_present : PeriodData
```

The constructor

```lean
bsdWhoData_to_heterogeneousBundle
```

forwards the five fields.  It adds no arithmetic theorem.  Its role is
to make the heterogeneity of the Who side a first-class typed object.

This design also avoids two opposite mistakes.  It does not collapse
the five invariants into a single artificial scalar.  It also does not
declare all five components equally mysterious.  Later leaf
localization and closeability audits refine which parts are closed,
known-but-uninternalized, structurally closeable, or genuinely open.

### 6.3. Central Taylor Where-data

The Where side is centered at \(s=1\).  The central Taylor package is:

```lean
structure CentralTaylorData where
  order : ℕ
  leadingCoeff : ℂ
```

and the full Where data is:

```lean
structure BSDWhereData where
  L : ℂ → ℂ
  rootNumber : ℂ
  centralTaylor : CentralTaylorData
  functionalEquationAtCenter : Prop
```

The center itself is named:

```lean
def bsdCenter : ℂ := 1
```

The projections

```lean
centralTaylor_order
centralTaylor_leadingCoeff
bsdWhereData_has_L
bsdWhereData_has_rootNumber
bsdWhereData_has_centralTaylor
bsdWhereData_has_functionalEquationSocket
```

expose these fields.  The last projection is especially important:
`functionalEquationAtCenter` is a `Prop` field.  The Where package
names a functional-equation socket; it does not prove analytic
continuation or the functional equation of an actual \(L\)-function.

The Type-side bundle is:

```lean
structure BSDWhereCentralBundle (_W : BSDWhereData) where
  L_present : ℂ → ℂ
  center_present : ℂ
  rootNumber_present : ℂ
  taylorOrder_present : ℕ
  leadingCoeff_present : ℂ
  functionalEquation_socket : Prop
```

and the forgetful constructor is:

```lean
bsdWhereData_to_centralBundle
```

As on the Who side, this is a naming operation.  It records that the
central Where layer consists of an \(L\)-function-like object, the
center \(1\), a root number, Taylor order and leading coefficient, and
a functional-equation socket.

### 6.4. The compatibility node

The central Bridge C compatibility node is:

```lean
structure BSDWhoWhereCompatible
    (who : BSDWhoData) (where_ : BSDWhereData) where
  leadingCoefficientFormula : Prop
  rankOrderCompatibility : Prop
```

This is the BSD-shaped point where heterogeneous Who-data and central
Taylor Where-data meet.  It has exactly two named sockets:

```text
leadingCoefficientFormula : Prop
rankOrderCompatibility    : Prop
```

The projections are:

```lean
bsdWhoWhereCompatible_has_leadingCoefficientFormula
bsdWhoWhereCompatible_has_rankOrderCompatibility
```

and the Type-side bundle is:

```lean
BSDCompatibilitySocketBundle
bsdWhoWhereCompatible_to_socketBundle
```

The flat pair projection

```lean
bsdWhoWhereCompatible_socketPair
```

is also available for downstream use.

The key methodological point is that the compatibility node is a
constraint, not a function.  It is not a serialization engine that
computes a single scalar from five heterogeneous inputs.  It is a
typed node whose two sockets say what must be supplied to identify
central Taylor behavior with arithmetic data.  This is the BSD
instance of the Bridge C discipline: the coupler exposes exits instead
of hiding them inside an informal phrase such as "the BSD formula."

The surrounding bridge genealogy in `BSDBridgeC/Bridges/Basic.lean`
names additional sockets:

```lean
BridgeA_Encode
BridgeAprime_LogDeriv
BridgeB_Decode
BridgeC_Rigidity
```

`BridgeA_Encode` contains a `ModularitySocket E`, an Euler-product
model socket, and a Dirichlet-model socket.  `BridgeAprime_LogDeriv`
contains logarithmic-derivative and pole/residue sockets.
`BridgeB_Decode` contains an `IwasawaMainSocket E`, a
Taylor-to-arithmetic socket, and a normalization-compatibility socket.
These are not proved in the BSD scaffold.  They are named exits.

### 6.5. Higher-rank socket genealogy

The higher-rank part is where the BSD branch most clearly becomes a
recursive socket genealogy.  The V2 visible socket is:

```lean
def HigherRankSocket (E : EllipticCurveLike) (r : ℕ) : Prop :=
  Nonempty (HigherRankArithmeticBridge E r)
```

where

```lean
structure HigherRankArithmeticBridge (E : EllipticCurveLike) (r : ℕ) where
  ES : HigherEulerSystem (TateModule E) r
  KS : HigherKolyvaginSystem (TateModule E) r
  D : HigherKolyvaginDerivative ES KS
  regulator_compatibility : Prop
  selmer_control : Prop
  core_rank_matches_bsd_rank : Prop
```

The first three fields are data-bearing socket structures:

```lean
HigherEulerSystem
HigherKolyvaginSystem
HigherKolyvaginDerivative
```

Their internal sockets are also named:

```lean
higherEulerSystem_normCompatibility
higherKolyvaginSystem_localRelations
higherKolyvaginDerivative_law
```

The remaining V2 fields are bare `Prop` sockets:

```lean
higherRankBridge_has_regulatorCompatibility
higherRankBridge_has_selmerControl
higherRankBridge_has_coreRankMatchesBSDRank
```

The Type-side bundle

```lean
HigherRankSocketBundle
```

collects the six components of a `HigherRankArithmeticBridge`.

V3 refines the bare compatibility fields into named structures:

```lean
RegulatorCompatibility
SelmerControl
CoreRankBSDRankCompatibility
```

and packages the refined object as:

```lean
structure HigherRankSocketStructure (E : EllipticCurveLike) (r : ℕ) where
  ES : HigherEulerSystem (TateModule E) r
  KS : HigherKolyvaginSystem (TateModule E) r
  D : HigherKolyvaginDerivative ES KS
  regulatorCompat : RegulatorCompatibility E r ES
  selmerControl : SelmerControl E r KS
  rankCompat : CoreRankBSDRankCompatibility E r
```

with visible socket:

```lean
def HigherRankSocketV3 (E : EllipticCurveLike) (r : ℕ) : Prop :=
  Nonempty (HigherRankSocketStructure E r)
```

The V3-to-V2 direction is implemented:

```lean
higherRankSocketStructure_to_arithmeticBridge
higherRankSocket_of_v3
```

This migration is deliberately one-way.  A V3 structure can forget its
named sub-sockets to the V2 shape.  A V2 witness cannot reconstruct
the V3 structure without additional typed information.  This is not a
defect; it is a useful honesty property.  The type system records that
V3 carries strictly more dependency information than V2.

The Sha side is similarly refined in `BSDBridgeC/WhoWhere/Basic.lean`.
V3 introduces abstract carriers:

```lean
MordellWeilLike
SelmerGroupLike
ShaTorsionLike
```

and the exact-sequence package:

```lean
structure SelmerShaExactPackage (E : EllipticCurveLike) (n : ℕ) where
  mordellWeilMod : MordellWeilLike E
  selmer : SelmerGroupLike E n
  shaTorsion : ShaTorsionLike E n
  injection_socket : Prop
  surjection_socket : Prop
  exactness_socket : Prop
```

The refined Sha data is:

```lean
structure ShaDataV3 (E : EllipticCurveLike) where
  shaCarrier : Type
  torsionAt : ∀ n : ℕ, ShaTorsionLike E n
  selmerShaPackage : ∀ n : ℕ, SelmerShaExactPackage E n
  finiteSocket : Prop
```

and the order-bearing version

```lean
ShaDataWithOrderV3
```

forgets to the V2 `ShaData` through

```lean
shaData_of_v3
```

Again, the direction is one-way.  The refined V3 package contains
more information than the V2 `order : ℕ` shape.  The reverse direction
is not derivable and is not claimed.

For rank \(r \ge 2\), none of these structures is inhabited by the
scaffold.  The profile field
`bsdBridgeCProfile_has_higherRankSocket_as_hypothesis` records the
policy precisely: higher-rank sockets are consumed as structured
hypotheses and never discharged.

### 6.6. Rank-one closure via Heegner witnesses

Rank one is treated differently.  The file
`BSDBridgeC/Specialization/RankOne.lean` introduces:

```lean
structure RankOneHeegnerWitness (E : EllipticCurveLike) where
  ES : HigherEulerSystem (TateModule E) 1
  KS : HigherKolyvaginSystem (TateModule E) 1
  D : HigherKolyvaginDerivative ES KS
  regulator_compatibility : Prop
  selmer_control : Prop
  core_rank_matches_bsd_rank : Prop
```

Given such a witness, the rank-one arithmetic bridge is obtained by:

```lean
rankOneArithmeticBridge_of_heegnerWitness
```

and the visible rank-one socket is inhabited by:

```lean
higherRankSocket_rankOne_of_heegnerWitness
```

There is also a profile-level alias:

```lean
rankOneProfileSocket_of_heegnerWitness
```

This is a closure theorem conditional on data.  It does not prove
Gross--Zagier or Kolyvagin.  It says: if a rank-one Heegner/Kolyvagin
witness is supplied, then the rank-one instance of the higher-rank
socket is inhabited.

The V3 rank-one witness mirrors the V3 higher-rank structure:

```lean
RankOneHeegnerWitnessV3
rankOneHeegnerWitnessV3_to_higherRankSocketStructure
higherRankSocketV3_rankOne_of_heegnerWitnessV3
higherRankSocket_rankOne_of_heegnerWitnessV3
```

The V3 witness forgets to the V2 witness through:

```lean
rankOneHeegnerWitness_of_v3
```

and again the reverse direction is not implemented.  The asymmetry is
the same as in §6.5: V3 records more typed structure than V2.

Thus rank one is a small closed DAG once a witness is provided, while
rank \(r \ge 2\) remains an open structured hypothesis.  This
distinction is essential for the paper's later leaf-localization
story: not every open-looking part has the same status.

### 6.7. Parity freezing

The BSD branch also contains a small closed algebraic theorem,
parallel in spirit to the C-freezing observation of the HP/zeta side.
In `BSDBridgeC/Freezing/Parity.lean`, the local functional-equation
predicate is:

```lean
def RootNumberFunctionalEquation (L : ℂ → ℂ) (w : ℂ) : Prop :=
  ∀ t : ℂ, L (1 + t) = w * L (1 - t)
```

The algebraic theorem is:

```lean
bsd_where_rootNumber_forces_centralZero
```

If the root number is `-1`, then evaluating the functional equation
at `t = 0` gives \(L(1) = -L(1)\), hence \(L(1)=0\).  The application
alias is:

```lean
bsd_where_sign_neg_one_forces_vanishing
```

The Where-data wrapper is:

```lean
def BSDWhereHasNegativeRootFunctionalEquation
    (W : BSDWhereData) : Prop :=
  W.rootNumber = -1 ∧ RootNumberFunctionalEquation W.L (-1)
```

The two conjuncts matter.  The hypothesis includes both the statement
that the declared root number is `-1` and the functional equation
itself.  The scaffold does not prove either conjunct.  Once they are
supplied, the theorem

```lean
bsdWhereData_centralZero_of_negativeRootFunctionalEquation
```

concludes:

```lean
W.L 1 = 0
```

The profile-level lift lives in
`BSDBridgeC/Freezing/ProfileParity.lean`:

```lean
BSDBridgeCProfileHasNegativeRootFunctionalEquation
bsdBridgeCProfile_centralZero_of_negativeRootFunctionalEquation
```

This lift exists in a separate file to avoid a circular import between
`Profile.Basic` and `Freezing.Parity`.  It adds no mathematical
content; it forwards the `where_` field of a `BSDBridgeCProfile`.

The parity-freezing result is intentionally narrow.  It is not a
proof of the parity conjecture, not a proof of BSD, and not a theorem
about modular forms.  It is the algebraic root-number consequence
inside the BSD Where layer.  Its presence is useful because it shows
that the BSD branch is not merely a list of open sockets: some
small local consequences of Where are already closed, while the large
compatibility and higher-rank sockets remain explicitly open.

## 7. Recursive Leaf Localization

The previous section described the BSD branch as a typed dependency
DAG.  This section explains the paper's central new methodological
contribution: **recursive leaf localization**.

The slogan is:

```text
Open mathematics is a finite list of labeled leaves.
```

This does not mean that the open leaves have been proved.  It means
that the development has refined the surrounding structure far enough
that the remaining open content is no longer an undifferentiated
cloud.  It is recorded as named leaves of a typed dependency DAG.

The main Lean file is:

```text
BSDBridgeC/Profile/LeafLocalization.lean
```

The section follows that file closely.  The profile definitions are
introduced in the same order as the implementation:

```lean
bsd_leafLocalizationProfile
bsd_refinedShaLeafLocalizationProfile
bsd_refinedShaAndCompatibilityLeafLocalizationProfile
bsd_fullyRefinedLeafLocalizationProfile
```

The first profile is coarse.  The later profiles refine selected open
leaves into named sub-leaves.  The closed-leaf count remains invariant
at four.  The open-leaf count grows from \(2\) to \(5\), then to \(7\),
then to \(12\).  This growth measures **granularity**, not
difficulty.

### 7.1. Structure refinement as DAG refinement

At the root of the BSD branch sits:

```lean
BSDBridgeCProfile
```

It contains an elliptic-curve-like object, Who-data, Where-data, a
Bridge C rigidity package, and a higher-rank socket policy.  Each of
these fields points to another structure or proposition.  Expanding
those fields produces a dependency DAG.

The organizing convention is:

```text
node = a structure or named predicate
edge = a structure field or hypothesis dependency
leaf = a field whose type is not further decomposed at the present level
```

For example, `BSDBridgeCProfile.bridgeC` points to
`BridgeC_Rigidity`; `BridgeC_Rigidity.whoWhere` points to
`BSDWhoWhereCompatible`; `BSDWhoWhereCompatible` contains two `Prop`
fields.  If the development stops there, those two fields are leaves.
If the development replaces one of them by a richer structure, the
DAG has been refined and the leaf has been expanded into a subtree.

This is what V3 does for higher-rank input and Sha.  It does not
change the informal BSD question.  It deepens the typed decomposition
around the question.

### 7.2. Fields as dependency edges

In an interactive theorem prover, a structure field is not merely a
piece of prose.  It is a typed dependency.  If a theorem asks for a
structure, every field of that structure is an obligation.  If a
field is itself a structure, its fields are further obligations.

This is why the BSD scaffold is not just a list of labels.  A field
such as

```lean
leadingCoefficientFormula : Prop
```

inside `BSDWhoWhereCompatible` is a visible exit.  A field such as

```lean
finiteSocket : Prop
```

inside `ShaDataV3` is also a visible exit.  A field such as

```lean
regulatorCompat : RegulatorCompatibility E r ES
```

inside `HigherRankSocketStructure` is a dependency edge to a named
sub-socket structure rather than to an anonymous bare proposition.

Thus refinement is DAG refinement.  Replacing a bare `Prop` by a
structure with named fields does not solve the proposition.  It
records more accurately what a future proof would have to provide.

### 7.3. Leaves as bottom nodes

The file `LeafLocalization.lean` introduces:

```lean
inductive LeafStatus where
  | closed
  | «open»
```

and:

```lean
structure RefinementLeaf where
  name : String
  status : LeafStatus
  description : String
```

It also defines two predicates:

```lean
RefinementLeaf.IsClosed
RefinementLeaf.IsOpen
```

A `RefinementLeaf` is a bottom node in the current refinement DAG.
The phrase "current" matters.  A leaf may later be refined.  When
that happens, the old coarse profile is preserved for backward
compatibility, and a new refined profile is added.

At the first coarse BSD level, the closed leaves are:

```lean
torsion_closed_leaf
tamagawa_closed_leaf
regulator_closed_leaf
period_closed_leaf
```

The coarse open leaves are:

```lean
sha_finiteness_open_leaf
higher_euler_system_open_leaf
```

The corresponding profile is:

```lean
bsd_leafLocalizationProfile
```

It contains six leaves:

```text
4 closed leaves:
  torsion, tamagawa, regulator, period

2 open leaves:
  Sha finiteness
  higher Euler systems r >= 2
```

The theorem

```lean
bsd_leafLocalizationProfile_openCount
```

proves that the open count is `2`, and

```lean
bsd_leafLocalizationProfile_closedCount
```

proves that the closed count is `4`.

### 7.4. Closed leaves versus open leaves

The classification is intentionally modest.  A closed leaf means:

```text
not part of the residual BSD-conjecture socket
```

It does **not** mean that the exact object is fully formalized in
Mathlib in the current package.  For example, torsion, Tamagawa
factors, regulator data, and period data are classified as closed at
this scaffold level because they are not where the residual BSD
openness is being localized.  They may still require engineering if
one replaces the abstract `EllipticCurveLike` scaffold by concrete
arithmetic geometry.

An open leaf means:

```text
the present scaffold has reached a named socket that is not discharged
```

The file contains basic witness theorems:

```lean
sha_finiteness_leaf_is_open
higher_euler_system_leaf_is_open
torsion_leaf_is_closed
```

Later refined leaves have similar openness theorems.  For example:

```lean
sha_finiteSocket_leaf_is_open
sha_selmer_injection_leaf_is_open
sha_selmer_surjection_leaf_is_open
sha_selmer_exactness_leaf_is_open
```

and:

```lean
higherEuler_normCompatibility_leaf_is_open
higherKolyvagin_localRelations_leaf_is_open
higherKolyvagin_derivativeLaw_leaf_is_open
higherRank_regulatorCompatibility_leaf_is_open
higherRank_selmerControl_leaf_is_open
higherRank_analyticRankCompatibility_leaf_is_open
```

These theorems close by simplification because the leaf definitions
carry their statuses explicitly.  The point is not mathematical
depth; the point is registry discipline.  The status of each leaf is
machine-checkable rather than left to prose.

### 7.5. V3 Sha decomposition: a worked example

The Sha leaf is the best example of recursive refinement.  In the
coarse profile, Sha appears as a single open leaf:

```lean
sha_finiteness_open_leaf
```

This is useful but too coarse.  The V3 Who/Where layer introduces
the refined Sha structure:

```lean
ShaDataV3
SelmerShaExactPackage
```

The exact-sequence package has three named socket fields:

```lean
injection_socket : Prop
surjection_socket : Prop
exactness_socket : Prop
```

and `ShaDataV3` itself has:

```lean
finiteSocket : Prop
```

Consequently, `LeafLocalization.lean` refines the one coarse Sha leaf
into four named open sub-leaves:

```lean
sha_finiteSocket_open_leaf
sha_selmer_injection_open_leaf
sha_selmer_surjection_open_leaf
sha_selmer_exactness_open_leaf
```

The refined profile is:

```lean
bsd_refinedShaLeafLocalizationProfile
```

It contains the same four closed leaves as before, replaces the
coarse Sha leaf by the four Sha sub-leaves, and keeps the coarse
higher-rank open leaf.  Its counts are:

```lean
bsd_refinedShaLeafLocalizationProfile_openCount  : ... = 5
bsd_refinedShaLeafLocalizationProfile_closedCount : ... = 4
```

The old profile is preserved.  The old leaf
`sha_finiteness_open_leaf` is not deleted or silently reinterpreted.
Instead, the new profile records the refined view.  This is the key
recursive behavior:

```text
one open leaf
  → four named open sub-leaves
```

No open content is discharged by this refinement.  Rather, the open
content is localized more precisely.  This is why the Sha
decomposition is the "killer app" of the method: it shows how an
apparently single obstruction can split into separately named
sub-sockets:

```text
Sha finiteSocket
Selmer-Sha injection socket
Selmer-Sha surjection socket
Selmer-Sha exactness socket
```

Those sockets may later be audited separately.  Some may turn out to
be known-but-uninternalized or structurally closeable; others may
remain genuinely open.  The leaf-localization layer does not decide
that.  It makes the boundary visible enough for the later audit
layers to ask the question.

### 7.6. Compatibility-node leaves

The next refinement observes that the Bridge C compatibility node
itself contains open content.  Recall:

```lean
structure BSDWhoWhereCompatible
    (who : BSDWhoData) (where_ : BSDWhereData) where
  leadingCoefficientFormula : Prop
  rankOrderCompatibility : Prop
```

These two fields are added as leaves:

```lean
bsd_leadingCoefficientFormula_open_leaf
bsd_rankOrderCompatibility_open_leaf
```

with openness theorems:

```lean
bsd_leadingCoefficientFormula_leaf_is_open
bsd_rankOrderCompatibility_leaf_is_open
```

The resulting profile is:

```lean
bsd_refinedShaAndCompatibilityLeafLocalizationProfile
```

It has:

```text
4 closed leaves
7 open leaves
```

The open leaves are:

```text
4 Sha sub-leaves
2 compatibility-node leaves
1 coarse higher-rank leaf
```

The corresponding count theorems are:

```lean
bsd_refinedShaAndCompatibilityLeafLocalizationProfile_openCount
bsd_refinedShaAndCompatibilityLeafLocalizationProfile_closedCount
```

This step is important because it prevents the central compatibility
node from remaining an opaque label.  The statement "BSD formula" is
split into at least two typed exits: the leading-coefficient formula
and the rank/order compatibility.

### 7.7. The refinement chain

The final refinement in `LeafLocalization.lean` replaces the coarse
higher-rank leaf by six named sub-leaves drawn from the V3
higher-rank structures.  The new leaves are:

```lean
higherEuler_normCompatibility_open_leaf
higherKolyvagin_localRelations_open_leaf
higherKolyvagin_derivativeLaw_open_leaf
higherRank_regulatorCompatibility_open_leaf
higherRank_selmerControl_open_leaf
higherRank_analyticRankCompatibility_open_leaf
```

They correspond respectively to:

```text
HigherEulerSystem.norm_compatibility
HigherKolyvaginSystem.local_relations
HigherKolyvaginDerivative.derivative_law
RegulatorCompatibility.compatibility_law
SelmerControl.control_law
CoreRankBSDRankCompatibility.analytic_matches_algebraic
```

The fully refined profile is:

```lean
bsd_fullyRefinedLeafLocalizationProfile
```

It has four closed leaves and twelve open leaves:

```lean
bsd_fullyRefinedLeafLocalizationProfile_closedCount : ... = 4
bsd_fullyRefinedLeafLocalizationProfile_openCount   : ... = 12
```

The four profiles form the following refinement chain:

| Profile | Closed count | Open count | Interpretation |
| --- | ---: | ---: | --- |
| `bsd_leafLocalizationProfile` | 4 | 2 | coarse Sha + coarse higher-rank |
| `bsd_refinedShaLeafLocalizationProfile` | 4 | 5 | Sha split into four sub-leaves |
| `bsd_refinedShaAndCompatibilityLeafLocalizationProfile` | 4 | 7 | compatibility node split into two leaves |
| `bsd_fullyRefinedLeafLocalizationProfile` | 4 | 12 | higher-rank leaf split into six sub-leaves |

The count theorems are:

```lean
bsd_leafLocalizationProfile_openCount
bsd_refinedShaLeafLocalizationProfile_openCount
bsd_refinedShaAndCompatibilityLeafLocalizationProfile_openCount
bsd_fullyRefinedLeafLocalizationProfile_openCount

bsd_leafLocalizationProfile_closedCount
bsd_refinedShaLeafLocalizationProfile_closedCount
bsd_refinedShaAndCompatibilityLeafLocalizationProfile_closedCount
bsd_fullyRefinedLeafLocalizationProfile_closedCount
```

and the concrete monotone open-count chain is:

```lean
bsd_leafLocalization_openCount_chain
```

This theorem records:

```text
2 ≤ 5 ≤ 7 ≤ 12
```

It is not a general theorem about every possible future refinement.
It is a theorem about the four profiles currently registered in the
Lean file.

The closed-leaf count stays fixed:

```text
4 = torsion, tamagawa, regulator, period
```

The open-leaf count grows because the representation becomes more
granular.  That is the crucial interpretive point:

```text
openCount measures resolution, not difficulty.
```

A larger open count does not mean that the theorem has become harder.
It means the scaffold has stopped treating a large obstruction as a
single blur.

### 7.8. The methodological claim

Recursive leaf localization changes the form of an open mathematical
problem.  It does not solve BSD.  It does not prove Sha finiteness,
the leading coefficient formula, rank equality, higher Euler system
existence, or Kolyvagin-system compatibility.  It proves a different
kind of statement: the remaining openness has been localized to named
leaves of a typed dependency DAG.

The contribution can be stated as:

```text
The contribution is not to remove the open leaves,
but to prove that the remaining openness has been localized
to named leaves of the typed dependency DAG.
```

This statement is backed by Lean objects.  The leaves are data:

```lean
RefinementLeaf
LeafLocalizationProfile
```

The statuses are data:

```lean
LeafStatus.closed
LeafStatus.«open»
```

The profile chain is data:

```lean
bsd_leafLocalizationProfile
bsd_refinedShaLeafLocalizationProfile
bsd_refinedShaAndCompatibilityLeafLocalizationProfile
bsd_fullyRefinedLeafLocalizationProfile
```

The counts are theorems:

```lean
openCount  : 2, 5, 7, 12
closedCount: 4, 4, 4, 4
```

Thus "BSD is unsolved" is replaced, at the scaffold level, by a finite
registry of named leaves.  The next sections refine this registry
further: V4 turns leaves into typed identifiers, and the audit layers
distinguish genuinely open mathematical content from content that is
known-but-uninternalized, structurally closeable, technically hard, or
blocked by the current model.

## 8. Four Orthogonal Observation Axes

Leaf localization identifies open leaves.  That is not yet enough.
An open leaf may be open for different reasons: it may be genuinely
mathematically open, known externally but not internalized, structurally
closeable, pending audit, or blocked by the present model.  Treating
all of these cases as the same kind of "open" would be another form
of overclaim.

The BSD scaffold therefore records four independent observation axes:

```text
where?          Leaf localization
what role?      Partial closure audit
un-audited?     Pending closure audit
why open?       Closeability audit
```

The key warning is that these axes are not partitions of one another.
The numbers

```text
12, (2,1,1,0), 10, (4,1,1,1,0)
```

measure different things.  The paper keeps them separate on purpose.

The relevant Lean files are:

```text
BSDBridgeC/Profile/LeafLocalization.lean
BSDBridgeC/Profile/PartialClosureAudit.lean
BSDBridgeC/Profile/CloseabilityAudit.lean
```

There is no separate `PendingClosureAudit.lean` file.  The pending
audit registry

```lean
bsd_pendingClosureAudit
```

is defined inside `BSDBridgeC/Profile/PartialClosureAudit.lean`.

### 8.1. Why four axes?

The four axes answer different questions.

The first axis asks:

```text
Where is the leaf in the dependency DAG?
```

This is the role of `LeafLocalization.lean`.  It classifies leaves
as `closed` or `«open»` and counts them in each registered profile.

The second axis asks:

```text
What role does this audited item currently play?
```

This is the role of `PartialClosureAudit.lean`.  It distinguishes
entries that are genuinely open, known externally but not
internalized, structural candidates, or already closed in the
scaffold.

The third axis asks:

```text
Which refined leaves have not been audited yet?
```

This is also recorded in `PartialClosureAudit.lean`, through the
string-level pending registry `bsd_pendingClosureAudit`.

The fourth axis asks:

```text
Why is this audited item not closed yet?
```

This is the role of `CloseabilityAudit.lean`.  It distinguishes
mathematically open content from work that is technically hard,
technically heavy, blocked by modeling, or immediately closeable.

These questions are orthogonal.  A leaf can be open in the
localization axis and be explained as mathematically open in the
closeability axis.  Another leaf can be open in localization but
technically heavy in closeability.  A thematic audit entry may cover
several typed leaves, or none of the twelve refined leaves directly.
That is why the counts cannot be collapsed into one table.

### 8.2. Axis 1: Leaf localization

Axis 1 is the binary leaf-status layer introduced in §7.  Its main
objects are:

```lean
LeafStatus
RefinementLeaf
LeafLocalizationProfile
```

The fully refined BSD profile is:

```lean
bsd_fullyRefinedLeafLocalizationProfile
```

and its counts are:

```lean
bsd_fullyRefinedLeafLocalizationProfile_openCount   : ... = 12
bsd_fullyRefinedLeafLocalizationProfile_closedCount : ... = 4
```

This axis answers only "where" and "open or closed at the present
localization level."  It does not explain why a leaf is open, whether
the leaf is known externally, or whether it is pending further audit.

The binary tag is therefore intentionally coarse:

```lean
LeafStatus.closed
LeafStatus.«open»
```

It is the starting point for the later axes, not their replacement.

### 8.3. Axis 2: Partial closure audit

Axis 2 is defined in `BSDBridgeC/Profile/PartialClosureAudit.lean`.
The status taxonomy is:

```lean
inductive ClosureAuditStatus where
  | closed
  | knownButUninternalized
  | structuralCandidate
  | «open»
```

An audit entry is:

```lean
structure ClosureAuditEntry where
  leafName : String
  status : ClosureAuditStatus
  reason : String
```

The current registry is:

```lean
bsd_partialClosureAudit
```

It contains four thematic entries:

```lean
selmerFinite_knownButUninternalized
mordellWeilToSelmerInjection_structuralCandidate
shaGlobalFiniteness_staysOpen
higherEulerSystems_stayOpen
```

The partition count theorem is:

```lean
bsd_partialClosureAudit_partition_counts
```

It records the tuple

```text
(2, 1, 1, 0)
```

across the statuses

```text
«open», knownButUninternalized, structuralCandidate, closed.
```

Concretely:

```lean
bsd_partialClosureAudit_openCount = 2
bsd_partialClosureAudit_knownButUninternalizedCount = 1
bsd_partialClosureAudit_structuralCandidateCount = 1
bsd_partialClosureAudit_closedCount = 0
```

This is not a count over all twelve refined open leaves.  It is a
partition of the four-entry thematic audit registry.  That distinction
is crucial.

### 8.4. Axis 3: Pending closure audit

Axis 3 records what the partial audit has not yet classified.  This
registry is in the same file as the partial audit:

```text
BSDBridgeC/Profile/PartialClosureAudit.lean
```

The pending-entry structure is:

```lean
structure PendingAuditEntry where
  leafName : String
  reason : String
```

and the registry is:

```lean
bsd_pendingClosureAudit : List PendingAuditEntry
```

It contains ten string-level pending entries:

```lean
selmerShaSurjection_pendingAudit
selmerShaExactness_pendingAudit
bsdLeadingCoefficientFormula_pendingAudit
bsdRankOrderCompatibility_pendingAudit
higherEulerNormCompatibility_pendingAudit
higherKolyvaginLocalRelations_pendingAudit
higherKolyvaginDerivativeLaw_pendingAudit
higherRankRegulatorCompatibility_pendingAudit
higherRankSelmerControl_pendingAudit
higherRankAnalyticRankCompatibility_pendingAudit
```

The count theorem is:

```lean
bsd_pendingClosureAudit_count :
  pendingAuditCount bsd_pendingClosureAudit = 10
```

and the non-exhaustivity theorem is:

```lean
bsd_partialAudit_is_not_exhaustive :
  pendingAuditCount bsd_pendingClosureAudit ≠ 0
```

This theorem is not a mathematical theorem about BSD.  It is a
registry theorem about the scaffold itself: the current partial audit
is explicitly non-exhaustive.  The file refuses to let the reader
infer that every refined leaf has already been audited.

There is also a V4 typed coverage layer in the same file:

```lean
AuditCoverage
bsd_auditCoverage
bsd_auditCoveredLeaves
bsd_pendingAuditLeafIds
```

This typed layer records that, relative to the explicit typed
coverage relation, eight typed open leaves are covered and four typed
open leaves are pending:

```lean
bsd_auditCoveredLeaves_count = 8
bsd_pendingAuditLeafIds_count = 4
bsd_typedCoverage_count_matches_openLeafCount
```

The string-level pending count `10` and the typed pending count `4`
are both correct because they measure different things.  The former
is conservative and does not assume an audit-to-leaf bijection.  The
latter is relative to the explicit `AuditCoverage` relation.  This is
one of the places where the paper's "not a partition" warning matters
most.

### 8.5. Axis 4: Closeability audit

Axis 4 is defined in `BSDBridgeC/Profile/CloseabilityAudit.lean`.
The status taxonomy is:

```lean
inductive CloseabilityStatus where
  | mathematicallyOpen
  | technicallyHard
  | technicallyHeavy
  | blockedByModeling
  | closeableNow
```

The statuses mean:

| Status | Meaning |
| --- | --- |
| `mathematicallyOpen` | genuinely unsolved at the mathematical frontier |
| `technicallyHard` | known mathematically, but a serious formalization project |
| `technicallyHeavy` | closeable in principle, mostly engineering / API work |
| `blockedByModeling` | the current abstraction is too coarse to decide closure |
| `closeableNow` | should be closed now; leaving it open is a reverse overclaim |

This axis answers "why is this not closed yet?" rather than "where is
the leaf?" or "has this leaf been audited?"  It is therefore
orthogonal to both localization and partial audit.

### 8.6. The current BSD closeability audit table

The closeability entries are:

```lean
shaGlobalFiniteness_mathematicallyOpen
higherEulerSystems_mathematicallyOpen
selmerFinite_technicallyHard
mordellWeilToSelmerInjection_technicallyHeavy
selmerShaExactness_blockedByModeling
bsdLeadingCoefficientFormula_mathematicallyOpen
bsdRankOrderCompatibility_mathematicallyOpen
```

They form the registry:

```lean
bsd_closeabilityAudit
```

Each entry carries a `reason : String`.  The reasons are not proofs;
they are audit explanations.  For example, global Sha finiteness is
classified as mathematically open because general Sha finiteness is a
BSD-frontier problem.  Finite-level Selmer finiteness is classified as
technically hard because it is known by descent and finite-Selmer
theory but not internalized in this scaffold.  The Mordell--Weil to
Selmer injection is technically heavy because it is structural once
the maps and quotient objects are modeled.  Selmer--Sha exactness is
blocked by modeling because the maps inside `SelmerShaExactPackage`
are still abstract.

The count theorem is:

```lean
bsd_closeabilityAudit_partition_counts
```

It records:

```text
(4, 1, 1, 1, 0)
```

across the five statuses:

```text
mathematicallyOpen,
technicallyHard,
technicallyHeavy,
blockedByModeling,
closeableNow.
```

The individual count theorems are:

```lean
bsd_closeabilityAudit_mathematicallyOpenCount
bsd_closeabilityAudit_technicallyHardCount
bsd_closeabilityAudit_technicallyHeavyCount
bsd_closeabilityAudit_blockedByModelingCount
bsd_closeabilityAudit_closeableNowCount
```

The closeability file also has a V4 typed coverage layer:

```lean
CloseabilityCoverage
bsd_closeabilityCoverage
bsd_closeabilityCoveredLeaves
```

Unlike the partial audit typed coverage, closeability coverage is
exhaustive over the twelve typed open leaves:

```lean
bsd_closeabilityCoverage_covers_openLeafIds
```

and the per-status typed-leaf counts are:

```text
(9, 0, 1, 2, 0)
```

That is a typed-leaf attribution count, not the same as the seven-entry
registry count `(4,1,1,1,0)`.

### 8.7. Independence of the axes

The four axes must not be conflated.

Axis 1 says:

```text
fully refined leaf localization:
  12 open leaves, 4 closed leaves
```

Axis 2 says:

```text
partial closure audit registry:
  (2,1,1,0) over four thematic audit entries
```

Axis 3 says:

```text
string-level pending audit registry:
  10 pending entries
```

Axis 4 says:

```text
closeability audit registry:
  (4,1,1,1,0) over seven closeability entries
```

These are independent observations.  The number `12` is a count of
typed open leaves in the fully refined localization profile.  The
tuple `(2,1,1,0)` is a partition of the four-entry partial audit
registry.  The number `10` is a conservative string-level pending
registry count.  The tuple `(4,1,1,1,0)` is a partition of the
seven-entry closeability registry.

A leaf can be open in Axis 1 and mathematically open in Axis 4.  A
different leaf can be open in Axis 1 and technically heavy in Axis 4.
An audit entry can cover several typed leaves.  Another audit entry
can cover none of the twelve refined leaves directly, as in the case
of finite-level Selmer finiteness.  This is why none of the four
counts should be read as a partition of any other.

V4 adds typed lookup functions that make this distinction queryable:

```lean
BSDLeafId.partialClosureAuditStatus
BSDLeafId.closeabilityStatus
```

The first is strict and partial: only the eight typed leaves covered
by `bsd_auditCoverage` receive a partial-audit status.  Pending and
closed leaves return `none`.  The second is total over open leaves:
every typed open leaf receives a closeability status, while closed
leaves return `none`.

This is the point where the scaffold becomes a queryable index rather
than only a prose classification.  A reader can choose a typed leaf
identifier and ask for its current status along two audit axes.

### 8.8. Registry hygiene as a Lean theorem

The final component of this section is registry hygiene.  The
`closeableNow` status is not a resting state.  It means:

```text
this entry should already be closed, or reclassified
```

Therefore a healthy closeability registry should contain no
`closeableNow` entries.  The predicate is:

```lean
def CloseabilityRegistryHygieneClean
    (entries : List CloseabilityAuditEntry) : Prop :=
  closeabilityCountBy CloseabilityStatus.isCloseableNow entries = 0
```

The current registry satisfies it:

```lean
theorem bsd_closeabilityAudit_hygieneClean :
    CloseabilityRegistryHygieneClean bsd_closeabilityAudit
```

and the zero-count alias is:

```lean
theorem bsd_closeabilityAudit_has_no_closeableNow :
    closeabilityCountBy CloseabilityStatus.isCloseableNow
      bsd_closeabilityAudit = 0
```

This is an important distinction.  The hygiene theorem is not a theorem
about elliptic curves.  It is a theorem about the registry.  It proves
that the current audit table does not quietly park closeable material
under an open-looking label.

The slogan is:

```text
Open is not a single color.
The scaffold is not allowed to park closeable material
under an open-looking label.
```

If a future entry is marked `closeableNow`, the hygiene theorem will
fail until the entry is closed or reclassified.  That feedback loop is
the operational force of this section.  The paper's honesty discipline
is not only editorial.  It is partly encoded as a Lean theorem about
the state of the registry.

## 9. Typed Query Index: the V4 Inversion

The previous two sections described the BSD scaffold as an observation
device.  It could list leaves, refine them, count them, audit them,
and classify why they remain open.  V4 changes the direction of use.
Instead of only reading from registries to leaves, a reader can now
start with a leaf and query its status.

The main thesis of this section is:

```text
V4 turns leaf identity into a typed value.
The scaffold transitions from observation device to queryable index.
```

The location of the relevant definitions is:

```text
BSDLeafId and partitions:
  BSDBridgeC/Profile/LeafLocalization.lean

partial audit coverage and lookup:
  BSDBridgeC/Profile/PartialClosureAudit.lean

closeability coverage and lookup:
  BSDBridgeC/Profile/CloseabilityAudit.lean
```

There is no separate `TypedLeafIdentifier.lean` file.  The typed
identifier `BSDLeafId` is declared inside
`Profile/LeafLocalization.lean`, layered non-destructively on top of
the earlier `RefinementLeaf` registry.

### 9.1. The methodological pivot

The V1--V3 picture is:

```text
registry → leaves
```

A profile contains leaves.  A leaf has a string name, a status, and a
description.  A count theorem reports how many open and closed leaves
the profile contains.

The V4 picture is:

```text
leaf → status
```

A leaf is now a value of an inductive type.  One can ask for its
binary status, human-readable label, partial-audit status, and
closeability status.  The inversion is not merely a refactor.  It
changes how the scaffold is used: a reader can query a specific leaf
identifier and obtain its current classification.

This is the difference between an observation table and an index.

### 9.2. The inductive type `BSDLeafId`

The typed identifier is:

```lean
inductive BSDLeafId where
  | torsion
  | tamagawa
  | regulator
  | period
  | shaFiniteSocket
  | shaSelmerInjection
  | shaSelmerSurjection
  | shaSelmerExactness
  | bsdLeadingCoefficientFormula
  | bsdRankOrderCompatibility
  | higherEulerNormCompatibility
  | higherKolyvaginLocalRelations
  | higherKolyvaginDerivativeLaw
  | higherRankRegulatorCompatibility
  | higherRankSelmerControl
  | higherRankAnalyticRankCompatibility
deriving DecidableEq, Repr
```

The first four constructors are the closed leaves:

```lean
torsion
tamagawa
regulator
period
```

The remaining twelve constructors are the fully refined open leaves:

```lean
shaFiniteSocket
shaSelmerInjection
shaSelmerSurjection
shaSelmerExactness
bsdLeadingCoefficientFormula
bsdRankOrderCompatibility
higherEulerNormCompatibility
higherKolyvaginLocalRelations
higherKolyvaginDerivativeLaw
higherRankRegulatorCompatibility
higherRankSelmerControl
higherRankAnalyticRankCompatibility
```

The `DecidableEq` instance is important.  It means that equality of
leaf identifiers is decidable by Lean.  This turns leaf identity from
a string convention into a typed, computable object.  The `Repr`
instance is useful for inspection and theorem-map output.

### 9.3. Status, label, and audit as computable functions

In `LeafLocalization.lean`, the typed leaf identifier has a status:

```lean
BSDLeafId.status : BSDLeafId → LeafStatus
```

a human-readable label:

```lean
BSDLeafId.label : BSDLeafId → String
```

and Boolean discriminators:

```lean
BSDLeafId.isOpen
BSDLeafId.isClosed
```

The status and label functions are total.  They are ordinary functions
out of the inductive type `BSDLeafId`.

V4 then adds two audit lookup functions in separate files.  The strict
partial-closure lookup is defined in `PartialClosureAudit.lean`:

```lean
BSDLeafId.partialClosureAuditStatus :
  BSDLeafId → Option ClosureAuditStatus
```

It returns `some` exactly for the eight typed leaves covered by
`bsd_auditCoverage`.  It returns `none` for the four pending typed
leaves and for the four closed leaves.  This strictness prevents the
partial audit from pretending to be exhaustive.

The closeability lookup is defined in `CloseabilityAudit.lean`:

```lean
BSDLeafId.closeabilityStatus :
  BSDLeafId → Option CloseabilityStatus
```

It is total over open leaves and undefined on closed leaves.  The
theorems

```lean
closeabilityStatus_some_of_openLeaf
closeabilityStatus_none_of_closedLeaf
```

record that behavior.

A reader can now query a leaf directly.  For example:

```lean
#check BSDLeafId.shaSelmerExactness.closeabilityStatus
```

This expression has type `Option CloseabilityStatus`.  Its value is
recorded definitionally by the witness theorem:

```text
some CloseabilityStatus.blockedByModeling
```

```lean
closeabilityStatus_selmerExactness :
  BSDLeafId.closeabilityStatus .shaSelmerExactness =
    some .blockedByModeling
```

This is the V4 inversion in miniature.  A named leaf is no longer
only a row in a registry.  It is a typed query key.

### 9.4. Partition counts closed by `rfl`

The typed partitions are declared in `LeafLocalization.lean`:

```lean
bsd_closedLeafIds : List BSDLeafId
bsd_openLeafIds : List BSDLeafId
bsd_fullyRefinedLeafIds : List BSDLeafId
```

They have lengths:

```lean
bsd_closedLeafIds_count : bsd_closedLeafIds.length = 4
bsd_openLeafIds_count : bsd_openLeafIds.length = 12
bsd_fullyRefinedLeafIds_count : bsd_fullyRefinedLeafIds.length = 16
```

These theorems close by `rfl`.  The lists are literal, and `List.length`
reduces definitionally.  This is the simplest possible form of
registry bookkeeping: the typed registry has four closed leaves,
twelve open leaves, and sixteen total leaves because the lists say so
definitionally.

V4 also provides a bridge back to the string registry:

```lean
BSDLeafId.toRefinementLeaf : BSDLeafId → RefinementLeaf
```

with consistency theorems:

```lean
BSDLeafId.toRefinementLeaf_status
BSDLeafId.toRefinementLeaf_label
BSDLeafId.toRefinementLeaf_closed_iff
BSDLeafId.toRefinementLeaf_open_iff
```

These theorems prevent drift between the typed registry and the
human-readable `RefinementLeaf` registry.  If a future edit changes a
label or status on one side without updating the other, the bridge
theorems will fail.

### 9.5. Audit coverage as a decidable relation

The typed audit coverage relation is in `PartialClosureAudit.lean`:

```lean
structure AuditCoverage where
  auditName : String
  covers : List BSDLeafId
```

The registry is:

```lean
bsd_auditCoverage : List AuditCoverage
```

It flattens to the typed covered-leaf list:

```lean
bsd_auditCoveredLeaves : List BSDLeafId
```

and the typed pending list:

```lean
bsd_pendingAuditLeafIds : List BSDLeafId
```

The count theorems are:

```lean
bsd_auditCoveredLeaves_count : ... = 8
bsd_pendingAuditLeafIds_count : ... = 4
bsd_typedCoverage_count_matches_openLeafCount
```

V4 then strengthens the count statement to membership-level
consistency.  The central theorems are:

```lean
bsd_typedCoverage_disjoint
bsd_auditCoveredLeaves_subset_open
bsd_pendingAuditLeafIds_subset_open
bsd_openLeafIds_covered_or_pending
bsd_typedCoverage_covers_openLeafIds
```

The proofs are by case analysis on `BSDLeafId` followed by `decide`.
Thus coverage and non-coverage are no longer prose claims.  They are
decidable facts over a finite inductive type.

The lookup function

```lean
BSDLeafId.partialClosureAuditStatus
```

is consistent with this coverage relation:

```lean
partialClosureAuditStatus_isSome_iff_covered
partialClosureAuditStatus_isNone_iff_uncovered
```

These theorems state that a typed leaf receives a partial-audit status
if and only if it lies in `bsd_auditCoveredLeaves`.  Pending leaves
therefore return `none` by construction.

### 9.6. Non-destructive overlay

V4 is layered on top of V3.  It does not delete or rewrite the
string-based leaves:

```lean
sha_finiteSocket_open_leaf
sha_selmer_injection_open_leaf
sha_selmer_surjection_open_leaf
sha_selmer_exactness_open_leaf
bsd_leadingCoefficientFormula_open_leaf
bsd_rankOrderCompatibility_open_leaf
higherEuler_normCompatibility_open_leaf
...
```

Those `RefinementLeaf` declarations remain in place.  The typed
identifier is an overlay:

```lean
BSDLeafId → RefinementLeaf
```

not a destructive replacement.

This is important for two reasons.  First, documentation and theorem
maps can continue to display readable names and descriptions from
`RefinementLeaf`.  Second, Lean can now use `BSDLeafId` for decidable
identity, membership, partition, and lookup theorems.  The two views
serve different purposes and are tied together by the
`toRefinementLeaf` bridge.

The migration direction is forgetful:

```text
typed leaf id → string-based registry cell
```

The reverse direction is not needed and is not implemented.  A
`RefinementLeaf` contains a string label and description; it is not a
canonical typed identifier.  V4 therefore does not pretend that any
string with the right spelling can be promoted into a `BSDLeafId`.

### 9.7. What this enables

V4 changes what the scaffold can do.

Before V4, the statement was:

```text
the registry contains named leaves
```

After V4, the statement is:

```text
leaves are values of a typed identifier
```

This enables:

- decidable equality of leaves;
- literal open/closed partitions with `rfl` count theorems;
- typed audit coverage by lists of `BSDLeafId`;
- membership-level consistency theorems closed by `decide`;
- leaf-indexed partial-audit lookup;
- leaf-indexed closeability lookup;
- a bridge back to the string registry with status and label
  consistency theorems.

The conceptual transition is:

```text
V3:
  leaves are named cells in a registry

V4:
  leaves are values of a typed identifier
```

This matters because the paper's goal is not only to display a
dependency DAG.  It is to make that DAG queryable.  A reviewer can ask
"what is the status of the Selmer--Sha exactness leaf?" and the
scaffold has a typed answer:

```lean
BSDLeafId.shaSelmerExactness.partialClosureAuditStatus
BSDLeafId.shaSelmerExactness.closeabilityStatus
BSDLeafId.shaSelmerExactness.toRefinementLeaf
```

The first query returns no partial-audit status, because the strict
partial audit does not cover that leaf.  The second returns
`some blockedByModeling`.  The third returns the corresponding
human-readable `RefinementLeaf`.  This is the practical content of
the V4 inversion: the open mathematical boundary has become a
typed, queryable index.

## 10. Metaphor Sharpening through Formalization

The preceding sections described a typed apparatus.  This section
records a smaller but important methodological lesson: formalization
can also detect when a natural informal metaphor is the wrong one.

The BSD branch began with a tempting software-engineering joke:
BSD looks like an engine that takes heterogeneous arithmetic data and
returns a single central Taylor coefficient.  The joke is useful
because it makes the shape memorable.  But when forced through Lean,
the metaphor changes category.  The result is not a serialization
engine.  It is a constraint node.

The main thesis of this section is:

```text
Lean is a diagnostic instrument for informal intuition.
It does not merely transcribe metaphors; it tests their type.
```

The detailed record of this correction is the commentary document

```text
BSDBridgeC/docs/BSDSerializationEngine.md
```

and the corrected Lean objects live in

```text
BSDBridgeC/WhoWhere/Basic.lean
```

### 10.1. The case study: `BSDSerializationEngine`

A first informal API sketch might read:

```text
BSDSerializationEngine.encode :
  input:
    torsion order
    Sha order
    Tamagawa factors
    regulator
    period
  output:
    leading Taylor coefficient of L(E, s) at s = 1
```

This is intentionally playful, but it captures a real visual
temptation.  BSD places several unlike arithmetic quantities on one
side of a formula and a central analytic quantity on the other.  To a
software engineer, it is natural to read this as an encoder:

```text
heterogeneous input tuple → one output scalar
```

The appeal is precisely why the metaphor is dangerous.  It compresses
the shape of the formula into a familiar programming trope, but it
also imports properties that BSD does not have.

### 10.2. Why "serialization" is the wrong word

In software, serialization is usually expected to have at least three
features.

First, it is lossless in the relevant sense.  The serialized form is
supposed to determine the object being serialized, perhaps after a
decoding step.  The leading Taylor coefficient does not determine the
five Who-side components of BSD.  Even if the conjectural formula is
granted as an equality, the scalar product does not uniquely recover
torsion, Sha, Tamagawa factors, regulator, and period.

Second, serialization is computable as a function.  One calls an
encoder.  BSD is not presently a callable function from arithmetic
data to an analytic coefficient, nor a callable verifier returning a
closed theorem.  In the Lean scaffold, the relevant content appears as
named fields and hypotheses, not as an executable encoder.

Third, serialization metaphors often invite hash-collision language:
"the central scalar perfectly records the arithmetic data."  That
language fails especially badly here.  The Tate--Shafarevich group is
not even known finite in general, and the package deliberately records
that uncertainty as a socket rather than suppressing it.

Thus the original metaphor fails along exactly the axes that Lean asks
us to type: losslessness, computability, and the status of unknown
data.

### 10.3. Constraint-satisfaction reading

The corrected reading is heterogeneous constraint satisfaction.
There are three separately typed pieces:

```text
Who data          : heterogeneous arithmetic package
Where data        : central Taylor / functional-equation package
Compatibility     : two named sockets relating the two sides
```

In Lean, these are not represented by an encoder.  They are represented
by structures and forgetful constructors.

On the Who side, `BSDWhoData` carries the five heterogeneous fields:

```lean
torsion   : TorsionData
sha       : ShaData
tamagawa  : TamagawaData
regulator : RegulatorData
period    : PeriodData
```

The corresponding Type-side bundle is:

```lean
BSDWhoHeterogeneousBundle
```

and the forgetful constructor is:

```lean
bsdWhoData_to_heterogeneousBundle :
  (W : BSDWhoData) → BSDWhoHeterogeneousBundle W
```

On the Where side, `BSDWhereData` carries an L-function-like object,
a root number, central Taylor data, and a functional-equation socket:

```lean
L : ℂ → ℂ
rootNumber : ℂ
centralTaylor : CentralTaylorData
functionalEquationAtCenter : Prop
```

The corresponding bundle is:

```lean
BSDWhereCentralBundle
```

with constructor:

```lean
bsdWhereData_to_centralBundle :
  (W : BSDWhereData) → BSDWhereCentralBundle W
```

Finally, the Bridge C compatibility node is:

```lean
BSDWhoWhereCompatible who where_
```

with two socket fields:

```lean
leadingCoefficientFormula : Prop
rankOrderCompatibility : Prop
```

The corresponding bundle and flat socket pair are:

```lean
BSDCompatibilitySocketBundle

bsdWhoWhereCompatible_to_socketBundle :
  BSDWhoWhereCompatible who where_ →
    BSDCompatibilitySocketBundle who where_

bsdWhoWhereCompatible_socketPair :
  BSDWhoWhereCompatible who where_ → Prop × Prop
```

The three corrected arrows are therefore:

```text
BSDWhoData             → BSDWhoHeterogeneousBundle
BSDWhereData           → BSDWhereCentralBundle
BSDWhoWhereCompatible  → BSDCompatibilitySocketBundle
```

Each arrow is a forgetful projection.  It introduces no new
mathematics, proves no BSD formula, computes no Sha group, and
discharges no functional equation.  Its purpose is to expose the
shape of the constraint as named typed data.

### 10.4. What was learned

The lesson is a category correction:

```text
wrong metaphor:
  function / encoder / serialization engine

corrected Lean shape:
  typed constraint node with named exits
```

The correction is not merely rhetorical.  The Lean file contains no
`BSDSerializationEngine.encode`.  Instead, it contains structures,
field projections, and forgetful constructors.  This matters because
the type signatures refuse to hide the difference between data,
socket, and theorem.

For example, the functional-equation content appears as:

```lean
functionalEquationAtCenter : Prop
```

and is forwarded by:

```lean
bsdWhereData_has_functionalEquationSocket
```

It is not silently assumed.  Likewise, the compatibility content is
split into:

```lean
bsdWhoWhereCompatible_has_leadingCoefficientFormula
bsdWhoWhereCompatible_has_rankOrderCompatibility
```

The API correction therefore becomes a proof-engineering correction:
once the metaphor is typed, the false function disappears and the
real constraint node remains.

### 10.5. General principle

The principle is:

```text
Lean reveals architecture by forcing metaphors to type-check.
```

This is a small example, but it is representative of the larger paper.
In Section 2, Mathlib's zeta infrastructure revealed that the zeta
object is not a single monolithic definition but a family of analytic,
Dirichlet, Euler-product, exp-log, log-derivative, and completed
functional-equation layers glued by named theorems.  There too, Lean
did not merely transcribe a familiar object.  It exposed its typed
architecture.

The BSD serialization case is more modest and more local.  It does not
prove BSD.  It does not add new arithmetic geometry.  Its value is
diagnostic: it records the moment when a vivid informal metaphor was
sharpened into a more accurate formal one.

The resulting slogan is:

```text
BSD is not a serialization engine.
It is a Bridge C constraint node.
```

That correction is precisely the kind of methodological information
this paper aims to make visible.  Formalization is not only a way to
certify finished proofs.  It is also a way to discover what kind of
object an informal idea actually is.

## 11. Functional-Equation Freezing

Bridge C has one more local feature that is independent of the large
rigidity pipeline: Where symmetry can freeze a real direction.  In the
Hermite--Pochhammer and zeta-adjacent setting this appears as a
first-order complex-algebra theorem.  In the BSD setting it appears as
a parity-freezing theorem at the center.  The two statements are not
the same theorem, and the BSD theorem is not an instance of the
first-order response lemma.  They are deliberately presented as
parallel algebraic manifestations of the same methodological slogan:

```text
Where symmetry removes a direction of freedom.
```

The main theorem of this section is the GaussianWhoWhere theorem

```lean
bridgeC_where_firstOrder_freezes_Re
```

from

```text
GaussianWhoWhere/Infinite/FunctionalEquationFreezing.lean
```

The BSD companion is the parity-freezing theorem

```lean
bsdBridgeCProfile_centralZero_of_negativeRootFunctionalEquation
```

from

```text
BSDBridgeC/Freezing/ProfileParity.lean
```

with its Where-layer source in

```text
BSDBridgeC/Freezing/Parity.lean
```

### 11.1. The perturbative setting

The informal analytic picture is the following.  Consider a
perturbation

```text
F_eps(s) = xi(s) + eps * H(s)
```

near a simple zero

```text
rho = 1/2 + i gamma.
```

Implicit differentiation of `F_eps(rho(eps)) = 0` at `eps = 0`
suggests a first-order displacement

```text
delta rho = - eps * H(rho) / xi'(rho).
```

Under reflection symmetry about the critical line, the point
`1 - rho` coincides with the complex conjugate of `rho`.  The usual
formal consequences are:

```text
xi'(rho) is purely imaginary,
H(rho) is real.
```

Thus the first-order response is purely imaginary.  Its real part
vanishes.  This is the local algebraic content of the statement:

```text
Where freezes first-order real displacement.
```

The Lean file does not formalize an implicit-function theorem, nor
does it construct the branch `rho(eps)`.  It isolates only the
algebraic quotient calculation at the end of the perturbative
argument.

### 11.2. Lean predicates

The file `FunctionalEquationFreezing.lean` begins with two elementary
predicates:

```lean
IsRealComplex (z : ℂ) : Prop
IsPureImagComplex (z : ℂ) : Prop
```

They are defined by vanishing of the imaginary and real parts,
respectively:

```lean
IsRealComplex z      := z.im = 0
IsPureImagComplex z  := z.re = 0
```

The local algebraic toolkit consists of four small lemmas:

```lean
realComplex_of_real
pureImag_mul_I
pureImag_neg
real_mul_pureImag
```

These are deliberately minimal.  They are not a theory of holomorphic
functions, zeros, or functional equations.  They are just enough
complex arithmetic to state and prove that a real numerator divided by
a nonzero purely imaginary denominator has zero real part after the
sign convention used by first-order perturbation theory.

### 11.3. The first-order response theorem

The parameterized form writes the denominator as `(y : ℂ) * I`:

```lean
firstOrderResponse_pureImag_param
```

Its statement is:

```lean
{eps h y : ℝ} →
  y ≠ 0 →
  IsPureImagComplex
    (-((eps : ℂ) * (h : ℂ)) / ((y : ℂ) * Complex.I))
```

The general form abstracts the denominator as an arbitrary nonzero
purely imaginary complex number:

```lean
firstOrderResponse_pureImag_real
```

with shape:

```lean
IsPureImagComplex D →
D ≠ 0 →
IsPureImagComplex (-((eps : ℂ) * (h : ℂ)) / D)
```

The paper-facing theorem extracts the real-part equation:

```lean
bridgeC_where_firstOrder_freezes_Re
```

with statement:

```lean
IsPureImagComplex D →
D ≠ 0 →
(-((eps : ℂ) * (h : ℂ)) / D).re = 0
```

There is also an application-flavored alias:

```lean
where_firstOrder_response_has_zero_real_part
```

The proof is pure complex algebra.  It uses no Jensen socket, no
Hermite--Pochhammer basis, no zeta object, no zero-counting, and no
analytic continuation.

### 11.4. Interpretation as a Where theorem

The intended reading is:

```text
D = xi'(rho)
h = H(rho)
eps real
```

If the Where symmetry forces `D` to be purely imaginary and `h` to be
real, then the response

```text
- eps * h / D
```

has zero real part.  This is exactly the algebraic content needed for
the slogan:

```text
Where = first-order real-part freezing operator.
```

The theorem is intentionally local.  It does not say that zeros stay
on a line under an actual analytic perturbation.  It says that once
the perturbation calculation has reduced the response to the displayed
quotient, the real part of that quotient is forced to vanish by the
Where symmetry.

This matters for the paper's methodology.  A large global statement is
not being smuggled into a slogan.  The slogan has been cut down to a
small theorem with exactly the hypotheses it needs.

### 11.5. Independence from the analytic sockets

The independence is as important as the theorem.

The statement

```lean
bridgeC_where_firstOrder_freezes_Re
```

does not depend on:

- `JensenCartwrightLinearZeroBound`;
- the Hermite--Pochhammer finite or infinite rigidity pipeline;
- the zeta bridge scaffold;
- sampled Who-data;
- real-axis-to-global analytic continuation;
- log-derivative reconstruction.

It lives in a standalone file and is proved from elementary complex
arithmetic.  This is the cleanest example in the development of a
Bridge C principle being isolated from all branch-specific machinery.

### 11.6. BSD parity freezing as a companion

The BSD branch has a different but structurally analogous freezing
statement.  It is not a first-order displacement theorem.  It is a
central-value parity theorem.

At the Where layer, `BSDBridgeC/Freezing/Parity.lean` defines:

```lean
RootNumberFunctionalEquation (L : ℂ → ℂ) (w : ℂ) : Prop :=
  ∀ t : ℂ, L (1 + t) = w * L (1 - t)
```

The algebraic theorem is:

```lean
bsd_where_rootNumber_forces_centralZero
```

If the root number is `-1`, substituting `t = 0` gives:

```text
L(1) = - L(1),
```

and hence:

```text
L(1) = 0.
```

The application-flavored alias is:

```lean
bsd_where_sign_neg_one_forces_vanishing
```

The theorem is then packaged at the Where-data level by:

```lean
BSDWhereHasNegativeRootFunctionalEquation
bsdWhereData_centralZero_of_negativeRootFunctionalEquation
```

and lifted to the profile level in
`BSDBridgeC/Freezing/ProfileParity.lean`:

```lean
BSDBridgeCProfileHasNegativeRootFunctionalEquation
bsdBridgeCProfile_centralZero_of_negativeRootFunctionalEquation
```

This BSD statement is intentionally weak in analytic content and
strong in type discipline.  It does not prove the functional equation.
It does not prove BSD.  It does not identify analytic and algebraic
rank.  The hypothesis

```lean
BSDWhereHasNegativeRootFunctionalEquation W
```

is a named conjunction: the `rootNumber` field is `-1`, and the
local-center functional equation holds.  The theorem consumes that
Where-side hypothesis and returns the forced central vanishing.

Thus the BSD side is not weak in the sense of being absent.  It is
weaker only if one expects the same first-order perturbative theorem
to apply unchanged.  The correct comparison is:

```text
GaussianWhoWhere freezing:
  Where symmetry freezes first-order real displacement.

BSD parity freezing:
  negative root-number Where symmetry freezes the central value
  to zero.
```

Both are algebraic consequences of functional-equation structure.
Both are independent of the large open sockets.  Both are deliberately
small.  They support the same methodological claim: Bridge C does not
only expose large compatibility sockets; it can also isolate tiny
algebraic consequences of Where symmetry as reusable theorems.

## 12. Numerical Companion: Stiffness and RMT Source

The previous section isolated an algebraic theorem.  This section
records the numerical companion to that theorem and to the Bridge C
interpretation more broadly.  The numerical work is not part of the
Lean proof.  It does not discharge any socket.  It does not prove RH,
BSD, Jensen--Cartwright, or any zero-location statement.  Its role is
different: it tests whether the local response picture suggested by
the formal architecture is visible in computed zeta-zero data.

The companion material lives in the `GaussianWhoWhere` repository:

```text
GaussianWhoWhere/experiments/README.md
GaussianWhoWhere/experiments/numerical_results_summary.md
GaussianWhoWhere/experiments/*.py
GaussianWhoWhere/experiments/data/*.csv
GaussianWhoWhere/paper/*.png
```

The data files record precomputed experiments.  The large external
zero list `zeros6.txt` is not included in the repository; the scripts
expect the first `2,001,052` nontrivial zeros of the Riemann zeta
function, sourced from LMFDB.

The main thesis of this section is:

```text
The numerics corroborate the local stiffness interpretation of
Bridge C; they are not a substitute for any formal proof.
```

### 12.1. Why a numerical companion belongs here

Section 11 proves that, once a first-order perturbation calculation has
the form

```text
delta rho = - eps * h / D,
```

with `h` real and `D` nonzero purely imaginary, the real part of the
response is zero.  That theorem says nothing about the existence of a
zero branch, the numerical size of the vertical response, or the
statistical source of the denominator.

The numerical experiments investigate those remaining interpretive
questions:

```text
What is the measured vertical response?
What local quantity controls its size?
How does this quantity relate to zeta-zero spacing?
What changes when the functional equation is broken?
```

The experiments therefore sit beside the formal theorem.  They are a
companion to the algebraic freezing statement, not evidence in place
of it.

### 12.2. Experiment suite and data

The experiment suite consists of five scripts:

```text
phase1a_prime_v4.py
phase2_bridge_c.py
phase2_vs_1a_comparison.py
bridge_c_rmt_stiffness.py
bridge_c_rmt_SI.py
```

The precomputed data files are:

```text
experiments/data/phase1a_prime_v4.csv
experiments/data/phase2_colab_primary_10.csv
experiments/data/phase2_colab_stability_10.csv
experiments/data/bridge_c_rmt_SI_data.csv
```

The two high-throughput root-tracking experiments are:

- Phase 1a' (`phase1a_prime_v4.py`): `40,000` rows, consisting of
  `10,000` zeros under four Where-preserving conditions.
- Phase 2 (`phase2_bridge_c.py`): `100,000` rows under a
  Where-breaking / Who-breaking perturbation.

The RMT stiffness experiment uses the full zero list for spacing
statistics and samples `2,000` zeros for computing `Z'(gamma)`.

### 12.3. Phase 1a': Where-preserving response

The Where-preserving experiment works on the critical line with the
Hardy `Z` function:

```text
Xi_eps(t) = Z(t) + eps * h(t).
```

Here `Z(t)` and `h(t)` are real-valued on the line.  The perturbation
therefore tests the vertical response predicted by the first-order
picture.  For a zero `gamma_k`, the predicted response is:

```text
C_where[h](k) = delta t_k / eps ≈ - h(gamma_k) / Z'(gamma_k).
```

The summary file reports four conditions:

```text
h = 1,        eps = 10^-5
h = 1,        eps = 10^-6
h = cos(t/T), eps = 10^-5
h = cos(t/T), eps = 10^-6
```

All `40,000/40,000` root tracks converged.  The best condition reports:

```text
corr(predicted, measured) = 0.99999988
median relative error     = 2.53 × 10^-4
```

The other three conditions also have correlations at least
`0.99999321`.  This is the numerical counterpart of the formal
freezing theorem: the horizontal motion is frozen by construction of
the Where-preserving perturbation, and the measured vertical motion is
governed by the stiffness quantity `Z'(gamma_k)`.

### 12.4. Local stiffness

The experiments identify

```text
|Z'(gamma_k)|
```

as the local stiffness of the `k`-th zero.  Its reciprocal controls the
size of the Where-preserving response:

```text
response size ≈ |h(gamma_k)| / |Z'(gamma_k)|.
```

For the `10,000`-zero Phase 1a' sample, the summary reports:

```text
mean   |Z'(gamma_k)| = 1.04 × 10^1
median |Z'(gamma_k)| = 7.87 × 10^0
min    |Z'(gamma_k)| = 5.55 × 10^-2
max    |Z'(gamma_k)| = 5.20 × 10^2
```

The inverse stiffness has a heavy right tail.  This is important
because it explains why some zeros respond much more strongly than
others even though the algebraic freezing theorem is uniform.  The
theorem freezes a direction; it does not make every zero equally
stiff.

### 12.5. Phase 2: breaking Where releases the real direction

Phase 2 uses a perturbation that breaks the functional-equation
structure.  It tracks `100,000` zeros and records both components:

```text
Ck_Re
Ck_Im
```

The data file is:

```text
experiments/data/phase2_colab_primary_10.csv
```

At high heights the summary reports:

```text
|Re| / |Im| ≈ 1.08.
```

Thus, once the functional-equation symmetry is broken, the real
direction is no longer frozen; the response becomes approximately
isotropic at high height.  This is the numerical contrast to the
Where-preserving Phase 1a' experiment.

The comparison script

```text
phase2_vs_1a_comparison.py
```

tests the Where-preserved and Where-broken distributions.  The summary
reports:

```text
KS = 0.092,
p  = 2.4 × 10^-67.
```

The interpretation is not that the numerical test proves a theorem.
It is that the two response regimes are visibly different: functional
equation preservation changes the response distribution, not merely
the notation used to describe it.

### 12.6. RMT stiffness-source hypothesis

The most important numerical result is not about the distribution of
response values themselves.  It is about the source of the stiffness
field.

The script

```text
bridge_c_rmt_stiffness.py
```

uses the full list of `2,001,052` zeros to compute adjacent spacings
and samples `2,000` zeros to compute `Z'(gamma_k)`.  It first confirms
the expected Montgomery--Odlyzko / GUE spacing behavior:

```text
mean spacing ratio <r> = 0.60665
GUE target             = 0.60266
```

It then compares the nearest-neighbor spacing

```text
Delta_min
```

with the local stiffness:

```text
|Z'(gamma_k)|.
```

The key correlations reported are:

```text
Delta_min vs |Z'|       Spearman r = +0.6601, p = 1.3 × 10^-250
Delta_min vs 1/|Z'|     Spearman r = -0.6601, p = 1.3 × 10^-250
log Delta_min vs log |Z'| Pearson r = +0.6819
```

The supplementary script

```text
bridge_c_rmt_SI.py
```

finds that the geometric mean of the left and right adjacent spacings
is an even stronger predictor:

```text
sqrt(Delta_L * Delta_R) vs |Z'|  Spearman r ≈ +0.732.
```

This is consistent with the Hadamard-product intuition: the derivative
at a zero depends on the neighboring zero geometry, not merely on one
nearest neighbor.

The resulting mechanism is:

```text
GUE level repulsion
  → spacing field
  → stiffness field |Z'(gamma_k)|
  → Bridge C response scale.
```

In other words, RMT enters the Bridge C numerical picture through the
stiffness field, not through a universality class for the response
values themselves.

### 12.7. Withdrawn beta-ladder hypothesis

The numerical companion also records a negative result.  An earlier
interpretation suggested a beta-ladder: as the perturbation scale
changed, the Where-preserving response values appeared to move from a
Poisson-like regime toward a GOE-like regime.

That hypothesis was withdrawn.  The reason is structural.  The
predicted response

```text
C_pred = -h(gamma_k) / Z'(gamma_k)
```

is independent of `eps`.  When spacing ratios are computed from the
predicted response rather than from finite-precision measured root
tracks, the apparent beta dependence disappears.  The summary records
the corrected interpretation:

```text
The RMT connection operates through the stiffness-source hypothesis,
not through the universality class of response values.
```

This withdrawal matters methodologically.  The numerical companion is
not a collection of supportive plots kept regardless of outcome.  It
contains a documented retraction of an attractive but incorrect
interpretation.  That is the numerical analogue of the registry
hygiene discipline in the Lean development: when a claim is not
supported, it is not left parked under a stronger label.

### 12.8. Status of the numerical companion

The numerical results support three paper-level interpretations:

1. Where-preserving perturbations obey the local stiffness law
   predicted by the first-order analysis.
2. Where-breaking perturbations release the real direction and produce
   a different response distribution.
3. GUE spacing statistics appear to control the stiffness field
   `|Z'(gamma_k)|`, with Spearman correlation about `0.66` for
   `Delta_min` and about `0.73` for the geometric-mean spacing
   predictor.

They do not prove:

- RH;
- any zero-location theorem;
- Jensen--Cartwright zero-density;
- the C-HP rigidity theorem;
- BSD;
- any formal theorem about random matrices;
- any theorem about all zeta zeros.

The companion therefore has the same discipline as the rest of the
paper.  It is useful because it is sharply bounded.  The Lean theorem
of Section 11 isolates a local algebraic freezing law; the experiments
show that the corresponding local response and stiffness field are
visible in large-scale computed data.  The formal theorem and the
numerical companion are not interchangeable, and neither is asked to
do the other's job.

## 13. Conclusion

This paper is not a proof of RH, BSD, Jensen--Cartwright theory, or a
new theorem about the zero locations of the Riemann zeta function.  It
is a proof-engineering paper about what Lean can make visible when a
large mathematical claim is decomposed until its remaining openness is
no longer a fog.

The central methodological claim is:

```text
Formalization is not only proof certification.
It is also an instrument for exposing mathematical architecture.
```

The paper demonstrates this claim through the Bridge C architecture
and the recursive leaf-localization discipline.

### 13.1. What Bridge C contributes

Bridge C is not a new equation.  It is a typed coupler.  It separates
two roles:

```text
Who    : arithmetic / multiplicative / identity data
Where  : analytic / reflective / central symmetry data
```

and records the nontrivial content connecting them as named exits:
theorems, sockets, profiles, or typed leaves.

The Hermite--Pochhammer branch shows the strongest mathematical
instance.  The finite theorem

```lean
finite_general_uniqueness
```

is closed unconditionally.  The infinite theorem

```lean
where_rigidity_of_oddLogSample_from_jensenCartwright
```

is mechanically composed downstream of one named analytic socket:

```lean
JensenCartwrightLinearZeroBound
```

Everything below that socket is exposed as Lean structure, not as
informal prose.  The result is not "we assume a vague analytic fact."
It is "this theorem consumes exactly this named socket."

The zeta branch shows a different use.  It does not prove a rigidity
claim.  Instead, `ZetaBridgeCProfile` records that Mathlib's zeta
infrastructure already separates analytic, Dirichlet, Euler-product,
log-derivative, and completed functional-equation layers.  The
Dirichlet side is backed by concrete Mathlib theorems; the remaining
layers are registered as typed interfaces or explicit non-claims.
This is architecture recognition, not zero-location control.

The BSD branch shows the newest methodological contribution.  There
the point is not to solve BSD.  The point is to turn a heterogeneous
constraint node into a typed dependency DAG whose residual openness is
observable, refinable, audited, and queryable.

### 13.2. Recursive leaf localization

The BSD branch begins with heterogeneous Who-data, central Where-data,
and a compatibility node.  Refinement then proceeds structurally:
structures are split into sub-structures; fields become dependency
edges; unresolved fields become leaves.

The fully refined BSD profile records:

```text
4 closed leaves
12 open leaves
16 total leaves
```

The open count grows along the trace

```text
2 ≤ 5 ≤ 7 ≤ 12
```

not because the mathematics becomes harder, but because the scaffold
has refined coarse open content into more precise named leaves.

This is the central idea of recursive leaf localization:

```text
Open mathematics is not a fog.
It is a typed refinement trace ending in named leaves.
```

The Sha leaf illustrates the point.  A coarse leaf

```text
Sha finiteness
```

is refined into:

```text
Sha finiteSocket
Selmer-Sha injection socket
Selmer-Sha surjection socket
Selmer-Sha exactness socket
```

The refinement does not close Sha.  It makes the unresolved structure
smaller, more explicit, and harder to misdescribe.

### 13.3. Observation axes and hygiene

The paper also separates several questions that are often conflated.

Leaf localization answers:

```text
Where are the leaves?
```

Partial closure audit answers:

```text
What role does a representative entry currently play?
```

Pending audit answers:

```text
Which refined leaves have not yet been assigned an audit status?
```

Closeability audit answers:

```text
Why is this entry not closed yet?
```

These axes are independent.  The quantities

```text
12
(2, 1, 1, 0)
10
(4, 1, 1, 1, 0)
```

are not partitions of one another.  They measure different aspects of
the scaffold.  This distinction is not editorial commentary; it is
reflected in Lean definitions, count theorems, and lookup functions.

The hygiene theorem

```lean
bsd_closeabilityAudit_hygieneClean
```

adds a further discipline: no entry is allowed to remain parked in the
`closeableNow` status.  If a leaf is closeable now, the scaffold should
close it or reclassify it.  This is the reverse-overclaim guard.  It
prevents the development from making the open boundary look harder
than it is.

### 13.4. From registry to query index

V4 inverts the registry.  Before V4, the scaffold could list leaves.
After V4, leaves are values of the inductive type:

```lean
BSDLeafId
```

This supports decidable equality, typed partitions, typed audit
coverage, typed closeability coverage, and lookup functions:

```lean
BSDLeafId.partialClosureAuditStatus
BSDLeafId.closeabilityStatus
BSDLeafId.toRefinementLeaf
```

The result is not just a diagram.  It is a queryable index.  A reader
can ask for the status of a specific typed leaf and obtain the current
audit and closeability classification.  The bridge

```lean
BSDLeafId.toRefinementLeaf
```

keeps the typed registry synchronized with the human-readable
`RefinementLeaf` registry.

This is the point at which the scaffold becomes an instrument rather
than a static map.

### 13.5. Functional-equation freezing and numerical companion

The functional-equation freezing theorem

```lean
bridgeC_where_firstOrder_freezes_Re
```

shows that a local Where principle can be isolated as a small algebraic
theorem independent of the large analytic sockets.  The BSD parity
freezing theorem gives a companion manifestation: negative
root-number symmetry forces central vanishing once the relevant
functional-equation hypothesis is supplied.

The numerical companion then tests the local response interpretation
against computed zeta-zero data.  It supports the stiffness picture:
Where-preserving perturbations follow the local law governed by
`Z'(gamma)`, Where-breaking perturbations release the real direction,
and GUE spacing statistics appear to control the stiffness field.

The numerical work is deliberately bounded.  It is not a proof.  Its
most important methodological feature is that it also records a
withdrawn interpretation, the beta-ladder hypothesis.  This mirrors
the Lean-side hygiene discipline: attractive but unsupported readings
are not retained under stronger labels.

### 13.6. What is not claimed

The paper deliberately avoids several overclaims.

It does not claim:

- a proof of RH;
- a proof of BSD;
- a proof of Jensen--Cartwright zero-counting theory;
- a proof of Sha finiteness;
- a proof of higher-rank Euler-system existence;
- a zeta zero-location theorem;
- an identification of the HP branch with zeta;
- a theorem extracted from the numerical experiments.

The point is not that these problems disappear.  The point is that
their locations become explicit.

For the C-HP infinite branch, the remaining analytic wall is named:

```lean
JensenCartwrightLinearZeroBound
```

For the BSD branch, the residual open content is localized into named
leaves and then further analyzed by audit and closeability registries.
The package does not flatten every gap into the same color.  It
distinguishes mathematically open content from technically hard,
technically heavy, and modeling-blocked content.

### 13.7. Why this belongs in automated reasoning

The contribution is methodological, and therefore appropriate for a
venue such as the Journal of Automated Reasoning.

Interactive theorem proving is often described as the final stage of
mathematical verification: a proof is finished, then formalized.  This
paper emphasizes another role.  Lean can be used earlier, while a
program is still being understood, to detect category errors, expose
dependency structure, name sockets, separate claims from non-claims,
and make openness queryable.

In this sense, the paper argues for a broader view of formalization:

```text
Formalization can certify proof.
It can also diagnose structure.
```

The Bridge C development is a case study in the second role.  It shows
how a proof assistant can discipline the boundary between theorem,
socket, scaffold, numerical evidence, and metaphor.

### 13.8. Final summary

The final message is:

```text
Bridge C is a reusable typed proof architecture.
Recursive leaf localization turns unresolved content into named leaves.
Audit and closeability registries prevent both overclaim and reverse
overclaim.
Typed identifiers turn the registry into a queryable index.
```

Across Hermite--Pochhammer rigidity, the Mathlib zeta scaffold, and
the BSD dependency DAG, the same discipline appears: separate Who from
Where, expose the connecting content as typed exits, and make every
remaining gap visible by name.

That is the paper's contribution.  It does not remove every open leaf.
It changes what it means to say where the openness is.

# Appendices

## Appendix A. Lean Dependency Graphs

This appendix records the dependency layout of the two Lean
developments used in the paper.  It is not meant to reproduce every
proof term.  Its purpose is to make the architecture auditable: a
reader can see where each named theorem, socket, profile, and typed
registry lives.

The appendix separates the two packages:

```text
GaussianWhoWhere
BSDBridgeC
```

The first contains the Hermite--Pochhammer rigidity, the infinite
Bridge C pipeline, the Mathlib zeta scaffold, and the first-order
freezing theorem.  The second contains the BSD constraint-node
scaffold, recursive leaf localization, audit registries, typed query
indices, and the cross-branch leaf registry.

### A.1. `GaussianWhoWhere` dependency layout

The `GaussianWhoWhere` development currently consists of `51` Lean
source files under:

```text
GaussianWhoWhere/
GaussianWhoWhere/Infinite/
GaussianWhoWhere/ZetaBridge/
```

The old Bridge C appendix can mostly be reused for this package.  The
layers are:

```text
G0. Basic objects
    Basic.lean
    ConcretePolynomials.lean
    HermitePochhammer.lean

G1. Polynomial rigidity
    PolynomialRigidity.lean
    LogMultiplicativity.lean

G2. Finite Hermite--Pochhammer uniqueness
    FiniteUniqueness.lean
    FiniteGeneralUniqueness.lean

G3. Bridge vocabulary
    BridgeStructure.lean
    InfiniteCoupler.lean

G4. Infinite analytic pipeline
    Infinite/*.lean

G5. Zeta scaffold
    ZetaBridge/Basic.lean

G6. Theorem map
    TheoremMap.lean
```

The finite rigidity branch is closed unconditionally.  Its main
headline is:

```lean
finite_general_uniqueness
```

The infinite C-HP branch is conditional on the single analytic socket:

```lean
JensenCartwrightLinearZeroBound
```

The freezing branch is independent of that socket and is located at:

```text
GaussianWhoWhere/Infinite/FunctionalEquationFreezing.lean
```

The zeta branch is located at:

```text
GaussianWhoWhere/ZetaBridge/Basic.lean
```

It records the C-zeta scaffold and the concrete Dirichlet-side
witness for `riemannZeta`.  Three additional files in
`GaussianWhoWhere/LFunctionBridge/` extend this with concrete
Euler-product, log-derivative, and completed-Where witnesses,
and assemble them into the fully bound concrete instance
`riemannZeta_zetaBridgeCProfile : ZetaBridge.ZetaBridgeCProfile`.
The branch does not prove a zero-location theorem and does not
connect zeta to the Hermite--Pochhammer rigidity theorem.

### A.2. `BSDBridgeC` dependency layout

The `BSDBridgeC` development currently consists of `14` Lean source
files:

```text
BSDBridgeC/Basic.lean
BSDBridgeC/WhoWhere/Basic.lean
BSDBridgeC/Bridges/Basic.lean
BSDBridgeC/Socket/HigherRank.lean
BSDBridgeC/Specialization/RankOne.lean
BSDBridgeC/Freezing/Parity.lean
BSDBridgeC/Freezing/ProfileParity.lean
BSDBridgeC/Profile/Basic.lean
BSDBridgeC/Profile/Generality.lean
BSDBridgeC/Profile/LeafLocalization.lean
BSDBridgeC/Profile/PartialClosureAudit.lean
BSDBridgeC/Profile/CloseabilityAudit.lean
BSDBridgeC/Profile/BranchLeafRegistry.lean
BSDBridgeC/TheoremMap.lean
```

The root aggregator imports them in the following order:

```lean
import BSDBridgeC.Basic
import BSDBridgeC.WhoWhere.Basic
import BSDBridgeC.Bridges.Basic
import BSDBridgeC.Socket.HigherRank
import BSDBridgeC.Specialization.RankOne
import BSDBridgeC.Freezing.Parity
import BSDBridgeC.Profile.Basic
import BSDBridgeC.Freezing.ProfileParity
import BSDBridgeC.Profile.Generality
import BSDBridgeC.Profile.LeafLocalization
import BSDBridgeC.Profile.PartialClosureAudit
import BSDBridgeC.Profile.CloseabilityAudit
import BSDBridgeC.Profile.BranchLeafRegistry
import BSDBridgeC.TheoremMap
```

Conceptually, the layout is:

```text
B0. Basic placeholders
    BSDBridgeC/Basic.lean

B1. Who / Where layer
    BSDBridgeC/WhoWhere/Basic.lean

B2. Bridge A / A' / B / C socket genealogy
    BSDBridgeC/Bridges/Basic.lean

B3. Higher-rank socket genealogy
    BSDBridgeC/Socket/HigherRank.lean

B4. Rank-one specialization
    BSDBridgeC/Specialization/RankOne.lean

B5. BSD parity freezing
    BSDBridgeC/Freezing/Parity.lean
    BSDBridgeC/Freezing/ProfileParity.lean

B6. Profile and generality wrappers
    BSDBridgeC/Profile/Basic.lean
    BSDBridgeC/Profile/Generality.lean

B7. Recursive leaf localization and V4 typed identifiers
    BSDBridgeC/Profile/LeafLocalization.lean

B8. Partial closure audit and typed audit coverage
    BSDBridgeC/Profile/PartialClosureAudit.lean

B9. Closeability audit and typed closeability coverage
    BSDBridgeC/Profile/CloseabilityAudit.lean

B10. Cross-branch leaf registry
    BSDBridgeC/Profile/BranchLeafRegistry.lean

B11. Theorem map
    BSDBridgeC/TheoremMap.lean
```

There is no separate file named `TypedLeafIdentifier.lean`.
The typed identifier `BSDLeafId` lives in:

```text
BSDBridgeC/Profile/LeafLocalization.lean
```

Similarly, there is no separate `PendingClosureAudit.lean`.  The
string-level pending audit registry lives in:

```text
BSDBridgeC/Profile/PartialClosureAudit.lean
```

This placement matters because V4 is a non-destructive overlay on
V3.  The same file that contains the string-based `RefinementLeaf`
registry also contains the typed `BSDLeafId` bridge back into that
registry.

### A.3. The C-HP analytic socket

The C-HP infinite theorem is reduced to one named analytic socket:

```lean
JensenCartwrightLinearZeroBound
```

It is defined in:

```text
GaussianWhoWhere/Infinite/JensenCartwrightInterface.lean
```

as an alias for the nonzero-form linear real-zero-counting socket:

```lean
FiniteExpTypeLinearZeroBound
```

The intended mathematical content is:

```text
nonzero finite exponential type function
  → linear real-zero counting upper bound
```

The zero-density machinery downstream of that socket is internalized:

```text
ZeroCounting.lean
ZeroDensityForcesZeroRefined.lean
LogSampleDensity.lean
LogSampleZeroContradiction.lean
OddLogLinearZeroBoundBeating.lean
JensenFinalPipeline.lean
```

The final C-HP theorem using the socket is:

```lean
where_rigidity_of_oddLogSample_from_jensenCartwright
```

It lives in:

```text
GaussianWhoWhere/Infinite/JensenFinalPipeline.lean
```

This appendix should be read carefully: `JensenCartwrightLinearZeroBound`
is the single remaining analytic socket for the C-HP infinite
rigidity branch.  It is not the only open content of the entire paper;
the BSD branch deliberately contains its own open leaves.

### A.4. The `BSDLeafId` inductive

The V4 typed identifier for the fully refined BSD leaves is:

```lean
inductive BSDLeafId where
  | torsion
  | tamagawa
  | regulator
  | period
  | shaFiniteSocket
  | shaSelmerInjection
  | shaSelmerSurjection
  | shaSelmerExactness
  | bsdLeadingCoefficientFormula
  | bsdRankOrderCompatibility
  | higherEulerNormCompatibility
  | higherKolyvaginLocalRelations
  | higherKolyvaginDerivativeLaw
  | higherRankRegulatorCompatibility
  | higherRankSelmerControl
  | higherRankAnalyticRankCompatibility
deriving DecidableEq, Repr
```

Source:

```text
BSDBridgeC/Profile/LeafLocalization.lean
```

The first four constructors are closed leaves:

```text
torsion
tamagawa
regulator
period
```

The remaining twelve constructors are open leaves in the fully refined
BSD profile:

```text
shaFiniteSocket
shaSelmerInjection
shaSelmerSurjection
shaSelmerExactness
bsdLeadingCoefficientFormula
bsdRankOrderCompatibility
higherEulerNormCompatibility
higherKolyvaginLocalRelations
higherKolyvaginDerivativeLaw
higherRankRegulatorCompatibility
higherRankSelmerControl
higherRankAnalyticRankCompatibility
```

The typed partitions are:

```lean
bsd_closedLeafIds : List BSDLeafId
bsd_openLeafIds : List BSDLeafId
bsd_fullyRefinedLeafIds : List BSDLeafId
```

with count theorems:

```lean
bsd_closedLeafIds_count : bsd_closedLeafIds.length = 4
bsd_openLeafIds_count : bsd_openLeafIds.length = 12
bsd_fullyRefinedLeafIds_count : bsd_fullyRefinedLeafIds.length = 16
```

These close by `rfl`.

The bridge back to the string registry is:

```lean
BSDLeafId.toRefinementLeaf : BSDLeafId → RefinementLeaf
```

with drift-prevention theorems:

```lean
BSDLeafId.toRefinementLeaf_status
BSDLeafId.toRefinementLeaf_label
BSDLeafId.toRefinementLeaf_closed_iff
BSDLeafId.toRefinementLeaf_open_iff
```

These theorems ensure that the typed identifier registry and the
human-readable `RefinementLeaf` registry remain synchronized.

### A.5. Typed audit and closeability lookup

The partial closure audit lives in:

```text
BSDBridgeC/Profile/PartialClosureAudit.lean
```

Its V4 typed coverage relation is:

```lean
structure AuditCoverage where
  auditName : String
  covers : List BSDLeafId
```

The main lists are:

```lean
bsd_auditCoveredLeaves : List BSDLeafId
bsd_pendingAuditLeafIds : List BSDLeafId
```

with counts:

```lean
bsd_auditCoveredLeaves_count = 8
bsd_pendingAuditLeafIds_count = 4
bsd_typedCoverage_count_matches_openLeafCount
```

The membership-level consistency theorems are:

```lean
bsd_typedCoverage_disjoint
bsd_auditCoveredLeaves_subset_open
bsd_pendingAuditLeafIds_subset_open
bsd_openLeafIds_covered_or_pending
bsd_typedCoverage_covers_openLeafIds
```

The inverse lookup is:

```lean
BSDLeafId.partialClosureAuditStatus :
  BSDLeafId → Option ClosureAuditStatus
```

with consistency theorems:

```lean
partialClosureAuditStatus_isSome_iff_covered
partialClosureAuditStatus_isNone_iff_uncovered
```

The closeability audit lives in:

```text
BSDBridgeC/Profile/CloseabilityAudit.lean
```

Its typed coverage relation is:

```lean
structure CloseabilityCoverage where
  closeabilityName : String
  status : CloseabilityStatus
  covers : List BSDLeafId
```

The main list is:

```lean
bsd_closeabilityCoveredLeaves : List BSDLeafId
```

and the coverage exhaustiveness theorem is:

```lean
bsd_closeabilityCoverage_covers_openLeafIds
```

The per-status typed-leaf counts are:

```text
mathematicallyOpen   : 9
technicallyHard      : 0
technicallyHeavy     : 1
blockedByModeling    : 2
closeableNow         : 0
```

The inverse lookup is:

```lean
BSDLeafId.closeabilityStatus :
  BSDLeafId → Option CloseabilityStatus
```

with exhaustiveness theorems:

```lean
closeabilityStatus_some_of_openLeaf
closeabilityStatus_none_of_closedLeaf
```

The registry hygiene theorem is:

```lean
bsd_closeabilityAudit_hygieneClean
```

with alias:

```lean
bsd_closeabilityAudit_has_no_closeableNow
```

This is the type-level guard that no audited entry is parked in
`closeableNow`.

### A.6. V5 branch-leaf registry

The V5 cross-branch registry lives in:

```text
BSDBridgeC/Profile/BranchLeafRegistry.lean
```

It introduces typed leaf identifiers for four branches:

```text
C-HP
C-zeta
C-BSD
C-freezing
```

The generic branch identifier is:

```lean
BridgeCMethodBranch
```

The generic cell is:

```lean
BranchLeaf
```

and the sum type of all branch-local identifiers is:

```lean
BridgeCAnyLeafId
```

The per-branch counts are:

```text
C-HP       : 10 closed,  1 open,  11 total
C-zeta     :  4 closed,  2 open,   6 total
C-BSD      :  4 closed, 12 open,  16 total
C-freezing :  3 closed,  0 open,   3 total
```

The C-ζ counts changed from `2 closed / 4 open` to
`4 closed / 2 open` after the `eulerProductInterface` and
`logDerivativeInterface` leaves were promoted to `closed`, in
light of the typed concrete Mathlib-backed witnesses
`riemannZeta_eulerProductBridge` and
`riemannZeta_logDerivativeBridge` supplied by
`GaussianWhoWhere/LFunctionBridge/`.  The two remaining
C-ζ `«open»` leaves are explicit non-claims
(`analyticContinuationNotClaimed`, `zeroLocationNotClaimed`),
not missing arithmetic-bridge implementations.

The total is:

```text
21 closed, 15 open, 36 total
```

recorded by:

```lean
bridgeC_allLeafIds_count
```

The C-HP and C-zeta entries are reference-only labels.  The file does
not import `GaussianWhoWhere`; this is deliberate.  The branch-leaf
registry is a cross-branch methodological map, not a proof-level
coupling of the two repositories.  The C-ζ promotion is a
classification update justified by the external
`GaussianWhoWhere` repository state.

One warning is essential: in the zeta branch, `«open»` after
the C-ζ promotion means *explicit non-claim* (analytic
continuation, zero location / RH), not "frontier-open
mathematics" in the same sense as the BSD leaf localization
profile.  The shared tag is a registry status, not a uniform
mathematical difficulty class.

The branch registry closes the paper's architectural loop:

```text
HP       : rigidity theorem with one C-HP analytic socket
zeta     : three arithmetic layers Mathlib-backed; two explicit non-claims
BSD      : recursive leaf localization and typed query index
freezing : algebraic Where consequences, no open leaves
```

Together these four branches support the methodological claim of the
paper: Bridge C is not a single theorem about one object.  It is a
typed proof architecture with named exits, recursive leaves, audit
axes, and queryable identifiers.

## Appendix B. Main Theorem Statements

This appendix collects the main Lean declarations cited in the body of
the paper.  The statements are presented without proof bodies.  The
purpose is to let the reader see the actual type-level shape of the
development: which hypotheses are concrete predicates, which pieces
are sockets, and which conclusions are closed theorems.

For readability, most declarations are shown in their source-file
namespace rather than with full package qualification.  For example,
theorems from `GaussianWhoWhere` are displayed as they appear under:

```lean
namespace GaussianWhoWhere
```

and BSD declarations as they appear under:

```lean
namespace BSDBridgeC
```

### B.1. `finite_general_uniqueness`

Source:

```text
GaussianWhoWhere/FiniteGeneralUniqueness.lean
```

Statement:

```lean
theorem finite_general_uniqueness
    (K : ℕ) (c : Fin K → ℝ)
    (hmul : ∀ x y : ℝ,
      (QFinitePoly K c).eval (x + y)
        = (QFinitePoly K c).eval x * (QFinitePoly K c).eval y) :
    ∀ k : Fin K, c k = 0
```

`#check` form:

```lean
GaussianWhoWhere.finite_general_uniqueness
  (K : ℕ) (c : Fin K → ℝ)
  (hmul :
    ∀ x y : ℝ,
      Polynomial.eval (x + y) (GaussianWhoWhere.QFinitePoly K c) =
        Polynomial.eval x (GaussianWhoWhere.QFinitePoly K c) *
        Polynomial.eval y (GaussianWhoWhere.QFinitePoly K c))
  (k : Fin K) : c k = 0
```

This is the finite Hermite--Pochhammer rigidity theorem.  It has no
analytic socket.

### B.2. `where_rigidity_of_oddLogSample_from_jensenCartwright`

Source:

```text
GaussianWhoWhere/Infinite/JensenFinalPipeline.lean
```

Statement:

```lean
theorem where_rigidity_of_oddLogSample_from_jensenCartwright
    (hJC : JensenCartwrightLinearZeroBound)
    {Q : ℂ → ℂ}
    (hQ : FiniteExpType Q)
    (hQdiff : Differentiable ℂ Q)
    (hQnz : ∀ z : ℂ, Q z ≠ 0)
    (hQ0 : Q 0 = 1)
    (hLog : AnalyticOnNhd ℂ (complexLogDeriv Q) Set.univ)
    (hWhere : InfiniteWhere Q)
    (I :
      TwoIncommensurableSampledWhoInputs Q
        (fun u : ℕ → ℂ =>
          Nonempty (LinearZeroBoundBeatingLogSample u)))
    {a b : ℝ}
    (ha : I.inputs.input₁.a = (a : ℂ))
    (hb : I.inputs.input₂.a = (b : ℂ))
    (hA : I.inputs.input₁.A ≠ 0) (hB : I.inputs.input₂.A ≠ 0)
    (hirr : Irrational (a / b)) :
    Q = fun _ : ℂ => 1
```

`#check` form:

```lean
GaussianWhoWhere.where_rigidity_of_oddLogSample_from_jensenCartwright
  (hJC : GaussianWhoWhere.JensenCartwrightLinearZeroBound)
  {Q : ℂ → ℂ}
  (hQ : GaussianWhoWhere.FiniteExpType Q)
  (hQdiff : Differentiable ℂ Q)
  (hQnz : ∀ z : ℂ, Q z ≠ 0)
  (hQ0 : Q 0 = 1)
  (hLog :
    AnalyticOnNhd ℂ (GaussianWhoWhere.complexLogDeriv Q) Set.univ)
  (hWhere : GaussianWhoWhere.InfiniteWhere Q)
  (I :
    GaussianWhoWhere.TwoIncommensurableSampledWhoInputs Q
      fun u => Nonempty
        (GaussianWhoWhere.LinearZeroBoundBeatingLogSample u))
  {a b : ℝ}
  (ha : I.inputs.input₁.a = ↑a)
  (hb : I.inputs.input₂.a = ↑b)
  (hA : I.inputs.input₁.A ≠ 0)
  (hB : I.inputs.input₂.A ≠ 0)
  (hirr : Irrational (a / b)) :
  Q = fun x => 1
```

The only named analytic socket in this theorem is
`JensenCartwrightLinearZeroBound`.  The remaining assumptions are
concrete regularity, nonvanishing, normalization, Where, and sampled
Who-data hypotheses.

### B.3. `bridgeC_where_firstOrder_freezes_Re`

Source:

```text
GaussianWhoWhere/Infinite/FunctionalEquationFreezing.lean
```

Statement:

```lean
theorem bridgeC_where_firstOrder_freezes_Re
    {eps h : ℝ} {D : ℂ}
    (hD : IsPureImagComplex D) (hDnz : D ≠ 0) :
    (-((eps : ℂ) * (h : ℂ)) / D).re = 0
```

`#check` form:

```lean
GaussianWhoWhere.bridgeC_where_firstOrder_freezes_Re
  {eps h : ℝ} {D : ℂ}
  (hD : GaussianWhoWhere.IsPureImagComplex D)
  (hDnz : D ≠ 0) :
  (-(↑eps * ↑h) / D).re = 0
```

This theorem is pure complex algebra.  It does not depend on any
analytic socket.

### B.4. `ZetaBridgeCProfile` and zeta projections

Source:

```text
GaussianWhoWhere/ZetaBridge/Basic.lean
```

Profile:

```lean
structure ZetaBridgeCProfile where
  zetaLike : ℂ → ℂ
  completedLike : ℂ → ℂ
  logDerivLike : ℂ → ℂ
  bridgeA_dirichlet : BridgeA_DirichletLike zetaLike
  bridgeA_euler : BridgeA_EulerProductLike zetaLike
  bridgeAprime : BridgeAprime_LogDerivLike zetaLike logDerivLike
  where_completed : CompletedWhereLike completedLike
```

Projection theorems:

```lean
theorem zetaBridgeCProfile_has_where
    (P : ZetaBridgeCProfile) :
    CompletedWhereLike P.completedLike

theorem zetaBridgeCProfile_has_who_dirichlet
    (P : ZetaBridgeCProfile) :
    BridgeA_DirichletLike P.zetaLike

theorem zetaBridgeCProfile_has_who_euler
    (P : ZetaBridgeCProfile) :
    BridgeA_EulerProductLike P.zetaLike

theorem zetaBridgeCProfile_has_logDeriv_bridge
    (P : ZetaBridgeCProfile) :
    BridgeAprime_LogDerivLike P.zetaLike P.logDerivLike
```

Concrete Dirichlet-side witnesses:

```lean
theorem riemannZeta_bridgeA_dirichlet :
    BridgeA_DirichletLike riemannZeta

theorem riemannZeta_has_dirichlet_bridge :
    BridgeA_DirichletLike riemannZeta

theorem riemannZeta_bridgeA_dirichlet_natAddOne :
    BridgeA_DirichletLike riemannZeta
```

These witnesses use Mathlib's Dirichlet-series theorems on the right
half-plane.  The Euler-product and Bridge A' layers remain typed
interfaces here.

### B.5. BSD Who, Where, and compatibility structures

Source:

```text
BSDBridgeC/WhoWhere/Basic.lean
```

Who data:

```lean
structure BSDWhoData where
  torsion : TorsionData
  sha : ShaData
  tamagawa : TamagawaData
  regulator : RegulatorData
  period : PeriodData
```

Central Taylor data:

```lean
structure CentralTaylorData where
  order : ℕ
  leadingCoeff : ℂ
```

Where data:

```lean
structure BSDWhereData where
  L : ℂ → ℂ
  rootNumber : ℂ
  centralTaylor : CentralTaylorData
  functionalEquationAtCenter : Prop
```

Compatibility node:

```lean
structure BSDWhoWhereCompatible
    (who : BSDWhoData) (where_ : BSDWhereData) where
  leadingCoefficientFormula : Prop
  rankOrderCompatibility : Prop
```

This is the BSD Bridge C node in its smallest form: heterogeneous
Who-data, central Where-data, and two named compatibility sockets.

### B.6. `bsd_closeabilityAudit_hygieneClean`

Source:

```text
BSDBridgeC/Profile/CloseabilityAudit.lean
```

Hygiene predicate:

```lean
def CloseabilityRegistryHygieneClean
    (entries : List CloseabilityAuditEntry) : Prop :=
  closeabilityCountBy CloseabilityStatus.isCloseableNow entries = 0
```

Theorem:

```lean
theorem bsd_closeabilityAudit_hygieneClean :
    CloseabilityRegistryHygieneClean bsd_closeabilityAudit
```

Alias:

```lean
theorem bsd_closeabilityAudit_has_no_closeableNow :
    closeabilityCountBy CloseabilityStatus.isCloseableNow
      bsd_closeabilityAudit = 0
```

This is a registry-hygiene theorem.  It is not a mathematical theorem
about BSD; it is the type-level guard that the current closeability
registry contains no unresolved `closeableNow` entry.

### B.7. Typed leaf count theorems

Source:

```text
BSDBridgeC/Profile/LeafLocalization.lean
```

Typed lists:

```lean
bsd_closedLeafIds : List BSDLeafId
bsd_openLeafIds : List BSDLeafId
bsd_fullyRefinedLeafIds : List BSDLeafId
```

Count theorems:

```lean
theorem bsd_closedLeafIds_count :
    bsd_closedLeafIds.length = 4

theorem bsd_openLeafIds_count :
    bsd_openLeafIds.length = 12

theorem bsd_fullyRefinedLeafIds_count :
    bsd_fullyRefinedLeafIds.length = 16
```

All three are closed by `rfl`, because the underlying lists are
literal lists.

### B.8. `JensenCartwrightLinearZeroBound`

Source:

```text
GaussianWhoWhere/Infinite/JensenCartwrightInterface.lean
```

Definition:

```lean
def JensenCartwrightLinearZeroBound : Prop :=
  FiniteExpTypeLinearZeroBound
```

The source file describes it as the canonical Jensen / Cartwright
socket:

```text
nonzero finite exponential type
  → linear real-zero counting upper bound
```

It is intentionally a named `Prop`, not an `axiom`.  Downstream
theorems consume it as a hypothesis.  When one internalizes the
classical Jensen / Cartwright theorem, the proof is meant to slot into
this named socket without changing the rest of the C-HP infinite
pipeline.

## Appendix E. V1-to-V4 Refinement Trace

Appendices C and D are reserved for material migrated from the earlier
Bridge C paper.  This appendix records the new BSD-side refinement
trace: how the leaf-localization profile evolves as the scaffold is
recursively decomposed.

The source file is:

```text
BSDBridgeC/Profile/LeafLocalization.lean
```

The trace is intentionally non-destructive.  Each refinement introduces
a new profile while preserving the earlier profile.  Thus the
development contains a sequence of profiles, not a single profile that
is overwritten in place.

### E.1. The four profile definitions

The four profile definitions are:

```lean
bsd_leafLocalizationProfile
bsd_refinedShaLeafLocalizationProfile
bsd_refinedShaAndCompatibilityLeafLocalizationProfile
bsd_fullyRefinedLeafLocalizationProfile
```

They all have the same branch:

```lean
branch := .bsd
```

and they all retain the same four closed leaves:

```text
torsion
tamagawa
regulator
period
```

The refinements only change the open side.  The closed-leaf count
therefore remains invariant:

```lean
bsd_leafLocalizationProfile_closedCount = 4
bsd_refinedShaLeafLocalizationProfile_closedCount = 4
bsd_refinedShaAndCompatibilityLeafLocalizationProfile_closedCount = 4
bsd_fullyRefinedLeafLocalizationProfile_closedCount = 4
```

The open-leaf count grows as granularity increases:

```lean
bsd_leafLocalizationProfile_openCount = 2
bsd_refinedShaLeafLocalizationProfile_openCount = 5
bsd_refinedShaAndCompatibilityLeafLocalizationProfile_openCount = 7
bsd_fullyRefinedLeafLocalizationProfile_openCount = 12
```

The growth of the open count is not a claim that the problem becomes
harder.  It is a claim that the open content has been decomposed into
more named exits.

### E.2. Phase V1: coarse BSD leaf localization

The first profile is:

```lean
def bsd_leafLocalizationProfile : LeafLocalizationProfile
```

Its leaves are:

```text
closed:
  torsion
  tamagawa
  regulator
  period

open:
  Sha finiteness
  higher Euler systems r >= 2
```

The associated count theorems are:

```lean
bsd_leafLocalizationProfile_closedCount :
  bsd_leafLocalizationProfile.closedCount = 4

bsd_leafLocalizationProfile_openCount :
  bsd_leafLocalizationProfile.openCount = 2
```

This is the coarse localization layer.  At this stage the residual
open content is summarized by two broad leaves: Sha and higher-rank
Euler/Kolyvagin input.

### E.3. Phase V2: Sha refinement

The next profile is:

```lean
def bsd_refinedShaLeafLocalizationProfile :
    LeafLocalizationProfile
```

It preserves the four closed leaves and replaces the coarse Sha leaf

```text
Sha finiteness
```

by four named Sha/Selmer sub-leaves:

```text
Sha finiteSocket
Selmer-Sha injection socket
Selmer-Sha surjection socket
Selmer-Sha exactness socket
```

The higher-rank leaf remains coarse:

```text
higher Euler systems r >= 2
```

Thus the open side becomes:

```text
open:
  Sha finiteSocket
  Selmer-Sha injection socket
  Selmer-Sha surjection socket
  Selmer-Sha exactness socket
  higher Euler systems r >= 2
```

The count theorems are:

```lean
bsd_refinedShaLeafLocalizationProfile_closedCount :
  bsd_refinedShaLeafLocalizationProfile.closedCount = 4

bsd_refinedShaLeafLocalizationProfile_openCount :
  bsd_refinedShaLeafLocalizationProfile.openCount = 5
```

This is the first recursive refinement of an open leaf:

```text
one coarse Sha leaf → four named Sha/Selmer sub-leaves.
```

The older `sha_finiteness_open_leaf` remains defined for backward
compatibility.  The refined profile does not erase it; it replaces it
only in the new profile's leaf list.

### E.4. Phase V3: compatibility-node refinement

The third profile is:

```lean
def bsd_refinedShaAndCompatibilityLeafLocalizationProfile :
    LeafLocalizationProfile
```

It keeps the Sha refinement and adds two open leaves from the Bridge C
compatibility node `BSDWhoWhereCompatible`:

```text
BSD leading coefficient formula
BSD rank/order compatibility
```

These correspond to the fields:

```lean
leadingCoefficientFormula : Prop
rankOrderCompatibility : Prop
```

The open side is now:

```text
open:
  Sha finiteSocket
  Selmer-Sha injection socket
  Selmer-Sha surjection socket
  Selmer-Sha exactness socket
  BSD leading coefficient formula
  BSD rank/order compatibility
  higher Euler systems r >= 2
```

The count theorems are:

```lean
bsd_refinedShaAndCompatibilityLeafLocalizationProfile_closedCount :
  bsd_refinedShaAndCompatibilityLeafLocalizationProfile.closedCount = 4

bsd_refinedShaAndCompatibilityLeafLocalizationProfile_openCount :
  bsd_refinedShaAndCompatibilityLeafLocalizationProfile.openCount = 7
```

This phase is important because the Bridge C node itself becomes a
typed-exit node.  The compatibility relation is not treated as a
single opaque hypothesis; its two sockets are visible as leaves.

### E.5. Phase V4: fully refined BSD profile

The fourth profile is:

```lean
def bsd_fullyRefinedLeafLocalizationProfile :
    LeafLocalizationProfile
```

It keeps the four Sha sub-leaves and the two compatibility leaves, and
replaces the coarse higher-rank leaf

```text
higher Euler systems r >= 2
```

by six named higher-rank sub-leaves:

```text
higher Euler norm compatibility
higher Kolyvagin local relations
higher Kolyvagin derivative law
higher-rank regulator compatibility
higher-rank Selmer control
higher-rank analytic/algebraic rank compatibility
```

The full open side is therefore:

```text
open:
  Sha finiteSocket
  Selmer-Sha injection socket
  Selmer-Sha surjection socket
  Selmer-Sha exactness socket
  BSD leading coefficient formula
  BSD rank/order compatibility
  higher Euler norm compatibility
  higher Kolyvagin local relations
  higher Kolyvagin derivative law
  higher-rank regulator compatibility
  higher-rank Selmer control
  higher-rank analytic/algebraic rank compatibility
```

The count theorems are:

```lean
bsd_fullyRefinedLeafLocalizationProfile_closedCount :
  bsd_fullyRefinedLeafLocalizationProfile.closedCount = 4

bsd_fullyRefinedLeafLocalizationProfile_openCount :
  bsd_fullyRefinedLeafLocalizationProfile.openCount = 12
```

This is the fully refined BSD-branch profile used by the V4 typed
identifier layer.  It is the point at which the BSD branch has:

```text
4 closed leaves
12 open leaves
16 total leaves
```

### E.6. Count table

The refinement trace can be summarized as follows:

| Phase | Lean profile | Closed | Open | Total | Change |
|---|---|---:|---:|---:|---|
| V1 | `bsd_leafLocalizationProfile` | 4 | 2 | 6 | coarse Sha + coarse higher-rank leaves |
| V2 | `bsd_refinedShaLeafLocalizationProfile` | 4 | 5 | 9 | Sha leaf refined into 4 sub-leaves |
| V3 | `bsd_refinedShaAndCompatibilityLeafLocalizationProfile` | 4 | 7 | 11 | compatibility node adds 2 leaves |
| V4 | `bsd_fullyRefinedLeafLocalizationProfile` | 4 | 12 | 16 | higher-rank leaf refined into 6 sub-leaves |

The concrete monotone chain is recorded by:

```lean
theorem bsd_leafLocalization_openCount_chain :
    bsd_leafLocalizationProfile.openCount
      ≤ bsd_refinedShaLeafLocalizationProfile.openCount ∧
    bsd_refinedShaLeafLocalizationProfile.openCount
      ≤ bsd_refinedShaAndCompatibilityLeafLocalizationProfile.openCount ∧
    bsd_refinedShaAndCompatibilityLeafLocalizationProfile.openCount
      ≤ bsd_fullyRefinedLeafLocalizationProfile.openCount
```

This theorem proves the concrete chain:

```text
2 ≤ 5 ≤ 7 ≤ 12.
```

It is not a general monotonicity theorem about all possible
refinements.  It is a witness that the four registered profiles in
this package form the stated refinement chain.

### E.7. Typed V4 overlay

The `BSDLeafId` layer is not a fifth profile.  It is a typed overlay on
the fully refined profile.  Its source is still:

```text
BSDBridgeC/Profile/LeafLocalization.lean
```

The typed lists are:

```lean
bsd_closedLeafIds
bsd_openLeafIds
bsd_fullyRefinedLeafIds
```

with count theorems:

```lean
bsd_closedLeafIds_count : bsd_closedLeafIds.length = 4
bsd_openLeafIds_count : bsd_openLeafIds.length = 12
bsd_fullyRefinedLeafIds_count : bsd_fullyRefinedLeafIds.length = 16
```

These close by `rfl`, because the lists are literal.  They correspond
to the counts of `bsd_fullyRefinedLeafLocalizationProfile`, but their
purpose is different.  The profile records human-readable
`RefinementLeaf` cells; `BSDLeafId` turns those cells into values of a
decidable inductive type.

The bridge:

```lean
BSDLeafId.toRefinementLeaf : BSDLeafId → RefinementLeaf
```

keeps the typed and string registries synchronized.

### E.8. Methodological reading

The refinement trace supports three methodological points.

First, open-leaf growth measures granularity, not increasing
difficulty.  The move from `2` to `12` open leaves means the scaffold
has found more precise exits, not that the mathematical problem has
become larger.

Second, the closed-leaf list is invariant across the trace.  Torsion,
Tamagawa data, regulator data, and period data remain classified as
closed at this scaffold level.  The refinements all occur inside the
open content.

Third, every refinement is preserved as a named profile.  A reader can
choose the coarse view, the Sha-refined view, the compatibility-refined
view, or the fully refined view.  The development does not hide the
history of refinement.  It records it as a sequence of typed profiles.

This is the operational form of the leaf-localization slogan:

```text
Open mathematics is not a fog.
It is a refinement trace ending in named leaves.
```
