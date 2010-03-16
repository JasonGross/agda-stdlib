------------------------------------------------------------------------
-- Alternative definition of bag and set equality
------------------------------------------------------------------------

{-# OPTIONS --universe-polymorphism #-}

module Data.Container.AlternativeBagAndSetEquality where

open import Data.Container
open import Data.Product as Prod
open import Function
open import Function.Equality using (_⟨$⟩_)
open import Function.Equivalence as Eq using (_⇔_; module Equivalent)
open import Function.Inverse as Inv using (Isomorphism; module Inverse)
open import Level
open import Relation.Binary.HeterogeneousEquality as H using (_≅_; refl)
open import Relation.Binary.PropositionalEquality as P using (_≡_; refl)

open P.≡-Reasoning

-- Another way to define bag and set equality. Two containers xs and
-- ys are equal when viewed as bags if their sets of positions are
-- equipotent and the position functions map related positions to
-- equal values. For set equality the position sets do not need to be
-- equipotent, only equiinhabited.

infix 4 _≈[_]′_

_≈[_]′_ : ∀ {c} {C : Container c} {X : Set c} →
          ⟦ C ⟧ X → Kind → ⟦ C ⟧ X → Set c
_≈[_]′_ {C = C} xs k ys =
  ∃ λ (p₁≈p₂ : Isomorphism k (Position C (proj₁ xs))
                             (Position C (proj₁ ys))) →
      (∀ p → proj₂ xs p ≡
             proj₂ ys (Equivalent.to   (Inv.⇒⇔ p₁≈p₂) ⟨$⟩ p)) ×
      (∀ p → proj₂ ys p ≡
             proj₂ xs (Equivalent.from (Inv.⇒⇔ p₁≈p₂) ⟨$⟩ p))
      -- The last component is unnecessary when k equals bag.

-- This definition is equivalent to the one in Data.Container.

private

  ≈⇔≈′-set : ∀ {c} {C : Container c} {X : Set c} (xs ys : ⟦ C ⟧ X) →
             xs ≈[ set ] ys ⇔ xs ≈[ set ]′ ys
  ≈⇔≈′-set {c} xs ys = Eq.equivalent to from
    where
    to : xs ≈[ set ] ys → xs ≈[ set ]′ ys
    to xs≈ys =
      Eq.equivalent
        (λ p → proj₁ $ Equivalent.to   xs≈ys ⟨$⟩ (p , lift refl))
        (λ p → proj₁ $ Equivalent.from xs≈ys ⟨$⟩ (p , lift refl)) ,
      (λ p → lower $ proj₂ (Equivalent.to   xs≈ys ⟨$⟩ (p , lift refl))) ,
      (λ p → lower $ proj₂ (Equivalent.from xs≈ys ⟨$⟩ (p , lift refl)))

    from : xs ≈[ set ]′ ys → xs ≈[ set ] ys
    from (p₁≈p₂ , f₁≈f₂ , f₂≈f₁) {z} =
      Eq.equivalent
        (Prod.map (_⟨$⟩_ (Equivalent.to p₁≈p₂))
                  (λ {x} eq → lift (begin
                     z                                     ≡⟨ lower {ℓ = c} eq ⟩
                     proj₂ xs x                            ≡⟨ f₁≈f₂ x ⟩
                     proj₂ ys (Equivalent.to p₁≈p₂ ⟨$⟩ x)  ∎)))
        (Prod.map (_⟨$⟩_ (Equivalent.from p₁≈p₂))
                  (λ {x} eq → lift (begin
                     z                                       ≡⟨ lower {ℓ = c} eq ⟩
                     proj₂ ys x                              ≡⟨ f₂≈f₁ x ⟩
                     proj₂ xs (Equivalent.from p₁≈p₂ ⟨$⟩ x)  ∎)))

  ≈⇔≈′-bag : ∀ {c} {C : Container c} {X : Set c} (xs ys : ⟦ C ⟧ X) →
             xs ≈[ bag ] ys ⇔ xs ≈[ bag ]′ ys
  ≈⇔≈′-bag {c} {C} {X} xs ys = Eq.equivalent t f
    where
    open Inverse

    t : xs ≈[ bag ] ys → xs ≈[ bag ]′ ys
    t xs≈ys =
      record { to         = Equivalent.to   (proj₁ xs∼ys)
             ; from       = Equivalent.from (proj₁ xs∼ys)
             ; inverse-of = record
               { left-inverse-of  = from∘to
               ; right-inverse-of = to∘from
               }
             } ,
      proj₂ xs∼ys
      where
      xs∼ys = Equivalent.to (≈⇔≈′-set xs ys) ⟨$⟩ Inv.⇿⇒ xs≈ys

      from∘to : ∀ p → proj₁ (from xs≈ys ⟨$⟩
                               (proj₁ (to xs≈ys ⟨$⟩ (p , lift refl)) ,
                                lift refl)) ≡ p
      from∘to p = begin
        proj₁ (from xs≈ys ⟨$⟩ (proj₁ (to xs≈ys ⟨$⟩ (p , lift refl)) , lift refl))  ≡⟨ lemma (to xs≈ys ⟨$⟩ (p , lift refl)) ⟩
        proj₁ (from xs≈ys ⟨$⟩        (to xs≈ys ⟨$⟩ (p , lift refl))             )  ≡⟨ P.cong proj₁ $
                                                                                        left-inverse-of xs≈ys (p , lift refl) ⟩
        p                                                                          ∎
        where
        lemma : ∀ {y} (x : ∃ λ p′ → Lift (y ≡ proj₂ ys p′)) →
                proj₁ (from xs≈ys ⟨$⟩ (proj₁ x , lift refl)) ≡
                proj₁ (from xs≈ys ⟨$⟩        x             )
        lemma (p′ , lift refl) = refl

      to∘from : ∀ p → proj₁ (to xs≈ys ⟨$⟩
                               (proj₁ (from xs≈ys ⟨$⟩ (p , lift refl)) ,
                                lift refl)) ≡ p
      to∘from p = begin
        proj₁ (to xs≈ys ⟨$⟩ (proj₁ (from xs≈ys ⟨$⟩ (p , lift refl)) , lift refl))  ≡⟨ lemma (from xs≈ys ⟨$⟩ (p , lift refl)) ⟩
        proj₁ (to xs≈ys ⟨$⟩        (from xs≈ys ⟨$⟩ (p , lift refl))             )  ≡⟨ P.cong proj₁ $
                                                                                        right-inverse-of xs≈ys (p , lift refl) ⟩
        p                                                                          ∎
        where
        lemma : ∀ {y} (x : ∃ λ p′ → Lift (y ≡ proj₂ xs p′)) →
                proj₁ (to xs≈ys ⟨$⟩ (proj₁ x , lift refl)) ≡
                proj₁ (to xs≈ys ⟨$⟩        x             )
        lemma (p′ , lift refl) = refl

    f : xs ≈[ bag ]′ ys → xs ≈[ bag ] ys
    f (p₁≈p₂ , f₁≈f₂ , f₂≈f₁) {z} = record
      { to         = Equivalent.to   xs∼ys
      ; from       = Equivalent.from xs∼ys
      ; inverse-of = record
        { left-inverse-of  = λ x →
            let eq = P.trans (P.trans (lower (proj₂ x)) (P.trans (f₁≈f₂ (proj₁ x)) refl))
                             (P.trans (f₂≈f₁ (to p₁≈p₂ ⟨$⟩ proj₁ x)) refl) in
            H.≅-to-≡ $
              H.cong₂ {B = λ x → Lift (z ≡ proj₂ xs x)}
                      _,_ (H.≡-to-≅ $ left-inverse-of  p₁≈p₂ (proj₁ x))
                          (proof-irrelevance eq (lower $ proj₂ x))
        ; right-inverse-of = λ x →
            let eq = P.trans (P.trans (lower (proj₂ x)) (P.trans (f₂≈f₁ (proj₁ x)) refl))
                             (P.trans (f₁≈f₂ (from p₁≈p₂ ⟨$⟩ proj₁ x)) refl) in
            H.≅-to-≡ $
              H.cong₂ {B = λ x → Lift (z ≡ proj₂ ys x)}
                      _,_ (H.≡-to-≅ $ right-inverse-of p₁≈p₂ (proj₁ x))
                          (proof-irrelevance eq (lower $ proj₂ x))
        }
      }
      where
      xs∼ys = Equivalent.from (≈⇔≈′-set xs ys) ⟨$⟩
                (Inv.⇿⇒ p₁≈p₂ , f₁≈f₂ , f₂≈f₁)

      proof-irrelevance : {A : Set c} {x y z : A}
                          (p : x ≡ y) (q : x ≡ z) →
                          lift {ℓ = c} p ≅ lift {ℓ = c} q
      proof-irrelevance refl refl = refl

≈⇔≈′ : ∀ {k c} {C : Container c} {X : Set c} (xs ys : ⟦ C ⟧ X) →
       xs ≈[ k ] ys ⇔ xs ≈[ k ]′ ys
≈⇔≈′ {set} = ≈⇔≈′-set
≈⇔≈′ {bag} = ≈⇔≈′-bag
