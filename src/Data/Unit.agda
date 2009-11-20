------------------------------------------------------------------------
-- The unit type
------------------------------------------------------------------------

module Data.Unit where

open import Data.Sum
open import Relation.Nullary
open import Relation.Binary
open import Relation.Binary.PropositionalEquality as PropEq
  using (_≡_; refl)

------------------------------------------------------------------------
-- Types

-- Note that the name of this type is "\top", not T.

record ⊤ : Set where
  constructor tt

record _≤_ (x y : ⊤) : Set where

------------------------------------------------------------------------
-- Operations

_≟_ : Decidable {A = ⊤} _≡_
_ ≟ _ = yes refl

_≤?_ : Decidable _≤_
_ ≤? _ = yes _

total : Total _≤_
total _ _ = inj₁ _

------------------------------------------------------------------------
-- Properties

preorder : Preorder _ _ _
preorder = PropEq.preorder ⊤

setoid : Setoid _ _
setoid = PropEq.setoid ⊤

decTotalOrder : DecTotalOrder _ _ _
decTotalOrder = record
  { carrier         = ⊤
  ; _≈_             = _≡_
  ; _≤_             = _≤_
  ; isDecTotalOrder = record
      { isTotalOrder = record
          { isPartialOrder = record
              { isPreorder = record
                  { isEquivalence = PropEq.isEquivalence
                  ; reflexive     = λ _ → _
                  ; trans         = λ _ _ → _
                  ; ∼-resp-≈      = PropEq.resp₂ _≤_
                  }
              ; antisym  = antisym
              }
          ; total = total
          }
      ; _≟_  = _≟_
      ; _≤?_ = _≤?_
      }
  }
  where
  antisym : Antisymmetric _≡_ _≤_
  antisym _ _ = refl

decSetoid : DecSetoid _ _
decSetoid = DecTotalOrder.Eq.decSetoid decTotalOrder

poset : Poset _ _ _
poset = DecTotalOrder.poset decTotalOrder
