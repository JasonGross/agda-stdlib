------------------------------------------------------------------------
-- Finite sets
------------------------------------------------------------------------

module Prelude.Fin where

open import Prelude.Nat
open import Prelude.Logic
open import Prelude.Function
open import Prelude.BinaryRelation
open import Prelude.BinaryRelation.PropositionalEquality

------------------------------------------------------------------------
-- The type

data Fin : ℕ -> Set where
  fz : {n : ℕ} -> Fin (suc n)
  fs : {n : ℕ} -> Fin n -> Fin (suc n)

------------------------------------------------------------------------
-- Queries

abstract

  fz≢fs : forall {n} {x : Fin n} -> ¬ fz ≡ fs x
  fz≢fs ()

  private
    drop-fs : forall {o} {m n : Fin o} -> fs m ≡ fs n -> m ≡ n
    drop-fs ≡-refl = ≡-refl

  _Fin-≟_ : {n : ℕ} -> Decidable {Fin n} _≡_
  fz   Fin-≟ fz    = yes ≡-refl
  fs m Fin-≟ fs n  with m Fin-≟ n
  fs m Fin-≟ fs .m | yes ≡-refl = yes ≡-refl
  fs m Fin-≟ fs n  | no prf     = no (prf ∘ drop-fs)
  fz   Fin-≟ fs n  = no (⊥-elim ∘ fz≢fs)
  fs m Fin-≟ fz    = no (⊥-elim ∘ fz≢fs ∘ sym)
    where sym = Equivalence.sym ≡-equivalence

------------------------------------------------------------------------
-- Some properties

Fin-preSetoid : ℕ -> PreSetoid
Fin-preSetoid n = ≡-preSetoid (Fin n)

Fin-setoid : ℕ -> Setoid
Fin-setoid n = ≡-setoid (Fin n)

Fin-decSetoid : ℕ -> DecSetoid
Fin-decSetoid n = record { setoid = Fin-setoid n; _≟_ = _Fin-≟_ }
