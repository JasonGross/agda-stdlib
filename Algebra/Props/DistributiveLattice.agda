------------------------------------------------------------------------
-- Some derivable properties
------------------------------------------------------------------------

open import Algebra

module Algebra.Props.DistributiveLattice
         (dl : DistributiveLattice)
         where

open DistributiveLattice dl
import Algebra.Props.Lattice as L; open L lattice public
import Algebra.Structures as S; open S setoid
import Algebra.FunctionProperties as P; open P setoid
import Relation.Binary.EqReasoning as EqR; open EqR setoid
open import Data.Function
open import Data.Product

abstract

  ∨-∧-distrib : _∨_ DistributesOver _∧_
  ∨-∧-distrib = ∨-∧-distribˡ , ∨-∧-distribʳ
    where
    ∨-∧-distribʳ : _∨_ DistributesOverʳ _∧_
    ∨-∧-distribʳ x y z = begin
      y ∧ z ∨ x          ≈⟨ ∨-comm _ _ ⟩
      x ∨ y ∧ z          ≈⟨ ∨-∧-distribˡ _ _ _ ⟩
      (x ∨ y) ∧ (x ∨ z)  ≈⟨ ∨-comm _ _ ⟨ ∧-pres-≈ ⟩ ∨-comm _ _ ⟩
      (y ∨ x) ∧ (z ∨ x)  ∎

  ∧-∨-distrib : _∧_ DistributesOver _∨_
  ∧-∨-distrib = ∧-∨-distribˡ , ∧-∨-distribʳ
    where
    ∧-∨-distribˡ : _∧_ DistributesOverˡ _∨_
    ∧-∨-distribˡ x y z = begin
      x ∧ (y ∨ z)                ≈⟨ sym (proj₂ absorptive _ _) ⟨ ∧-pres-≈ ⟩ byDef ⟩
      (x ∧ (x ∨ y)) ∧ (y ∨ z)    ≈⟨ (byDef ⟨ ∧-pres-≈ ⟩ ∨-comm _ _) ⟨ ∧-pres-≈ ⟩ byDef ⟩
      (x ∧ (y ∨ x)) ∧ (y ∨ z)    ≈⟨ sym $ ∧-assoc _ _ _ ⟩
      x ∧ ((y ∨ x) ∧ (y ∨ z))    ≈⟨ byDef ⟨ ∧-pres-≈ ⟩ sym (proj₁ ∨-∧-distrib _ _ _) ⟩
      x ∧ (y ∨ x ∧ z)            ≈⟨ sym (proj₁ absorptive _ _) ⟨ ∧-pres-≈ ⟩ byDef ⟩
      (x ∨ x ∧ z) ∧ (y ∨ x ∧ z)  ≈⟨ sym $ proj₂ ∨-∧-distrib _ _ _ ⟩
      x ∧ y ∨ x ∧ z              ∎

    ∧-∨-distribʳ : _∧_ DistributesOverʳ _∨_
    ∧-∨-distribʳ x y z = begin
      (y ∨ z) ∧ x    ≈⟨ ∧-comm _ _ ⟩
      x ∧ (y ∨ z)    ≈⟨ ∧-∨-distribˡ _ _ _ ⟩
      x ∧ y ∨ x ∧ z  ≈⟨ ∧-comm _ _ ⟨ ∨-pres-≈ ⟩ ∧-comm _ _ ⟩
      y ∧ x ∨ z ∧ x  ∎

  -- The dual construction is also a distributive lattice.

  ∧-∨-isDistributiveLattice : IsDistributiveLattice _∧_ _∨_
  ∧-∨-isDistributiveLattice = record
    { isLattice    = ∧-∨-isLattice
    ; ∨-∧-distribˡ = proj₁ ∧-∨-distrib
    }

∧-∨-distributiveLattice : DistributiveLattice
∧-∨-distributiveLattice = record
  { setoid                = setoid
  ; _∧_                   = _∨_
  ; _∨_                   = _∧_
  ; isDistributiveLattice = ∧-∨-isDistributiveLattice
  }
