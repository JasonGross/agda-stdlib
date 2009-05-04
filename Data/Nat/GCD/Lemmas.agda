------------------------------------------------------------------------
-- Boring lemmas used in Data.Nat.GCD
------------------------------------------------------------------------

module Data.Nat.GCD.Lemmas where

open import Data.Nat
import Data.Nat.Properties as NatProp
open NatProp.SemiringSolver
open import Relation.Binary.PropositionalEquality
open ≡-Reasoning
open import Data.Function

lem₀ = solve 2 (λ n k → n :+ (con 1 :+ k)  :=  con 1 :+ n :+ k) refl

lem₁ : ∀ i j → 2 + i ≤′ 2 + j + i
lem₁ i j = NatProp.≤⇒≤′ $ s≤s $ s≤s $ NatProp.n≤m+n j i

lem₂ : ∀ d x {k n} →
       d + x * k ≡ x * n → d + x * (n + k) ≡ 2 * x * n
lem₂ d x {k} {n} eq = begin
  d + x * (n + k)    ≡⟨ solve 4 (λ d x n k → d :+ x :* (n :+ k)
                                         :=  d :+ x :* k :+ x :* n)
                                refl d x n k ⟩
  d + x * k + x * n  ≡⟨ cong₂ _+_ eq refl ⟩
  x * n + x * n      ≡⟨ solve 3 (λ x n k → x :* n :+ x :* n
                                       :=  con 2 :* x :* n)
                                 refl x n k ⟩
  2 * x * n          ∎

lem₃ : ∀ d x {i k n} →
       d + (1 + x + i) * k ≡ x * n →
       d + (1 + x + i) * (n + k) ≡ (1 + 2 * x + i) * n
lem₃ d x {i} {k} {n} eq = begin
  d + y * (n + k)      ≡⟨ solve 4 (λ d y n k → d :+ y :* (n :+ k)
                                           :=  (d :+ y :* k) :+ y :* n)
                                  refl d y n k ⟩
  (d + y * k) + y * n  ≡⟨ cong₂ _+_ eq refl ⟩
  x * n + y * n        ≡⟨ solve 3 (λ x n i → x :* n :+ (con 1 :+ x :+ i) :* n
                                         :=  (con 1 :+ con 2 :* x :+ i) :* n)
                                  refl x n i ⟩
  (1 + 2 * x + i) * n  ∎
  where y = 1 + x + i

lem₄ : ∀ d y {k i} n →
       d + y * k ≡ (1 + y + i) * n →
       d + y * (n + k) ≡ (1 + 2 * y + i) * n
lem₄ d y {k} {i} n eq = begin
  d + y * (n + k)          ≡⟨ solve 4 (λ d y n k → d :+ y :* (n :+ k)
                                               :=  d :+ y :* k :+ y :* n)
                                      refl d y n k ⟩
  d + y * k + y * n        ≡⟨ cong₂ _+_ eq refl ⟩
  (1 + y + i) * n + y * n  ≡⟨ solve 3 (λ y i n → (con 1 :+ y :+ i) :* n :+ y :* n
                                             :=  (con 1 :+ con 2 :* y :+ i) :* n)
                                      refl y i n ⟩
  (1 + 2 * y + i) * n      ∎

private
  distrib-comm =
    solve 3 (λ x k n → x :* k :+ x :* n  :=  x :* (n :+ k)) refl

lem₅ : ∀ d x {n k} →
       d + x * n ≡ x * k →
       d + 2 * x * n ≡ x * (n + k)
lem₅ d x {n} {k} eq = begin
  d + 2 * x * n      ≡⟨ solve 3 (λ d x n → d :+ con 2 :* x :* n
                                       :=  d :+ x :* n :+ x :* n)
                                refl d x n ⟩
  d + x * n + x * n  ≡⟨ cong₂ _+_ eq refl ⟩
  x * k + x * n      ≡⟨ distrib-comm x k n ⟩
  x * (n + k)        ∎

lem₆ : ∀ d x {n i k} →
       d + x * n ≡ (1 + x + i) * k →
       d + (1 + 2 * x + i) * n ≡ (1 + x + i) * (n + k)
lem₆ d x {n} {i} {k} eq = begin
  d + (1 + 2 * x + i) * n  ≡⟨ solve 4 (λ d x i n → d :+ (con 1 :+ con 2 :* x :+ i) :* n
                                               :=  d :+ x :* n :+ (con 1 :+ x :+ i) :* n)
                                      refl d x i n ⟩
  d + x * n + y * n        ≡⟨ cong₂ _+_ eq refl ⟩
  y * k + y * n            ≡⟨ distrib-comm y k n ⟩
  y * (n + k)              ∎
  where y = 1 + x + i

lem₇ : ∀ d y {i} n {k} →
       d + (1 + y + i) * n ≡ y * k →
       d + (1 + 2 * y + i) * n ≡ y * (n + k)
lem₇ d y {i} n {k} eq = begin
  d + (1 + 2 * y + i) * n      ≡⟨ solve 4 (λ d y i n → d :+ (con 1 :+ con 2 :* y :+ i) :* n
                                                   :=  d :+ (con 1 :+ y :+ i) :* n :+ y :* n)
                                          refl d y i n ⟩
  d + (1 + y + i) * n + y * n  ≡⟨ cong₂ _+_ eq refl ⟩
  y * k + y * n                ≡⟨ distrib-comm y k n ⟩
  y * (n + k)                  ∎
