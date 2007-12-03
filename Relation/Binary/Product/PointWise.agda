------------------------------------------------------------------------
-- Pointwise products of binary relations
------------------------------------------------------------------------

module Relation.Binary.Product.PointWise where

open import Logic
open import Data.Function
open import Data.Product
open import Data.Sum
open import Relation.Nullary.Product
open import Relation.Binary
open import Relation.Binary.PropositionalEquality

private
 module Dummy {a₁ a₂ : Set} where

  infixr 2 _×-Rel_

  _×-Rel_ : Rel a₁ -> Rel a₂ -> Rel (a₁ × a₂)
  ∼₁ ×-Rel ∼₂ = (∼₁ on₁ proj₁) -×- (∼₂ on₁ proj₂)

  -- Some properties which are preserved by ×-Rel (under certain
  -- assumptions).

  abstract

    _×-reflexive_
      :  forall {≈₁ ∼₁ ≈₂ ∼₂}
      -> Reflexive ≈₁ ∼₁ -> Reflexive ≈₂ ∼₂
      -> Reflexive (≈₁ ×-Rel ≈₂) (∼₁ ×-Rel ∼₂)
    refl₁ ×-reflexive refl₂ = \x≈y ->
      (refl₁ (proj₁ x≈y) , refl₂ (proj₂ x≈y))

    _×-reflexive-≡_
      :  forall {∼₁ ∼₂}
      -> Reflexive _≡_ ∼₁ -> Reflexive _≡_ ∼₂
      -> Reflexive _≡_ (∼₁ ×-Rel ∼₂)
    (refl₁ ×-reflexive-≡ refl₂) ≡-refl = (refl₁ ≡-refl , refl₂ ≡-refl)

    ×-irreflexive₁
      :  forall {≈₁ <₁ ≈₂ <₂}
      -> Irreflexive ≈₁ <₁ -> Irreflexive (≈₁ ×-Rel ≈₂) (<₁ ×-Rel <₂)
    ×-irreflexive₁ ir = \x≈y x<y -> ir (proj₁ x≈y) (proj₁ x<y)

    ×-irreflexive₂
      :  forall {≈₁ <₁ ≈₂ <₂}
      -> Irreflexive ≈₂ <₂ -> Irreflexive (≈₁ ×-Rel ≈₂) (<₁ ×-Rel <₂)
    ×-irreflexive₂ ir = \x≈y x<y -> ir (proj₂ x≈y) (proj₂ x<y)

    _×-symmetric_
      :  forall {∼₁ ∼₂}
      -> Symmetric ∼₁ -> Symmetric ∼₂ -> Symmetric (∼₁ ×-Rel ∼₂)
    sym₁ ×-symmetric sym₂ = \x∼y -> sym₁ (proj₁ x∼y) , sym₂ (proj₂ x∼y)

    _×-transitive_
      :  forall {∼₁ ∼₂}
      -> Transitive ∼₁ -> Transitive ∼₂
      -> Transitive (∼₁ ×-Rel ∼₂)
    trans₁ ×-transitive trans₂ = \x∼y y∼z ->
      trans₁ (proj₁ x∼y) (proj₁ y∼z) ,
      trans₂ (proj₂ x∼y) (proj₂ y∼z)

    _×-antisymmetric_
      :  forall {≈₁ ≤₁ ≈₂ ≤₂}
      -> Antisymmetric ≈₁ ≤₁ -> Antisymmetric ≈₂ ≤₂
      -> Antisymmetric (≈₁ ×-Rel ≈₂) (≤₁ ×-Rel ≤₂)
    antisym₁ ×-antisymmetric antisym₂ = \x≤y y≤x ->
      ( antisym₁ (proj₁ x≤y) (proj₁ y≤x)
      , antisym₂ (proj₂ x≤y) (proj₂ y≤x) )

    ×-asymmetric₁
      :  forall {<₁ ∼₂}
      -> Asymmetric <₁ -> Asymmetric (<₁ ×-Rel ∼₂)
    ×-asymmetric₁ asym₁ = \x<y y<x -> asym₁ (proj₁ x<y) (proj₁ y<x)

    ×-asymmetric₂
      :  forall {∼₁ <₂}
      -> Asymmetric <₂ -> Asymmetric (∼₁ ×-Rel <₂)
    ×-asymmetric₂ asym₂ = \x<y y<x -> asym₂ (proj₂ x<y) (proj₂ y<x)

    _×-≈-respects₂_
      :  forall {≈₁ ∼₁ ≈₂ ∼₂}
      -> ≈₁ Respects₂ ∼₁ -> ≈₂ Respects₂ ∼₂
      -> (≈₁ ×-Rel ≈₂) Respects₂ (∼₁ ×-Rel ∼₂)
    _×-≈-respects₂_ {≈₁ = ≈₁} {∼₁ = ∼₁} {≈₂ = ≈₂} {∼₂ = ∼₂}
                    resp₁ resp₂ =
      (\{x y z} -> resp¹ {x} {y} {z}) ,
      (\{x y z} -> resp² {x} {y} {z})
      where
      ∼ = ∼₁ ×-Rel ∼₂

      resp¹ : forall {x} -> (≈₁ ×-Rel ≈₂) Respects (∼ x)
      resp¹ y≈y' x∼y = proj₁ resp₁ (proj₁ y≈y') (proj₁ x∼y) ,
                       proj₁ resp₂ (proj₂ y≈y') (proj₂ x∼y)

      resp² : forall {y} -> (≈₁ ×-Rel ≈₂) Respects (flip₁ ∼ y)
      resp² x≈x' x∼y = proj₂ resp₁ (proj₁ x≈x') (proj₁ x∼y) ,
                       proj₂ resp₂ (proj₂ x≈x') (proj₂ x∼y)

    ×-total
      :  forall {∼₁ ∼₂}
      -> Symmetric ∼₁ -> Total ∼₁ -> Total ∼₂ -> Total (∼₁ ×-Rel ∼₂)
    ×-total {∼₁ = ∼₁} {∼₂ = ∼₂} sym₁ total₁ total₂ = total
      where
      total : Total (∼₁ ×-Rel ∼₂)
      total x y with total₁ (proj₁ x) (proj₁ y)
                   | total₂ (proj₂ x) (proj₂ y)
      ... | inj₁ x₁∼y₁ | inj₁ x₂∼y₂ = inj₁ (     x₁∼y₁ , x₂∼y₂)
      ... | inj₁ x₁∼y₁ | inj₂ y₂∼x₂ = inj₂ (sym₁ x₁∼y₁ , y₂∼x₂)
      ... | inj₂ y₁∼x₁ | inj₂ y₂∼x₂ = inj₂ (     y₁∼x₁ , y₂∼x₂)
      ... | inj₂ y₁∼x₁ | inj₁ x₂∼y₂ = inj₁ (sym₁ y₁∼x₁ , x₂∼y₂)

    _×-decidable_
      :  forall {∼₁ ∼₂}
      -> Decidable ∼₁ -> Decidable ∼₂ -> Decidable (∼₁ ×-Rel ∼₂)
    dec₁ ×-decidable dec₂ = \x y ->
      dec₁ (proj₁ x) (proj₁ y)
        ×-dec
      dec₂ (proj₂ x) (proj₂ y)

  -- Some collections of properties which are preserved by ×-Rel.

  abstract

    _×-isEquivalence_
      :  forall {≈₁ ≈₂}
      -> IsEquivalence ≈₁ -> IsEquivalence ≈₂
      -> IsEquivalence (≈₁ ×-Rel ≈₂)
    _×-isEquivalence_ {≈₁ = ≈₁} {≈₂ = ≈₂} eq₁ eq₂ = record
      { refl  = \{x y} ->
                _×-reflexive-≡_ {∼₁ = ≈₁} {∼₂ = ≈₂}
                                (refl  eq₁) (refl  eq₂) {x} {y}
      ; sym   = \{x y} ->
                _×-symmetric_   {∼₁ = ≈₁} {∼₂ = ≈₂}
                                (sym   eq₁) (sym   eq₂) {x} {y}
      ; trans = \{x y z} ->
                _×-transitive_  {∼₁ = ≈₁} {∼₂ = ≈₂}
                                (trans eq₁) (trans eq₂) {x} {y} {z}
      }
      where open IsEquivalence

    _×-isPreorder_
      :  forall {≈₁ ∼₁ ≈₂ ∼₂}
      -> IsPreorder ≈₁ ∼₁ -> IsPreorder ≈₂ ∼₂
      -> IsPreorder (≈₁ ×-Rel ≈₂) (∼₁ ×-Rel ∼₂)
    _×-isPreorder_ {∼₁ = ∼₁} {∼₂ = ∼₂} pre₁ pre₂ = record
      { isEquivalence = isEquivalence pre₁ ×-isEquivalence
                        isEquivalence pre₂
      ; refl          = \{x y} ->
                        _×-reflexive_  {∼₁ = ∼₁} {∼₂ = ∼₂}
                                       (refl  pre₁) (refl  pre₂) {x} {y}
      ; trans         = \{x y z} ->
                        _×-transitive_ {∼₁ = ∼₁} {∼₂ = ∼₂}
                                       (trans pre₁) (trans pre₂)
                                       {x} {y} {z}
      ; ≈-resp-∼      = ≈-resp-∼ pre₁ ×-≈-respects₂ ≈-resp-∼ pre₂
      }
      where open IsPreorder

    _×-isPreorder-≡_
      :  forall {∼₁ ∼₂}
      -> IsPreorder _≡_ ∼₁ -> IsPreorder _≡_ ∼₂
      -> IsPreorder _≡_ (∼₁ ×-Rel ∼₂)
    _×-isPreorder-≡_ {∼₁ = ∼₁} {∼₂ = ∼₂} pre₁ pre₂ = record
      { isEquivalence = ≡-isEquivalence
      ; refl          = _×-reflexive-≡_ {∼₁ = ∼₁} {∼₂ = ∼₂}
                                        (refl  pre₁) (refl  pre₂)
      ; trans         = \{x y z} ->
                        _×-transitive_  {∼₁ = ∼₁} {∼₂ = ∼₂}
                                        (trans pre₁) (trans pre₂)
                                        {x} {y} {z}
      ; ≈-resp-∼      = ≡-resp _
      }
      where open IsPreorder

    _×-isDecEquivalence_
      :  forall {≈₁ ≈₂}
      -> IsDecEquivalence ≈₁ -> IsDecEquivalence ≈₂
      -> IsDecEquivalence (≈₁ ×-Rel ≈₂)
    eq₁ ×-isDecEquivalence eq₂ = record
      { isEquivalence = isEquivalence eq₁ ×-isEquivalence
                        isEquivalence eq₂
      ; _≟_           = _≟_ eq₁ ×-decidable _≟_ eq₂
      }
      where open IsDecEquivalence

    _×-isPartialOrder_
      :  forall {≈₁ ≤₁ ≈₂ ≤₂}
      -> IsPartialOrder ≈₁ ≤₁ -> IsPartialOrder ≈₂ ≤₂
      -> IsPartialOrder (≈₁ ×-Rel ≈₂) (≤₁ ×-Rel ≤₂)
    _×-isPartialOrder_ {≤₁ = ≤₁} {≤₂ = ≤₂} po₁ po₂ = record
      { isPreorder = isPreorder po₁ ×-isPreorder isPreorder po₂
      ; antisym    = \{x y} ->
                     _×-antisymmetric_ {≤₁ = ≤₁} {≤₂ = ≤₂}
                                       (antisym po₁) (antisym po₂)
                                       {x} {y}
      }
      where open IsPartialOrder

    _×-isStrictPartialOrder_
      :  forall {≈₁ <₁ ≈₂ <₂}
      -> IsStrictPartialOrder ≈₁ <₁ -> IsStrictPartialOrder ≈₂ <₂
      -> IsStrictPartialOrder (≈₁ ×-Rel ≈₂) (<₁ ×-Rel <₂)
    _×-isStrictPartialOrder_ {<₁ = <₁} {≈₂ = ≈₂} {<₂ = <₂} spo₁ spo₂ =
      record
        { isEquivalence = isEquivalence spo₁ ×-isEquivalence
                          isEquivalence spo₂
        ; irrefl        = \{x y} ->
                          ×-irreflexive₁ {<₁ = <₁} {≈₂ = ≈₂} {<₂ = <₂}
                                         (irrefl spo₁) {x} {y}
        ; trans         = \{x y z} ->
                          _×-transitive_ {∼₁ = <₁} {∼₂ = <₂}
                                         (trans spo₁) (trans spo₂)
                                         {x} {y} {z}
        ; ≈-resp-<      = ≈-resp-< spo₁ ×-≈-respects₂ ≈-resp-< spo₂
        }
      where open IsStrictPartialOrder

open Dummy public

-- "Packages" (e.g. setoids) can also be combined.

_×-preorder_ : Preorder -> Preorder -> Preorder
p₁ ×-preorder p₂ = record
  { carrier    = carrier    p₁ ×            carrier    p₂
  ; _≈_        = _≈_        p₁ ×-Rel        _≈_        p₂
  ; _∼_        = _∼_        p₁ ×-Rel        _∼_        p₂
  ; isPreorder = isPreorder p₁ ×-isPreorder isPreorder p₂
  }
  where open Preorder

_×-setoid_ : Setoid -> Setoid -> Setoid
s₁ ×-setoid s₂ = record
  { carrier       = carrier       s₁ ×               carrier       s₂
  ; _≈_           = _≈_           s₁ ×-Rel           _≈_           s₂
  ; isEquivalence = isEquivalence s₁ ×-isEquivalence isEquivalence s₂
  }
  where open Setoid

_×-decSetoid_ : DecSetoid -> DecSetoid -> DecSetoid
s₁ ×-decSetoid s₂ = record
  { carrier          = carrier s₁ ×     carrier s₂
  ; _≈_              = _≈_     s₁ ×-Rel _≈_     s₂
  ; isDecEquivalence = isDecEquivalence s₁ ×-isDecEquivalence
                       isDecEquivalence s₂
  }
  where open DecSetoid

_×-poset_ : Poset -> Poset -> Poset
s₁ ×-poset s₂ = record
  { carrier        = carrier s₁ ×     carrier s₂
  ; _≈_            = _≈_     s₁ ×-Rel _≈_     s₂
  ; _≤_            = _≤_     s₁ ×-Rel _≤_     s₂
  ; isPartialOrder = isPartialOrder s₁ ×-isPartialOrder
                     isPartialOrder s₂
  }
  where open Poset

_×-strictPartialOrder_
  : StrictPartialOrder -> StrictPartialOrder -> StrictPartialOrder
s₁ ×-strictPartialOrder s₂ = record
  { carrier              = carrier s₁ ×     carrier s₂
  ; _≈_                  = _≈_     s₁ ×-Rel _≈_     s₂
  ; _<_                  = _<_     s₁ ×-Rel _<_     s₂
  ; isStrictPartialOrder = isStrictPartialOrder s₁
                             ×-isStrictPartialOrder
                           isStrictPartialOrder s₂
  }
  where open StrictPartialOrder
