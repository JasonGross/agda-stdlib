------------------------------------------------------------------------
-- Commutative semirings with some additional structure ("almost"
-- commutative rings), used by the ring solver
------------------------------------------------------------------------

module Algebra.RingSolver.AlmostCommutativeRing where

open import Relation.Binary
open import Algebra
open import Algebra.Structures
open import Algebra.FunctionProperties
import Algebra.Morphism as Morphism
open import Function
open import Level

------------------------------------------------------------------------
-- Definitions

record IsAlmostCommutativeRing {A} (_≈_ : Rel A zero)
         (_+_ _*_ : Op₂ A) (-_ : Op₁ A) (0# 1# : A) : Set where
  field
    isCommutativeSemiring : IsCommutativeSemiring _≈_ _+_ _*_ 0# 1#
    -‿cong                : -_ Preserves _≈_ ⟶ _≈_
    -‿*-distribˡ          : ∀ x y → ((- x) * y)     ≈ (- (x * y))
    -‿+-comm              : ∀ x y → ((- x) + (- y)) ≈ (- (x + y))

  open IsCommutativeSemiring isCommutativeSemiring public

record AlmostCommutativeRing : Set₁ where
  infix  8 -_
  infixl 7 _*_
  infixl 6 _+_
  infix  4 _≈_
  field
    Carrier                 : Set
    _≈_                     : Rel Carrier zero
    _+_                     : Op₂ Carrier
    _*_                     : Op₂ Carrier
    -_                      : Op₁ Carrier
    0#                      : Carrier
    1#                      : Carrier
    isAlmostCommutativeRing :
      IsAlmostCommutativeRing _≈_ _+_ _*_ -_ 0# 1#

  open IsAlmostCommutativeRing isAlmostCommutativeRing public

  commutativeSemiring : CommutativeSemiring
  commutativeSemiring =
    record { isCommutativeSemiring = isCommutativeSemiring }

  open CommutativeSemiring commutativeSemiring public
         using ( setoid
               ; +-semigroup; +-monoid; +-commutativeMonoid
               ; *-semigroup; *-monoid; *-commutativeMonoid
               ; semiring
               )

  rawRing : RawRing
  rawRing = record
    { _+_ = _+_
    ; _*_ = _*_
    ; -_  = -_
    ; 0#  = 0#
    ; 1#  = 1#
    }

------------------------------------------------------------------------
-- Homomorphisms

record _-Raw-AlmostCommutative⟶_
         (From : RawRing)
         (To : AlmostCommutativeRing) : Set where
  private
    module F = RawRing From
    module T = AlmostCommutativeRing To
  open Morphism.Definitions F.Carrier T.Carrier T._≈_
  field
    ⟦_⟧    : Morphism
    +-homo : Homomorphic₂ ⟦_⟧ F._+_ T._+_
    *-homo : Homomorphic₂ ⟦_⟧ F._*_ T._*_
    -‿homo : Homomorphic₁ ⟦_⟧ F.-_  T.-_
    0-homo : Homomorphic₀ ⟦_⟧ F.0#  T.0#
    1-homo : Homomorphic₀ ⟦_⟧ F.1#  T.1#

-raw-almostCommutative⟶
  : ∀ r →
    AlmostCommutativeRing.rawRing r -Raw-AlmostCommutative⟶ r
-raw-almostCommutative⟶ r = record
  { ⟦_⟧    = id
  ; +-homo = λ _ _ → refl
  ; *-homo = λ _ _ → refl
  ; -‿homo = λ _ → refl
  ; 0-homo = refl
  ; 1-homo = refl
  }
  where open AlmostCommutativeRing r

------------------------------------------------------------------------
-- Conversions

-- Commutative rings are almost commutative rings.

fromCommutativeRing : CommutativeRing → AlmostCommutativeRing
fromCommutativeRing cr = record
  { isAlmostCommutativeRing = record
      { isCommutativeSemiring = isCommutativeSemiring
      ; -‿cong                = -‿cong
      ; -‿*-distribˡ          = -‿*-distribˡ
      ; -‿+-comm              = -‿∙-comm
      }
  }
  where
  open CommutativeRing cr
  import Algebra.Props.Ring as R; open R ring
  import Algebra.Props.AbelianGroup as AG; open AG +-abelianGroup

-- Commutative semirings can be viewed as almost commutative rings by
-- using identity as the "almost negation".

fromCommutativeSemiring : CommutativeSemiring → AlmostCommutativeRing
fromCommutativeSemiring cs = record
  { -_                      = id
  ; isAlmostCommutativeRing = record
      { isCommutativeSemiring = isCommutativeSemiring
      ; -‿cong                = id
      ; -‿*-distribˡ          = λ _ _ → refl
      ; -‿+-comm              = λ _ _ → refl
      }
  }
  where open CommutativeSemiring cs
