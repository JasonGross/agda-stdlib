------------------------------------------------------------------------
-- A bunch of properties
------------------------------------------------------------------------

module Data.Bool.Properties where

open import Data.Bool as Bool
open import Data.Fin
open import Data.Vec
open import Data.Function
open import Algebra
import Algebra.FunctionProperties as P; open P Bool.setoid
open import Algebra.Structures
import Algebra.RingSolver.Simple as Solver
import Algebra.RingSolver.AlmostCommutativeRing as ACR
open import Relation.Binary.PropositionalEquality
open import Data.Product

import Relation.Binary.EqReasoning as EqR; open EqR Bool.setoid

------------------------------------------------------------------------
-- Duality

-- Can we take advantage of duality in some (nice) way?

------------------------------------------------------------------------
-- (Bool, ∨, ∧, false, true) forms a commutative semiring

private

  ∨-assoc : Associative _∨_
  ∨-assoc true  y z = byDef
  ∨-assoc false y z = byDef

  ∧-assoc : Associative _∧_
  ∧-assoc true  y z = byDef
  ∧-assoc false y z = byDef

  ∨-comm : Commutative _∨_
  ∨-comm true  true  = byDef
  ∨-comm true  false = byDef
  ∨-comm false true  = byDef
  ∨-comm false false = byDef

  ∧-comm : Commutative _∧_
  ∧-comm true  true  = byDef
  ∧-comm true  false = byDef
  ∧-comm false true  = byDef
  ∧-comm false false = byDef

  ∨-identity : Identity false _∨_
  ∨-identity = (λ _ → byDef) , (λ x → ∨-comm x false)

  ∧-identity : Identity true _∧_
  ∧-identity = (λ _ → byDef) , (λ x → ∧-comm x true)

  zero-∧ : Zero false _∧_
  zero-∧ = (λ _ → byDef) , (λ x → ∧-comm x false)

  distrib-∧-∨ : _∧_ DistributesOver _∨_
  distrib-∧-∨ = distˡ , distʳ
    where
    distˡ : _∧_ DistributesOverˡ _∨_
    distˡ true  y z = byDef
    distˡ false y z = byDef

    distʳ : _∧_ DistributesOverʳ _∨_
    distʳ x y z =
                      begin
       (y ∨ z) ∧ x
                      ≈⟨ ∧-comm (y ∨ z) x ⟩
       x ∧ (y ∨ z)
                      ≈⟨ distˡ x y z ⟩
       x ∧ y ∨ x ∧ z
                      ≈⟨ cong₂ _∨_ (∧-comm x y) (∧-comm x z) ⟩
       y ∧ x ∨ z ∧ x
                      ∎

isCommutativeSemiring-∨-∧
  : IsCommutativeSemiring Bool.setoid _∨_ _∧_ false true
isCommutativeSemiring-∨-∧ = record
  { isSemiring = record
    { isSemiringWithoutAnnihilatingZero = record
      { +-isCommutativeMonoid = record
        { isMonoid = record
          { isSemigroup = record
            { assoc    = ∨-assoc
            ; ∙-pres-≈ = cong₂ _∨_
            }
          ; identity = ∨-identity
          }
        ; comm = ∨-comm
        }
      ; *-isMonoid = record
        { isSemigroup = record
          { assoc    = ∧-assoc
          ; ∙-pres-≈ = cong₂ _∧_
          }
        ; identity = ∧-identity
        }
      ; distrib = distrib-∧-∨
      }
    ; zero = zero-∧
    }
  ; *-comm = ∧-comm
  }

commutativeSemiring-∨-∧ : CommutativeSemiring
commutativeSemiring-∨-∧ = record
  { setoid                = Bool.setoid
  ; _+_                   = _∨_
  ; _*_                   = _∧_
  ; 0#                    = false
  ; 1#                    = true
  ; isCommutativeSemiring = isCommutativeSemiring-∨-∧
  }

module ringSolver =
  Solver (ACR.fromCommutativeSemiring commutativeSemiring-∨-∧)

------------------------------------------------------------------------
-- (Bool, ∧, ∨, true, false) forms a commutative semiring

private

  zero-∨ : Zero true _∨_
  zero-∨ = (λ _ → byDef) , (λ x → ∨-comm x true)

  distrib-∨-∧ : _∨_ DistributesOver _∧_
  distrib-∨-∧ = distˡ , distʳ
    where
    distˡ : _∨_ DistributesOverˡ _∧_
    distˡ true  y z = byDef
    distˡ false y z = byDef

    distʳ : _∨_ DistributesOverʳ _∧_
    distʳ x y z =
                          begin
       (y ∧ z) ∨ x
                          ≈⟨ ∨-comm (y ∧ z) x ⟩
       x ∨ (y ∧ z)
                          ≈⟨ distˡ x y z ⟩
       (x ∨ y) ∧ (x ∨ z)
                          ≈⟨ cong₂ _∧_ (∨-comm x y) (∨-comm x z) ⟩
       (y ∨ x) ∧ (z ∨ x)
                          ∎

isCommutativeSemiring-∧-∨
  : IsCommutativeSemiring Bool.setoid _∧_ _∨_ true false
isCommutativeSemiring-∧-∨ = record
  { isSemiring = record
    { isSemiringWithoutAnnihilatingZero = record
      { +-isCommutativeMonoid = record
        { isMonoid = record
          { isSemigroup = record
            { assoc    = ∧-assoc
            ; ∙-pres-≈ = cong₂ _∧_
            }
          ; identity = ∧-identity
          }
        ; comm = ∧-comm
        }
      ; *-isMonoid = record
        { isSemigroup = record
          { assoc    = ∨-assoc
          ; ∙-pres-≈ = cong₂ _∨_
          }
        ; identity = ∨-identity
        }
      ; distrib = distrib-∨-∧
      }
    ; zero = zero-∨
    }
  ; *-comm = ∨-comm
  }

commutativeSemiring-∧-∨ : CommutativeSemiring
commutativeSemiring-∧-∨ = record
  { setoid                = Bool.setoid
  ; _+_                   = _∧_
  ; _*_                   = _∨_
  ; 0#                    = true
  ; 1#                    = false
  ; isCommutativeSemiring = isCommutativeSemiring-∧-∨
  }

------------------------------------------------------------------------
-- (Bool, ∨, ∧, not, true, false) is a boolean algebra

private

  absorptive : Absorptive _∨_ _∧_
  absorptive = abs-∨-∧ , abs-∧-∨
    where
    abs-∨-∧ : _∨_ Absorbs _∧_
    abs-∨-∧ true  y = byDef
    abs-∨-∧ false y = byDef

    abs-∧-∨ : _∧_ Absorbs _∨_
    abs-∧-∨ true  y = byDef
    abs-∧-∨ false y = byDef

  not-∧-inverse : Inverse false not _∧_
  not-∧-inverse =
    ¬x∧x≡⊥ , (λ x → ∧-comm x (not x) ⟨ trans ⟩ ¬x∧x≡⊥ x)
    where
    ¬x∧x≡⊥ : LeftInverse false not _∧_
    ¬x∧x≡⊥ false = byDef
    ¬x∧x≡⊥ true  = byDef

  not-∨-inverse : Inverse true not _∨_
  not-∨-inverse =
    ¬x∨x≡⊤ , (λ x → ∨-comm x (not x) ⟨ trans ⟩ ¬x∨x≡⊤ x)
    where
    ¬x∨x≡⊤ : LeftInverse true not _∨_
    ¬x∨x≡⊤ false = byDef
    ¬x∨x≡⊤ true  = byDef

isBooleanAlgebra : IsBooleanAlgebra Bool.setoid _∨_ _∧_ not true false
isBooleanAlgebra = record
  { isDistributiveLattice = record
      { isLattice = record
          { ∨-comm     = ∨-comm
          ; ∨-assoc    = ∨-assoc
          ; ∨-pres-≈   = cong₂ _∨_
          ; ∧-comm     = ∧-comm
          ; ∧-assoc    = ∧-assoc
          ; ∧-pres-≈   = cong₂ _∧_
          ; absorptive = absorptive
          }
      ; ∨-∧-distribʳ = proj₂ distrib-∨-∧
      }
  ; ∨-complementʳ = proj₂ not-∨-inverse
  ; ∧-complementʳ = proj₂ not-∧-inverse
  ; ¬-pres-≈      = cong not
  }

booleanAlgebra : BooleanAlgebra
booleanAlgebra = record
  { setoid           = Bool.setoid
  ; _∨_              = _∨_
  ; _∧_              = _∧_
  ; ¬_               = not
  ; ⊤                = true
  ; ⊥                = false
  ; isBooleanAlgebra = isBooleanAlgebra
  }

------------------------------------------------------------------------
-- (Bool, xor, ∧, id, false, true) forms a commutative ring

private

  xor-is-ok : ∀ x y → x xor y ≡ (x ∨ y) ∧ not (x ∧ y)
  xor-is-ok true  y = byDef
  xor-is-ok false y = sym $ proj₂ ∧-identity _

commutativeRing-xor-∧ : CommutativeRing
commutativeRing-xor-∧ = commutativeRing
  where
  import Algebra.Props.BooleanAlgebra as BA
  open BA booleanAlgebra
  open XorRing _xor_ xor-is-ok

module xor-ringSolver =
  Solver (ACR.fromCommutativeRing commutativeRing-xor-∧)

------------------------------------------------------------------------
-- Miscellaneous other properties

not-involutive : Involutive not
not-involutive true  = byDef
not-involutive false = byDef
