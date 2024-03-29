------------------------------------------------------------------------
-- The Agda standard library
--
-- The free monad construction on containers
------------------------------------------------------------------------

module Data.Container.FreeMonad where

open import Level
open import Function using (_∘_)
open import Data.Empty using (⊥-elim)
open import Data.Sum using (inj₁; inj₂)
open import Data.Product
open import Data.Container
open import Data.Container.Combinator using (const; _⊎_)
open import Data.W
open import Category.Monad

------------------------------------------------------------------------
-- The free monad construction

infixl 1 _⋆C_
infix  1 _⋆_

_⋆C_ : ∀ {c} → Container c → Set c → Container c
C ⋆C X = const X ⊎ C

_⋆_ : ∀ {c} → Container c → Set c → Set c
C ⋆ X = μ (C ⋆C X)

do : ∀ {c} {C : Container c} {X} → ⟦ C ⟧ (C ⋆ X) → C ⋆ X
do (s , k) = sup (inj₂ s) k

rawMonad : ∀ {c} {C : Container c} → RawMonad (_⋆_ C)
rawMonad = record { return = return; _>>=_ = _>>=_ }
  where
  return : ∀ {c} {C : Container c} {X} → X → C ⋆ X
  return x = sup (inj₁ x) (⊥-elim ∘ lower)

  _>>=_ : ∀ {c} {C : Container c} {X Y} → C ⋆ X → (X → C ⋆ Y) → C ⋆ Y
  sup (inj₁ x) _ >>= k = k x
  sup (inj₂ s) f >>= k = do (s , λ p → f p >>= k)