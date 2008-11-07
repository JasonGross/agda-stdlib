------------------------------------------------------------------------
-- Nullary relations
------------------------------------------------------------------------

-- Some operations on/properties of nullary relations, i.e. sets.

module Relation.Nullary where

open import Data.Product
open import Data.Sum
open import Data.Empty
open import Data.Function
open import Data.Bool

open import Category.Monad

open import Relation.Nullary.Core public
open import Relation.Binary.PropositionalEquality
open ≡-Reasoning

------------------------------------------------------------------------
-- Equivalence

infix 4 _⇔_

_⇔_ : Set -> Set -> Set
P ⇔ Q = (P -> Q) × (Q -> P)

------------------------------------------------------------------------
-- Negation

contradiction : forall {P whatever} -> P -> ¬ P -> whatever
contradiction p ¬p = ⊥-elim (¬p p)

contravariant : forall {P Q} -> (P -> Q) -> ¬ Q -> ¬ P
contravariant f ¬q p = contradiction (f p) ¬q

-- Note also the following use of flip:

private
  note : forall {P Q} -> (P -> ¬ Q) -> Q -> ¬ P
  note = flip

-- And the following use of contradiction:

private
  ¬¬-add : {P : Set} -> P -> ¬ ¬ P
  ¬¬-add = contradiction

¬¬-map : forall {P Q} -> (P -> Q) -> ¬ ¬ P -> ¬ ¬ Q
¬¬-map f = contravariant (contravariant f)

¬¬-push : {P : Set} {Q : P -> Set} ->
          ¬ ¬ ((x : P) -> Q x) -> (x : P) -> ¬ ¬ Q x
¬¬-push ¬¬P⟶Q P ¬Q = ¬¬P⟶Q (\P⟶Q -> ¬Q (P⟶Q P))

¬¬-drop : {P : Set} -> ¬ ¬ ¬ P -> ¬ P
¬¬-drop ¬¬¬P P = ¬¬¬P (\ ¬P -> ¬P P)

¬¬-drop-Dec : {P : Set} -> Dec P -> ¬ ¬ P -> P
¬¬-drop-Dec (yes p) ¬¬p = p
¬¬-drop-Dec (no ¬p) ¬¬p = ⊥-elim (¬¬p ¬p)

-- A double-negation-translated variant of excluded middle.

excluded-middle : {P : Set} -> ¬ ¬ Dec P
excluded-middle ¬h = ¬h (no (\p -> ¬h (yes p)))

-- Double-negation is a monad (if we assume that all elements of ¬ ¬ P
-- are equal).

¬¬-Monad : RawMonad (\P -> ¬ ¬ P)
¬¬-Monad = record
  { return = contradiction
  ; _>>=_  = \x f -> ¬¬-drop (¬¬-map f x)
  }

-- Call with current continuation in the double-negation monad, or, if
-- you will, a double-negation translation of Peirce's law.

call/cc : forall {P whatever} ->
          ((P -> ¬ ¬ whatever) -> ¬ ¬ P) -> ¬ ¬ P
call/cc hyp ¬p = hyp (\p _ -> ¬p p) ¬p

∃⟶¬∀¬ : {A : Set} {P : A -> Set} ->
        ∃ P -> ¬ (forall x -> ¬ P x)
∃⟶¬∀¬ = flip Σ-uncurry

∀⟶¬∃¬ : {A : Set} {P : A -> Set} ->
        (forall x -> P x) -> ¬ ∃ \x -> ¬ P x
∀⟶¬∃¬ ∀xPx (x , ¬Px) = ¬Px (∀xPx x)

¬∃⟶∀¬ : {A : Set} {P : A -> Set} ->
        ¬ ∃ (\x -> P x) -> forall x -> ¬ P x
¬∃⟶∀¬ = Σ-curry

∀¬⟶¬∃ : {A : Set} {P : A -> Set} ->
        (forall x -> ¬ P x) -> ¬ ∃ (\x -> P x)
∀¬⟶¬∃ = Σ-uncurry

∃¬⟶¬∀ : {A : Set} {P : A -> Set} ->
        ∃ (\x -> ¬ P x) -> ¬ (forall x -> P x)
∃¬⟶¬∀ = flip ∀⟶¬∃¬

------------------------------------------------------------------------
-- Decidable relations

decToBool : forall {P} -> Dec P -> Bool
decToBool (yes _) = true
decToBool (no  _) = false

True : forall {P} -> Dec P -> Set
True Q = T (decToBool Q)

False : forall {P} -> Dec P -> Set
False Q = T (not (decToBool Q))

witnessToTruth : forall {P} {Q : Dec P} -> True Q -> P
witnessToTruth {Q = yes p} _  = p
witnessToTruth {Q = no  _} ()

------------------------------------------------------------------------
-- Injections

-- I cannot be bothered to generalise to an arbitrary setoid.

Injective : forall {A B} -> (A -> B) -> Set
Injective f = forall {x y} -> f x ≡ f y -> x ≡ y

_LeftInverseOf_ : forall {A B} -> (B -> A) -> (A -> B) -> Set
f LeftInverseOf g = forall x -> f (g x) ≡ x

record Injection A B : Set where
  field
    to        : A -> B
    injective : Injective to

record LeftInverse A B : Set where
  field
    to           : A -> B
    from         : B -> A
    left-inverse : from LeftInverseOf to

  injective : Injective to
  injective {x} {y} eq = begin
    x            ≡⟨ ≡-sym (left-inverse x)  ⟩
    from (to x)  ≡⟨ ≡-cong from eq ⟩
    from (to y)  ≡⟨ left-inverse y ⟩
    y            ∎

  injection : Injection A B
  injection = record { to = to; injective = injective }
