------------------------------------------------------------------------
-- Some derivable properties
------------------------------------------------------------------------

open import Algebra

module Algebra.Props.AbelianGroup (g : AbelianGroup) where

open AbelianGroup g
import Relation.Binary.EqReasoning as EqR; open EqR setoid
open import Data.Function
open import Data.Product

abstract

  private
    lemma : forall x y -> x • y • x ⁻¹ ≈ y
    lemma x y = begin
      x • y • x ⁻¹    ≈⟨ comm _ _ ⟨ •-pres-≈ ⟩ byDef ⟩
      y • x • x ⁻¹    ≈⟨ assoc _ _ _ ⟩
      y • (x • x ⁻¹)  ≈⟨ byDef ⟨ •-pres-≈ ⟩ proj₂ inverse _ ⟩
      y • ε           ≈⟨ proj₂ identity _ ⟩
      y               ∎

  --•-comm : forall x y -> x ⁻¹ • y ⁻¹ ≈ (x • y) ⁻¹
  --•-comm x y = begin
    x ⁻¹ • y ⁻¹                         ≈⟨ comm _ _ ⟩
    y ⁻¹ • x ⁻¹                         ≈⟨ sym $ lem ⟨ •-pres-≈ ⟩ byDef ⟩
    x • (y • (x • y) ⁻¹ • y ⁻¹) • x ⁻¹  ≈⟨ lemma _ _ ⟩
    y • (x • y) ⁻¹ • y ⁻¹               ≈⟨ lemma _ _ ⟩
    (x • y) ⁻¹                          ∎
    where
    lem = begin
      x • (y • (x • y) ⁻¹ • y ⁻¹)  ≈⟨ sym $ assoc _ _ _ ⟩
      x • (y • (x • y) ⁻¹) • y ⁻¹  ≈⟨ sym $ assoc _ _ _ ⟨ •-pres-≈ ⟩ byDef ⟩
      x • y • (x • y) ⁻¹ • y ⁻¹    ≈⟨ proj₂ inverse _ ⟨ •-pres-≈ ⟩ byDef ⟩
      ε • y ⁻¹                     ≈⟨ proj₁ identity _ ⟩
      y ⁻¹                         ∎
