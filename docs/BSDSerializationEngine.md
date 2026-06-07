# BSD Serialization Engine, Reinterpreted

This note explains, for human readers, what the Lean DAG of
`BSDBridgeC` is doing and — equally important — what it is *not*
doing. It is not a mathematical claim. It is a reading guide to the
typed scaffolding inside `BSDBridgeC/WhoWhere/Basic.lean`.

---

## 1. The joke specification

A first pass at "what is BSD?" can be drafted as the following
tongue-in-cheek API specification:

```
BSDSerializationEngine.encode :
  input  field[0] : torsion order
         field[1] : Sha order
         field[2] : Tamagawa factors
         field[3] : regulator
         field[4] : period
  output : leading Taylor coefficient of L(E, s) at s = 1
```

The picture is appealing because it lines up the five "Who-side"
ingredients of the BSD formula with a single "Where-side" output. It
is also wrong as soon as one tries to take it literally.

There is no `encode` function in the engineering sense. The output
scalar is not a serialization of the inputs; the inputs are not even
all known to be finite (Sha); and the formula relating them is not a
theorem we can call.

The remainder of this document corrects the metaphor.

---

## 2. Why "serialization" is the wrong word

A serialization, in the software sense, has three properties that BSD
does not have:

1. **Losslessness.** A serialized representation lets you decode the
   original inputs. The scalar `L*(E, 1)` does **not** determine the
   tuple `(|E(K)_tors|, |Sha(E/K)|, prod c_v, Reg(E/K), Omega(E/K))`;
   many distinct tuples could in principle produce the same product
   if the conjectural BSD formula is read in reverse.

2. **Computability.** Serialization is a function you call. The
   BSD formula is, today, a conjectural identity. We do not have a
   function `(Who, Where) -> Verdict` that returns `True` for
   compatible pairs.

3. **Hash collision rhetoric.** Phrases like "zero collisions" or
   "perfect hash" do not survive contact with arithmetic geometry,
   because Sha is not even known to be finite in general.

So `BSDSerializationEngine` is a metaphor that flatters software
intuition while obscuring the actual structure. The actual structure
is a *constraint*, not a function.

---

## 3. Constraint-satisfaction interpretation

Replace "serialization" with "heterogeneous constraint satisfaction":

- **Who side.** A heterogeneous bundle of arithmetic data — torsion,
  Sha, Tamagawa factors, regulator, period — none of which is a
  scalar of the same kind as the output.

- **Where side.** A central Taylor profile of an L-function-like
  object at `s = 1`: the function `L`, its root number, the center
  itself, the Taylor order, the leading coefficient, and a named
  functional-equation socket.

- **Bridge C.** The compatibility relation between Who and Where. It
  is not a function from Who to Where, nor from Where to Who. It is
  a relation that the pair `(Who, Where)` is required to satisfy.
  BSD is the assertion that this relation holds, and it remains
  open in this form.

The Lean DAG records this trichotomy as three typed transformations,
each a forgetful projection of an existing structure into a packaging
structure:

```
BSDWhoData            ->  BSDWhoHeterogeneousBundle
BSDWhereData          ->  BSDWhereCentralBundle
BSDWhoWhereCompatible ->  BSDCompatibilitySocketBundle
```

Each arrow is a `def` constructor; none of them introduces new
content. They make visible, at the type-signature level, what BSD
is actually asking for.

---

## 4. Lean objects

All of the objects below live in `BSDBridgeC/WhoWhere/Basic.lean`
(namespace `BSDBridgeC`). Each name is `#check`-able against the
compiled module.

### 4.1 Who side

- `BSDWhoData` — heterogeneous Who package with five fields:
  `torsion : TorsionData`, `sha : ShaData`,
  `tamagawa : TamagawaData`, `regulator : RegulatorData`,
  `period : PeriodData`.

- Field projections:
  `bsdWhoData_has_torsion`, `bsdWhoData_has_sha`,
  `bsdWhoData_has_tamagawa`, `bsdWhoData_has_regulator`,
  `bsdWhoData_has_period`.

- `BSDWhoHeterogeneousBundle` — Type-side packaging structure naming
  the five components as separate fields.

- `bsdWhoData_to_heterogeneousBundle` — forgetful constructor
  `BSDWhoData -> BSDWhoHeterogeneousBundle`.

### 4.2 Where side

- `BSDWhereData` — central-Taylor package: `L : ℂ → ℂ`,
  `rootNumber : ℂ`, `centralTaylor : CentralTaylorData`,
  `functionalEquationAtCenter : Prop`.

- `CentralTaylorData` — `order : ℕ`, `leadingCoeff : ℂ`, with
  projections `centralTaylor_order`, `centralTaylor_leadingCoeff`.

- Field projections:
  `bsdWhereData_has_L`, `bsdWhereData_has_rootNumber`,
  `bsdWhereData_has_centralTaylor`,
  `bsdWhereData_has_functionalEquationSocket`.

- `BSDWhereCentralBundle` — Type-side packaging structure with six
  fields, including the center value (`bsdCenter = 1`) and the named
  functional-equation socket as a `Prop` value.

- `bsdWhereData_to_centralBundle` — forgetful constructor
  `BSDWhereData -> BSDWhereCentralBundle`.

### 4.3 Compatibility (Bridge C node)

- `BSDWhoWhereCompatible` — two socket fields:
  `leadingCoefficientFormula : Prop`,
  `rankOrderCompatibility : Prop`.

- Field projections:
  `bsdWhoWhereCompatible_has_leadingCoefficientFormula`,
  `bsdWhoWhereCompatible_has_rankOrderCompatibility`.

- `BSDCompatibilitySocketBundle` — Type-side packaging structure
  with the two sockets as separately addressable `Prop` fields.

- `bsdWhoWhereCompatible_to_socketBundle` — forgetful constructor
  `BSDWhoWhereCompatible who where_ -> BSDCompatibilitySocketBundle who where_`.

- `bsdWhoWhereCompatible_socketPair` — flat `Prop × Prop`
  presentation of the same two sockets.

### 4.4 What the bundles are for

The bundles are not refinements of `BSDWhoData`,
`BSDWhereData`, `BSDWhoWhereCompatible`. They are *namings*. The
information content is unchanged; what changes is that every
component now has a stable theorem name that the prose and the
forthcoming paper can cite. This is the same discipline used in the
Bridge C zeta scaffold of `GaussianWhoWhere` (`ZetaBridgeCProfile`
and its projection theorems).

---

## 5. Non-claims

To prevent the metaphor of Section 1 from leaking into mathematical
claims, the following are explicitly **not** asserted by the Lean
development in this package:

- We do **not** prove the Birch–Swinnerton-Dyer conjecture.
- We do **not** prove finiteness of the Tate–Shafarevich group `Sha`.
- We do **not** compute `Sha`, the regulator, or the period.
- We do **not** prove that analytic rank equals algebraic rank.
- We do **not** prove modularity of elliptic curves beyond what
  Mathlib already provides.
- We do **not** prove the existence of higher-rank Euler systems or
  higher-rank Kolyvagin systems for rank `r ≥ 2`. Their inhabitation
  is exposed as a hypothesis (`HigherRankSocket E r`) in the
  signature of any theorem that depends on it.
- We do **not** claim that the leading coefficient `L*(E, 1)`
  determines the Who-side data by any decoding function. The
  serialization rhetoric of Section 1 is rejected.
- We do **not** discharge the functional equation. The Where bundle
  carries `functionalEquationAtCenter : Prop` as a socket value,
  forwarded unchanged from `BSDWhereData`.

No file in this package uses `sorry`, `admit`, or an `axiom`
declaration. Every gap is a structure field or a hypothesis in a
theorem signature.

---

## 6. One-sentence takeaway

> BSD is not a serialization engine. It is a Bridge C constraint
> node: heterogeneous Who-data and central Where-data are forced to
> satisfy one compatibility relation at the functional-equation
> center, and the Lean DAG of `BSDBridgeC` makes each part of that
> constraint a separately addressable, `#check`-able typed object.
