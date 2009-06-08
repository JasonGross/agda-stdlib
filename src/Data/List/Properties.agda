------------------------------------------------------------------------
-- List-related properties
------------------------------------------------------------------------

-- Note that the lemmas below could be generalised to work with other
-- equalities than _≡_.

module Data.List.Properties where

open import Data.List as List
open import Data.List.Any as Any using (Any; _∈_; _⊆_; here; there)
open import Data.List.All as All using (All; []; _∷_)
open import Data.Nat
open import Data.Nat.Properties
open import Data.Bool
open import Data.Bool.Properties
open import Data.Function
open import Data.Product as Prod hiding (map)
open import Data.Sum as Sum using (_⊎_; inj₁; inj₂; [_,_]′)
open import Data.Maybe using (Maybe; just; nothing)
open import Relation.Binary.PropositionalEquality
import Relation.Binary.EqReasoning as Eq
open import Algebra
open import Category.Monad
open RawMonad List.monad

∷-injective : ∀ {A} {x y xs ys} →
              (List A ∶ x ∷ xs) ≡ (y ∷ ys) → (x ≡ y) × (xs ≡ ys)
∷-injective refl = (refl , refl)

right-identity-unique : ∀ {A} (xs : List A) {ys} →
                        xs ≡ xs ++ ys → ys ≡ []
right-identity-unique []       refl = refl
right-identity-unique (x ∷ xs) eq   =
  right-identity-unique xs (proj₂ (∷-injective eq))

-- Map, sum, and append.

map-++-commute : ∀ {a b} (f : a → b) xs ys →
                 map f (xs ++ ys) ≡ map f xs ++ map f ys
map-++-commute f []       ys = refl
map-++-commute f (x ∷ xs) ys =
  cong (_∷_ (f x)) (map-++-commute f xs ys)

sum-++-commute : ∀ xs ys → sum (xs ++ ys) ≡ sum xs + sum ys
sum-++-commute []       ys = refl
sum-++-commute (x ∷ xs) ys = begin
  x + sum (xs ++ ys)
                         ≡⟨ cong (_+_ x) (sum-++-commute xs ys) ⟩
  x + (sum xs + sum ys)
                         ≡⟨ sym $ +-assoc x _ _ ⟩
  (x + sum xs) + sum ys
                         ∎
  where
  open CommutativeSemiring commutativeSemiring hiding (_+_; sym)
  open ≡-Reasoning

-- Various properties about folds.

foldr-universal : ∀ {a b} (h : List a → b) f e →
                  (h [] ≡ e) →
                  (∀ x xs → h (x ∷ xs) ≡ f x (h xs)) →
                  h ≗ foldr f e
foldr-universal h f e base step []       = base
foldr-universal h f e base step (x ∷ xs) = begin
  h (x ∷ xs)
    ≡⟨ step x xs ⟩
  f x (h xs)
    ≡⟨ cong (f x) (foldr-universal h f e base step xs) ⟩
  f x (foldr f e xs)
    ∎
  where open ≡-Reasoning

foldr-fusion : ∀ {a b c} (h : b → c)
                 {f : a → b → b} {g : a → c → c} (e : b) →
               (∀ x y → h (f x y) ≡ g x (h y)) →
               h ∘ foldr f e ≗ foldr g (h e)
foldr-fusion h {f} {g} e fuse =
  foldr-universal (h ∘ foldr f e) g (h e) refl
                  (λ x xs → fuse x (foldr f e xs))

idIsFold : ∀ {a} → id {a = List a} ≗ foldr _∷_ []
idIsFold = foldr-universal id _∷_ [] refl (λ _ _ → refl)

++IsFold : ∀ {a} (xs ys : List a) →
           xs ++ ys ≡ foldr _∷_ ys xs
++IsFold xs ys =
  begin
    xs ++ ys
  ≡⟨ cong (λ xs → xs ++ ys) (idIsFold xs) ⟩
    foldr _∷_ [] xs ++ ys
  ≡⟨ foldr-fusion (λ xs → xs ++ ys) [] (λ _ _ → refl) xs ⟩
    foldr _∷_ ([] ++ ys) xs
  ≡⟨ refl ⟩
    foldr _∷_ ys xs
  ∎
  where open ≡-Reasoning

mapIsFold : ∀ {a b} {f : a → b} →
            map f ≗ foldr (λ x ys → f x ∷ ys) []
mapIsFold {f = f} =
  begin
    map f
  ≈⟨ cong (map f) ∘ idIsFold ⟩
    map f ∘ foldr _∷_ []
  ≈⟨ foldr-fusion (map f) [] (λ _ _ → refl) ⟩
    foldr (λ x ys → f x ∷ ys) []
  ∎
  where open Eq (_ →-setoid _)

concat-map : ∀ {a b} {f : a → b} →
             concat ∘ map (map f) ≗ map f ∘ concat
concat-map {f = f} =
  begin
    concat ∘ map (map f)
  ≈⟨ cong concat ∘ mapIsFold ⟩
    concat ∘ foldr (λ xs ys → map f xs ∷ ys) []
  ≈⟨ foldr-fusion concat [] (λ _ _ → refl) ⟩
    foldr (λ ys zs → map f ys ++ zs) []
  ≈⟨ sym ∘
     foldr-fusion (map f) [] (λ ys zs → map-++-commute f ys zs) ⟩
    map f ∘ concat
  ∎
  where open Eq (_ →-setoid _)

map-id : ∀ {A} → map id ≗ id {List A}
map-id = begin
  map id        ≈⟨ mapIsFold ⟩
  foldr _∷_ []  ≈⟨ sym ∘ idIsFold ⟩
  id            ∎
  where open Eq (_ →-setoid _)

map-compose : ∀ {a b c} {g : b → c} {f : a → b} →
              map (g ∘ f) ≗ map g ∘ map f
map-compose {g = g} {f} =
  begin
    map (g ∘ f)
  ≈⟨ cong (map (g ∘ f)) ∘ idIsFold ⟩
    map (g ∘ f) ∘ foldr _∷_ []
  ≈⟨ foldr-fusion (map (g ∘ f)) [] (λ _ _ → refl) ⟩
    foldr (λ a y → g (f a) ∷ y) []
  ≈⟨ sym ∘ foldr-fusion (map g) [] (λ _ _ → refl) ⟩
    map g ∘ foldr (λ a y → f a ∷ y) []
  ≈⟨ cong (map g) ∘ sym ∘ mapIsFold ⟩
    map g ∘ map f
  ∎
  where open Eq (_ →-setoid _)

foldr-cong : ∀ {a b} {f₁ f₂ : a → b → b} {e₁ e₂ : b} →
             (∀ x y → f₁ x y ≡ f₂ x y) → e₁ ≡ e₂ →
             foldr f₁ e₁ ≗ foldr f₂ e₂
foldr-cong {f₁ = f₁} {f₂} {e} f₁≗₂f₂ refl =
  begin
    foldr f₁ e
  ≈⟨ cong (foldr f₁ e) ∘ idIsFold ⟩
    foldr f₁ e ∘ foldr _∷_ []
  ≈⟨ foldr-fusion (foldr f₁ e) [] (λ x xs → f₁≗₂f₂ x (foldr f₁ e xs)) ⟩
    foldr f₂ e
  ∎
  where open Eq (_ →-setoid _)

map-cong : ∀ {a b} {f g : a → b} → f ≗ g → map f ≗ map g
map-cong {f = f} {g} f≗g =
  begin
    map f
  ≈⟨ mapIsFold ⟩
    foldr (λ x ys → f x ∷ ys) []
  ≈⟨ foldr-cong (λ x ys → cong₂ _∷_ (f≗g x) refl) refl ⟩
    foldr (λ x ys → g x ∷ ys) []
  ≈⟨ sym ∘ mapIsFold ⟩
    map g
  ∎
  where open Eq (_ →-setoid _)

-- Take, drop, and splitAt.

take++drop : ∀ {a} n (xs : List a) → take n xs ++ drop n xs ≡ xs
take++drop zero    xs       = refl
take++drop (suc n) []       = refl
take++drop (suc n) (x ∷ xs) =
  cong (λ xs → x ∷ xs) (take++drop n xs)

splitAt-defn : ∀ {a} n → splitAt {a} n ≗ < take n , drop n >
splitAt-defn zero    xs       = refl
splitAt-defn (suc n) []       = refl
splitAt-defn (suc n) (x ∷ xs) with splitAt n xs | splitAt-defn n xs
... | (ys , zs) | ih = cong (Prod.map (_∷_ x) id) ih

-- TakeWhile, dropWhile, and span.

takeWhile++dropWhile : ∀ {a} (p : a → Bool) (xs : List a) →
                       takeWhile p xs ++ dropWhile p xs ≡ xs
takeWhile++dropWhile p []       = refl
takeWhile++dropWhile p (x ∷ xs) with p x
... | true  = cong (_∷_ x) (takeWhile++dropWhile p xs)
... | false = refl

span-defn : ∀ {a} (p : a → Bool) →
            span p ≗ < takeWhile p , dropWhile p >
span-defn p []       = refl
span-defn p (x ∷ xs) with p x
... | true  = cong (Prod.map (_∷_ x) id) (span-defn p xs)
... | false = refl

-- Partition.

partition-defn : ∀ {a} (p : a → Bool) →
                 partition p ≗ < filter p , filter (not ∘ p) >
partition-defn p []       = refl
partition-defn p (x ∷ xs)
 with p x | partition p xs | partition-defn p xs
...  | true  | (ys , zs) | eq = cong (Prod.map (_∷_ x) id) eq
...  | false | (ys , zs) | eq = cong (Prod.map id (_∷_ x)) eq

-- Inits, tails, and scanr.

scanr-defn : ∀ {a b} (f : a → b → b) (e : b) →
             scanr f e ≗ map (foldr f e) ∘ tails
scanr-defn f e []             = refl
scanr-defn f e (x ∷ [])       = refl
scanr-defn f e (x₁ ∷ x₂ ∷ xs)
  with scanr f e (x₂ ∷ xs) | scanr-defn f e (x₂ ∷ xs)
...  | [] | ()
...  | y ∷ ys | eq with ∷-injective eq
...        | y≡fx₂⦇f⦈xs , _ = cong₂ (λ z zs → f x₁ z ∷ zs) y≡fx₂⦇f⦈xs eq

scanl-defn : ∀ {a b} (f : a → b → a) (e : a) →
             scanl f e ≗ map (foldl f e) ∘ inits
scanl-defn f e []       = refl
scanl-defn f e (x ∷ xs) = cong (_∷_ e) (begin
     scanl f (f e x) xs
  ≡⟨ scanl-defn f (f e x) xs ⟩
     map (foldl f (f e x)) (inits xs)
  ≡⟨ refl ⟩
     map (foldl f e ∘ (_∷_ x)) (inits xs)
  ≡⟨ map-compose (inits xs) ⟩
     map (foldl f e) (map (_∷_ x) (inits xs))
  ∎)
  where open ≡-Reasoning

-- Length.

length-map : ∀ {A B} (f : A → B) xs →
             length (map f xs) ≡ length xs
length-map f []       = refl
length-map f (x ∷ xs) = cong suc (length-map f xs)

length-gfilter : ∀ {A B} (p : A → Maybe B) xs →
                 length (gfilter p xs) ≤ length xs
length-gfilter p []       = z≤n
length-gfilter p (x ∷ xs) with p x
length-gfilter p (x ∷ xs) | just y  = s≤s (length-gfilter p xs)
length-gfilter p (x ∷ xs) | nothing = ≤-step (length-gfilter p xs)

-- _∈_.

∈-++ˡ : ∀ {A} {x : A} {xs ys} → x ∈ xs → x ∈ xs ++ ys
∈-++ˡ (here refl)  = here refl
∈-++ˡ (there x∈xs) = there (∈-++ˡ x∈xs)

∈-++ʳ : ∀ {A} {x : A} xs {ys} → x ∈ ys → x ∈ xs ++ ys
∈-++ʳ []       x∈ys = x∈ys
∈-++ʳ (x ∷ xs) x∈ys = there (∈-++ʳ xs x∈ys)

++-∈ : ∀ {A} {x : A} xs {ys} → x ∈ xs ++ ys → x ∈ xs ⊎ x ∈ ys
++-∈ []       x∈ys             = inj₂ x∈ys
++-∈ (x ∷ xs) (here refl)      = inj₁ (here refl)
++-∈ (x ∷ xs) (there x∈xs++ys) = Sum.map there id (++-∈ xs x∈xs++ys)

_++-mono_ : ∀ {A} {xs₁ xs₂ ys₁ ys₂ : List A} →
            xs₁ ⊆ ys₁ → xs₂ ⊆ ys₂ → xs₁ ++ xs₂ ⊆ ys₁ ++ ys₂
_++-mono_ {ys₁ = ys₁} xs₁⊆ys₁ xs₂⊆ys₂ =
  [ ∈-++ˡ ∘ xs₁⊆ys₁ , ∈-++ʳ ys₁ ∘ xs₂⊆ys₂ ]′ ∘ ++-∈ _

++-idempotent : ∀ {A} {xs : List A} → xs ++ xs ⊆ xs
++-idempotent = [ id , id ]′ ∘ ++-∈ _

∈-map : ∀ {A B} {f : A → B} {x xs} →
        x ∈ xs → f x ∈ map f xs
∈-map {f = f} = Any.gmap (cong f)

map-∈ : ∀ {A B} {f : A → B} {fx} xs →
        fx ∈ map f xs → ∃ λ x → x ∈ xs × f x ≡ fx
map-∈ []       ()
map-∈ (x ∷ xs) (here refl)    = (x , here refl , refl)
map-∈ (x ∷ xs) (there fx∈fxs) =
  Prod.map id (Prod.map there id) (map-∈ xs fx∈fxs)

map-mono : ∀ {A B} {f : A → B} {xs ys} →
           xs ⊆ ys → map f xs ⊆ map f ys
map-mono xs⊆ys fx∈ with map-∈ _ fx∈
... | (x , x∈ , refl) = ∈-map (xs⊆ys x∈)

∈-concat : ∀ {A} {x : A} {xs xss} →
           x ∈ xs → xs ∈ xss → x ∈ concat xss
∈-concat x∈xs (here refl)             = ∈-++ˡ x∈xs
∈-concat x∈xs (there {x = ys} xs∈xss) = ∈-++ʳ ys (∈-concat x∈xs xs∈xss)

concat-∈ : ∀ {A} {x : A} xss →
           x ∈ concat xss → ∃ λ xs → x ∈ xs × xs ∈ xss
concat-∈ []               ()
concat-∈ ([]       ∷ xss) x∈cxss         = Prod.map id (Prod.map id there)
                                             (concat-∈ xss x∈cxss)
concat-∈ ((x ∷ xs) ∷ xss) (here refl)    = (x ∷ xs , here refl , here refl)
concat-∈ ((y ∷ xs) ∷ xss) (there x∈cxss) with concat-∈ (xs ∷ xss) x∈cxss
... | (.xs , x∈xs , here refl)    = (y ∷ xs , there x∈xs , here refl)
... | (ys  , x∈ys , there ys∈xss) = (ys     , x∈ys       , there ys∈xss)

concat-mono : ∀ {A} {xss yss : List (List A)} →
              xss ⊆ yss → concat xss ⊆ concat yss
concat-mono {xss = xss} xss⊆yss x∈ with concat-∈ xss x∈
... | (xs , x∈xs , xs∈xss) = ∈-concat x∈xs (xss⊆yss xs∈xss)

∈->>= : ∀ {A B} (f : A → List B) {x y xs} →
        x ∈ xs → y ∈ f x → y ∈ (xs >>= f)
∈->>= f x∈xs y∈fx = ∈-concat y∈fx (∈-map x∈xs)

>>=-∈ : ∀ {A B} (f : A → List B) {y} xs →
        y ∈ (xs >>= f) → ∃ λ x → x ∈ xs × y ∈ f x
>>=-∈ f xs y∈xs>>=f with Prod.map id (Prod.map id (map-∈ xs)) $
                           concat-∈ (map f xs) y∈xs>>=f
>>=-∈ f xs y∈xs>>=f | (.(f x) , y∈fx , (x , x∈xs , refl)) =
  (x , x∈xs , y∈fx)

_>>=-mono_ : ∀ {A B} {f g : A → List B} {xs ys} →
             xs ⊆ ys → (∀ {x} → f x ⊆ g x) →
             (xs >>= f) ⊆ (ys >>= g)
_>>=-mono_ {f = f} {g} {xs} xs⊆ys f⊆g z∈ with >>=-∈ f xs z∈
... | (x , x∈xs , z∈fx) = ∈->>= g (xs⊆ys x∈xs) (f⊆g z∈fx)

∈-⊛ : ∀ {A B} {fs : List (A → B)} {xs f x} →
      f ∈ fs → x ∈ xs → f x ∈ fs ⊛ xs
∈-⊛ f∈xs x∈xs = ∈->>= _ f∈xs (∈->>= _ x∈xs (here refl))

⊛-∈ : ∀ {A B} (fs : List (A → B)) xs {fx} →
      fx ∈ fs ⊛ xs → ∃₂ λ f x → f ∈ fs × x ∈ xs × f x ≡ fx
⊛-∈ fs xs fx∈fs⊛xs with >>=-∈ _ fs fx∈fs⊛xs
⊛-∈ fs xs fx∈fs⊛xs | (f , f∈fs , fx∈) with >>=-∈ _ xs fx∈
⊛-∈ fs xs fx∈fs⊛xs | (f , f∈fs , fx∈) | (x , x∈xs , here refl) =
  (f , x , f∈fs , x∈xs , refl)
⊛-∈ fs xs fx∈fs⊛xs | (f , f∈fs , fx∈) | (x , x∈xs , there ())

_⊛-mono_ : ∀ {A B} {fs gs : List (A → B)} {xs ys} →
           fs ⊆ gs → xs ⊆ ys → fs ⊛ xs ⊆ gs ⊛ ys
_⊛-mono_ {fs = fs} {gs} {xs} fs⊆gs xs⊆ys fx∈ with ⊛-∈ fs xs fx∈
... | (f , x , f∈fs , x∈xs , refl) = ∈-⊛ (fs⊆gs f∈fs) (xs⊆ys x∈xs)

-- any and all.

Any-any : ∀ {A} (p : A → Bool) {xs} →
          Any (T ∘₀ p) xs → T (any p xs)
Any-any p (here  px)  = proj₂ T-∨ (inj₁ px)
Any-any p (there {x = x} pxs) with p x
... | true  = _
... | false = Any-any p pxs

any-Any : ∀ {A} (p : A → Bool) xs →
          T (any p xs) → Any (T ∘₀ p) xs
any-Any p []       ()
any-Any p (x ∷ xs) px∷xs with inspect (p x)
any-Any p (x ∷ xs) px∷xs | true  with-≡ eq   = here (proj₂ T-≡ (sym eq))
any-Any p (x ∷ xs) px∷xs | false with-≡ eq   with p x
any-Any p (x ∷ xs) pxs   | false with-≡ refl | .false =
  there (any-Any p xs pxs)

any-mono : ∀ {A} (p : A → Bool) {xs ys} →
           xs ⊆ ys → T (any p xs) → T (any p ys)
any-mono p xs⊆ys = Any-any p ∘ Any.mono xs⊆ys ∘ any-Any p _

All-all : ∀ {A} (p : A → Bool) {xs} →
          All (T ∘₀ p) xs → T (all p xs)
All-all p []         = _
All-all p (px ∷ pxs) = proj₂ T-∧ (px , All-all p pxs)

all-All : ∀ {A} (p : A → Bool) xs →
          T (all p xs) → All (T ∘₀ p) xs
all-All p []       _     = []
all-All p (x ∷ xs) px∷xs with proj₁ (T-∧ {p x}) px∷xs
all-All p (x ∷ xs) px∷xs | (px , pxs) = px ∷ all-All p xs pxs

-- all is /anti/-monotone.

all-anti-mono : ∀ {A} (p : A → Bool) {xs ys} →
                xs ⊆ ys → T (all p ys) → T (all p xs)
all-anti-mono p xs⊆ys = All-all p ∘ All.anti-mono xs⊆ys ∘ all-All p _
