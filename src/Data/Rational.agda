------------------------------------------------------------------------
-- The Agda standard library
--
-- Rational numbers
------------------------------------------------------------------------

module Data.Rational where

import Data.Bool.Properties as Bool
open import Function
open import Data.Integer as ℤ using (ℤ; ∣_∣; +_; -_)
open import Data.Integer.Divisibility as ℤDiv using (Coprime)
import Data.Integer.Properties as ℤ
open import Data.Nat.Divisibility as ℕDiv using (_∣_)
import Data.Nat.Coprimality as C
open import Data.Nat as ℕ using (ℕ; zero; suc)
import Level
open import Relation.Nullary.Decidable
open import Relation.Nullary
open import Relation.Binary
import Relation.Binary.PropositionalEquality as PropEq
open PropEq using (_≡_; refl; cong; cong₂)
open PropEq.≡-Reasoning

------------------------------------------------------------------------
-- The definition

-- Rational numbers in reduced form. Note that there is exactly one
-- representative for every rational number. (This is the reason for
-- using "True" below. If Agda had proof irrelevance, then it would
-- suffice to use "isCoprime : Coprime numerator denominator".)

record ℚ : Set where
  field
    numerator     : ℤ
    denominator-1 : ℕ
    isCoprime     : True (C.coprime? ∣ numerator ∣ (suc denominator-1))

  denominator : ℤ
  denominator = + suc denominator-1

  coprime : Coprime numerator denominator
  coprime = toWitness isCoprime

-- Constructs rational numbers. The arguments have to be in reduced
-- form.

infixl 7 _÷_

_÷_ : (numerator : ℤ) (denominator : ℕ)
      {coprime : True (C.coprime? ∣ numerator ∣ denominator)}
      {≢0 : False (ℕ._≟_ denominator 0)} →
      ℚ
(n ÷ zero) {≢0 = ()}
(n ÷ suc d) {c} =
  record { numerator = n; denominator-1 = d; isCoprime = c }

private

  -- Note that the implicit arguments do not need to be given for
  -- concrete inputs:

  0/1 : ℚ
  0/1 = + 0 ÷ 1

  -½ : ℚ
  -½ = - + 1 ÷ 2

------------------------------------------------------------------------
-- Equality

-- Equality of rational numbers.

infix 4 _≃_

_≃_ : Rel ℚ Level.zero
p ≃ q = P.numerator ℤ.* Q.denominator ≡
        Q.numerator ℤ.* P.denominator
  where module P = ℚ p; module Q = ℚ q

-- _≃_ coincides with propositional equality.

≡⇒≃ : _≡_ ⇒ _≃_
≡⇒≃ refl = refl

≃⇒≡ : _≃_ ⇒ _≡_
≃⇒≡ {p} {q} = helper P.numerator P.denominator-1 P.isCoprime
                     Q.numerator Q.denominator-1 Q.isCoprime
  where
  module P = ℚ p; module Q = ℚ q

  helper : ∀ n₁ d₁ c₁ n₂ d₂ c₂ →
           n₁ ℤ.* + suc d₂ ≡ n₂ ℤ.* + suc d₁ →
           (n₁ ÷ suc d₁) {c₁} ≡ (n₂ ÷ suc d₂) {c₂}
  helper n₁ d₁ c₁ n₂ d₂ c₂ eq
    with Poset.antisym ℕDiv.poset 1+d₁∣1+d₂ 1+d₂∣1+d₁
    where
    1+d₁∣1+d₂ : suc d₁ ∣ suc d₂
    1+d₁∣1+d₂ = ℤDiv.coprime-divisor (+ suc d₁) n₁ (+ suc d₂)
                  (C.sym $ toWitness c₁) $
                  ℕDiv.divides ∣ n₂ ∣ (begin
                    ∣ n₁ ℤ.* + suc d₂ ∣  ≡⟨ cong ∣_∣ eq ⟩
                    ∣ n₂ ℤ.* + suc d₁ ∣  ≡⟨ ℤ.abs-*-commute n₂ (+ suc d₁) ⟩
                    ∣ n₂ ∣ ℕ.* suc d₁    ∎)

    1+d₂∣1+d₁ : suc d₂ ∣ suc d₁
    1+d₂∣1+d₁ = ℤDiv.coprime-divisor (+ suc d₂) n₂ (+ suc d₁)
                  (C.sym $ toWitness c₂) $
                  ℕDiv.divides ∣ n₁ ∣ (begin
                    ∣ n₂ ℤ.* + suc d₁ ∣  ≡⟨ cong ∣_∣ (PropEq.sym eq) ⟩
                    ∣ n₁ ℤ.* + suc d₂ ∣  ≡⟨ ℤ.abs-*-commute n₁ (+ suc d₂) ⟩
                    ∣ n₁ ∣ ℕ.* suc d₂    ∎)

  helper n₁ d c₁ n₂ .d c₂ eq | refl with ℤ.cancel-*-right
                                           n₁ n₂ (+ suc d) (λ ()) eq
  helper n  d c₁ .n .d c₂ eq | refl | refl with Bool.proof-irrelevance c₁ c₂
  helper n  d c  .n .d .c eq | refl | refl | refl = refl

------------------------------------------------------------------------
-- Equality is decidable

infix 4 _≟_

_≟_ : Decidable {A = ℚ} _≡_
p ≟ q with ℚ.numerator p ℤ.* ℚ.denominator q ℤ.≟ ℚ.numerator q ℤ.* ℚ.denominator p
p ≟ q | yes pq≃qp = yes (≃⇒≡ pq≃qp)
p ≟ q | no ¬pq≃qp = no (¬pq≃qp ∘ ≡⇒≃)

------------------------------------------------------------------------
-- Ordering

infix  4 _≤_ _≤?_

data _≤_ : ℚ → ℚ → Set where
  p≤q : ∀ {p q} →
        ℚ.numerator p ℤ.* ℚ.denominator q ℤ.≤
        ℚ.numerator q ℤ.* ℚ.denominator p →
        p ≤ q

drop-p≤q : ∀ {p q} → p ≤ q →
           ℚ.numerator p ℤ.* ℚ.denominator q ℤ.≤
           ℚ.numerator q ℤ.* ℚ.denominator p
drop-p≤q (p≤q pq≤qp) = pq≤qp

_≤?_ : Decidable _≤_
p ≤? q with ℚ.numerator p ℤ.* ℚ.denominator q ℤ.≤? ℚ.numerator q ℤ.* ℚ.denominator p
p ≤? q | yes pq≤qp = yes (p≤q pq≤qp)
p ≤? q | no ¬pq≤qp = no (λ {(p≤q pq≤qp) → ¬pq≤qp pq≤qp})

decTotalOrder : DecTotalOrder _ _ _
decTotalOrder = record
  { Carrier         = ℚ
  ; _≈_             = _≡_
  ; _≤_             = _≤_
  ; isDecTotalOrder = record
      { isTotalOrder = record
          { isPartialOrder = record
              { isPreorder = record
                  { isEquivalence = PropEq.isEquivalence
                  ; reflexive     = refl′
                  ; trans         = trans
                  }
                ; antisym  = antisym
              }
          ; total          = total
          }
      ; _≟_          = _≟_
      ; _≤?_         = _≤?_
      }
  }
  where
  module ℤO = DecTotalOrder ℤ.decTotalOrder

  refl′ : _≡_ ⇒ _≤_
  refl′ {.q} {q} refl = p≤q ℤO.refl

  trans : Transitive _≤_
  trans {p} {q} {r} (p≤q x₁) (p≤q x₂)
    = p≤q
        (cancel-*-+-right-≤ _ _ _
         (assert
          (ℚ.numerator p) (ℚ.denominator p)
          (ℚ.numerator q) (ℚ.denominator q)
          (ℚ.numerator r) (ℚ.denominator r)
          (*-+-right-mono (ℚ.denominator-1 r) x₁)
          (*-+-right-mono (ℚ.denominator-1 p) x₂)))
    where
      open import Data.Integer.Properties
      import Algebra
      open Algebra.CommutativeRing commutativeRing

      assert : ∀ n₁ d₁ n₂ d₂ n₃ d₃ →
               n₁ ℤ.* d₂ ℤ.* d₃ ℤ.≤ n₂ ℤ.* d₁ ℤ.* d₃ →
               n₂ ℤ.* d₃ ℤ.* d₁ ℤ.≤ n₃ ℤ.* d₂ ℤ.* d₁ →
               n₁ ℤ.* d₃ ℤ.* d₂ ℤ.≤ n₃ ℤ.* d₁ ℤ.* d₂
      assert n₁ d₁ n₂ d₂ n₃ d₃ x₁ x₂
        rewrite *-assoc n₁ d₂ d₃
              | *-comm d₂ d₃
              | sym (*-assoc n₁ d₃ d₂)
              | *-assoc n₃ d₂ d₁
              | *-comm d₂ d₁
              | sym (*-assoc n₃ d₁ d₂)
              | *-assoc n₂ d₁ d₃
              | *-comm d₁ d₃
              | sym (*-assoc n₂ d₃ d₁)
              = ℤO.trans x₁ x₂

  antisym : Antisymmetric _≡_ _≤_
  antisym (p≤q x₁) (p≤q x₂) = ≃⇒≡ (ℤO.antisym x₁ x₂)

  total : Total _≤_
  total p q = [ inj₁ ∘′ p≤q , inj₂ ∘′ p≤q ]′
                (ℤO.total
                 (ℚ.numerator p ℤ.* ℚ.denominator q)
                 (ℚ.numerator q ℤ.* ℚ.denominator p))
    where
      open import Data.Sum
