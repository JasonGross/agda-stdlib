------------------------------------------------------------------------
-- Lists where at least one element satisfies a given property
------------------------------------------------------------------------

module Data.List.Any where

open import Data.Empty
open import Data.Function
open import Data.List as List hiding (map)
open import Data.Product as Prod using (∃; _×_; _,_)
open import Relation.Nullary
import Relation.Nullary.Decidable as Dec
open import Relation.Unary using (Pred; _⊆_)

-- Any P xs means that at least one element in xs satisfies P.

data Any {A} (P : A → Set) : List A → Set where
  here  : ∀ {x xs} (px  : P x)      → Any P (x ∷ xs)
  there : ∀ {x xs} (pxs : Any P xs) → Any P (x ∷ xs)

find : ∀ {A} {P : A → Set} {xs} → Any P xs → ∃ λ x → x ∈ xs × P x
find (here px)   = (_ , here , px)
find (there pxs) = Prod.map id (Prod.map there id) (find pxs)

gmap : ∀ {A B} {P : A → Set} {Q : B → Set} {f : A → B} →
       P ⊆ Q ∘₀ f → Any P ⊆ Any Q ∘₀ List.map f
gmap g (here px)   = here (g px)
gmap g (there pxs) = there (gmap g pxs)

map : ∀ {A} {P Q : Pred A} → P ⊆ Q → Any P ⊆ Any Q
map g (here px)   = here (g px)
map g (there pxs) = there (map g pxs)

dec : ∀ {A} {P : A → Set} →
      (∀ x → Dec (P x)) → (xs : List A) → Dec (Any P xs)
dec p []       = no λ()
dec p (x ∷ xs) with p x
dec p (x ∷ xs) | yes px = yes (here px)
dec p (x ∷ xs) | no ¬px = Dec.map (there , helper) (dec p xs)
  where
  helper : Any _ (x ∷ xs) → Any _ xs
  helper (here  px)  = ⊥-elim (¬px px)
  helper (there pxs) = pxs
