------------------------------------------------------------------------
-- Finite sets, based on AVL trees
------------------------------------------------------------------------

open import Relation.Binary

module Data.AVL.Sets (OrderedKeySet : StrictTotalOrder) where

import Data.AVL as AVL
open StrictTotalOrder OrderedKeySet renaming (carrier to Key)
open import Data.Unit
open import Data.Function
open import Data.Product
open import Data.Maybe
open import Data.Bool
open import Data.List
open import Category.Functor
open RawFunctor MaybeFunctor

-- The set type. (Note that Set is a reserved word.)

private module S = AVL OrderedKeySet (const₁ ⊤)
open S public using () renaming (Tree to ⟨Set⟩)

-- Repackaged functions.

empty : ⟨Set⟩
empty = S.empty

singleton : Key → ⟨Set⟩
singleton k = S.singleton k _

insert : Key → ⟨Set⟩ → ⟨Set⟩
insert k = S.insert k _

delete : Key → ⟨Set⟩ → ⟨Set⟩
delete = S.delete

lookup : Key → ⟨Set⟩ → Maybe Key
lookup k s = proj₁ <$> S.lookup k s

_∈?_ : Key → ⟨Set⟩ → Bool
_∈?_ = S._∈?_

headTail : ⟨Set⟩ → Maybe (Key × ⟨Set⟩)
headTail s = map-Σ proj₁ id <$> S.headTail s

initLast : ⟨Set⟩ → Maybe (⟨Set⟩ × Key)
initLast s = map-Σ id proj₁ <$> S.initLast s

fromList : List Key → ⟨Set⟩
fromList = S.fromList ∘ map (λ k → (k , _))

toList : ⟨Set⟩ → List Key
toList = map proj₁ ∘ S.toList
