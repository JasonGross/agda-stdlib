------------------------------------------------------------------------
-- Products (variants for Set1)
------------------------------------------------------------------------

-- I want universe polymorphism.

module Data.Product1 where

open import Data.Function
open import Relation.Nullary

infixr 4 _,_
infixr 2 _×₀₁_ _×₁₀_ _×₁₁_

------------------------------------------------------------------------
-- Definition

data Σ₀₁ (a : Set) (b : a → Set1) : Set1 where
  _,_ : (x : a) (y : b x) → Σ₀₁ a b

data Σ₁₀ (a : Set1) (b : a → Set) : Set1 where
  _,_ : (x : a) (y : b x) → Σ₁₀ a b

data Σ₁₁ (a : Set1) (b : a → Set1) : Set1 where
  _,_ : (x : a) (y : b x) → Σ₁₁ a b

∃₀₁ : {A : Set} → (A → Set1) → Set1
∃₀₁ = Σ₀₁ _

∃₁₀ : {A : Set1} → (A → Set) → Set1
∃₁₀ = Σ₁₀ _

∃₁₁ : {A : Set1} → (A → Set1) → Set1
∃₁₁ = Σ₁₁ _

_×₀₁_ : Set → Set1 → Set1
A ×₀₁ B = Σ₀₁ A (λ _ → B)

_×₁₀_ : Set1 → Set → Set1
A ×₁₀ B = Σ₁₀ A (λ _ → B)

_×₁₁_ : Set1 → Set1 → Set1
A ×₁₁ B = Σ₁₁ A (λ _ → B)

------------------------------------------------------------------------
-- Functions

proj₀₁₁ : ∀ {a b} → Σ₀₁ a b → a
proj₀₁₁ (x , y) = x

proj₀₁₂ : ∀ {a b} → (p : Σ₀₁ a b) → b (proj₀₁₁ p)
proj₀₁₂ (x , y) = y

proj₁₀₁ : ∀ {a b} → Σ₁₀ a b → a
proj₁₀₁ (x , y) = x

proj₁₀₂ : ∀ {a b} → (p : Σ₁₀ a b) → b (proj₁₀₁ p)
proj₁₀₂ (x , y) = y

proj₁₁₁ : ∀ {a b} → Σ₁₁ a b → a
proj₁₁₁ (x , y) = x

proj₁₁₂ : ∀ {a b} → (p : Σ₁₁ a b) → b (proj₁₁₁ p)
proj₁₁₂ (x , y) = y

map₀₁ : ∀ {A B P Q} →
        (f : A → B) → (∀ {x} → P x → Q (f x)) →
        Σ₀₁ A P → Σ₀₁ B Q
map₀₁ f g p = (f (proj₀₁₁ p) , g (proj₀₁₂ p))

map₁₀ : ∀ {A B P Q} →
        (f : A → B) → (∀ {x} → P x → Q (f x)) →
        Σ₁₀ A P → Σ₁₀ B Q
map₁₀ f g p = (f (proj₁₀₁ p) , g (proj₁₀₂ p))

map₁₁ : ∀ {A B P Q} →
        (f : A → B) → (∀ {x} → P x → Q (f x)) →
        Σ₁₁ A P → Σ₁₁ B Q
map₁₁ f g p = (f (proj₁₁₁ p) , g (proj₁₁₂ p))
