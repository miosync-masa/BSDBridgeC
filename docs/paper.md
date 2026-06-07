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

