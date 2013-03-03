module SfLib-J where

-- Coq スタンダードライブラリから ---------------------------------------------
-- とのことなので ここでAgda標準ライブラリのほうの定義を解禁
open import Level as Level using ()
open import Function public
open import Data.Nat public hiding (_≟_)
open import Data.Bool public hiding (_≟_; decSetoid)
open import Data.Product public hiding (map; zip)
open import Data.Empty public
open import Data.List public hiding (monad; monadPlus; monadZero)
open import Data.Maybe public hiding (decSetoid; monad; monadPlus; monadZero)
open import Relation.Nullary public
open import Relation.Binary public
import Relation.Binary.PropositionalEquality as PropEq
open PropEq public using (_≡_; _≢_; refl; cong; sym)

-- Require Export相当とはいえこのpublicの山は嫌過ぎる

-- というか，Agdaで書き直してみる趣旨からすると．
-- CoqのBool/List/Arith/Arith.EqNatあたりのモジュールの中身を
-- この中で全部定義しとくべきなんだろうけど，
-- そんなのめんどいので必要なら追加で．

-- Basics.vから ---------------------------------------------------------------
beq-nat : ℕ → ℕ → Bool
beq-nat zero zero = true
beq-nat zero (suc m) = false
beq-nat (suc n) zero = false
beq-nat (suc n) (suc m) = beq-nat n m

ble-nat : ℕ → ℕ → Bool
ble-nat zero m = true
ble-nat (suc n) zero = false
ble-nat (suc n) (suc m) = ble-nat n m

andb-true-elim1 : ∀ b c → b ∧ c ≡ true → b ≡ true
andb-true-elim1 true c b∧c≡t = refl
andb-true-elim1 false c b∧c≡t = b∧c≡t

andb-true-elim2 : ∀ b c → b ∧ c ≡ true → c ≡ true
andb-true-elim2 b true b∧c≡t = refl
andb-true-elim2 true false b∧c=t = b∧c=t
andb-true-elim2 false false b∧c=t = b∧c=t

beq-nat-sym : ∀ n m → beq-nat n m ≡ beq-nat m n
beq-nat-sym zero zero = refl
beq-nat-sym zero (suc m) = refl
beq-nat-sym (suc n) zero = refl
beq-nat-sym (suc n) (suc m) = beq-nat-sym n m

-- Prop.vから -----------------------------------------------------------------
data ev : ℕ → Set where
  ev-0 : ev 0
  ev-SS : ∀ n → ev n → ev (suc (suc n))

-- Logic.vから ----------------------------------------------------------------
andb-true : ∀ b c → b ∧ c ≡ true → b ≡ true × c ≡ true
andb-true true c b∧c≡t = refl , b∧c≡t
andb-true false true b∧c≡t = b∧c≡t , refl
andb-true false false b∧c≡t = b∧c≡t , b∧c≡t

not-eq-beq-false : ∀ n n' → n ≢ n' → beq-nat n n' ≡ false
not-eq-beq-false zero zero n≢n' = ⊥-elim (n≢n' refl)
not-eq-beq-false zero (suc n') n≢n' = refl
not-eq-beq-false (suc n) zero n≢n' = refl
not-eq-beq-false (suc n) (suc n') n≢n' = not-eq-beq-false n n' (n≢n' ∘ cong suc)

ev-not-ev-S : ∀ n → ev n → ¬ ev (suc n)
ev-not-ev-S .(suc n) ev-n (ev-SS n ev-Sn) = ev-not-ev-S n ev-Sn ev-n

ble-nat-true : ∀ n m → ble-nat n m ≡ true → n ≤ m
ble-nat-true zero m ble = z≤n
ble-nat-true (suc n) zero ()
ble-nat-true (suc n) (suc m) ble = s≤s (ble-nat-true n m ble)

ble-nat-false : ∀ n m → ble-nat n m ≡ false → ¬ n ≤ m
ble-nat-false zero m ()
ble-nat-false (suc n) zero ble = λ ()
ble-nat-false (suc n) (suc m) ble = λ { (s≤s n≤m) → ble-nat-false n m ble n≤m }

data appears-in {x} {X : Set x} (a : X) : List X → Set x where
  ai-here : ∀ ls → appears-in a (a ∷ ls)
  ai-later : ∀ b ls → appears-in a ls → appears-in a (b ∷ ls)

data next-nat (n : ℕ) : ℕ → Set where
  nn : next-nat n (suc n)

data total-relation : ℕ → ℕ → Set where
  tot : ∀ n m → total-relation n m

data empty-relation : ℕ → ℕ → Set where

-- Rel.vから ------------------------------------------------------------------
partial-function : ∀ {a b} {X : Set a} (R : Rel X b) → Set (a Level.⊔ b)
partial-function R = ∀ x y₁ y₂ → R x y₁ → R x y₂ → y₁ ≡ y₂

data refl-step-closure {a b} {X : Set a} (R : Rel X b) : X → X → Set (a Level.⊔ b) where
  rsc-refl : ∀ x → refl-step-closure R x x
  rsc-step : ∀ x y z → R x y → refl-step-closure R y z → refl-step-closure R x z

rsc-R : ∀ {a b} {X : Set a} (R : Rel X b) (x y : X) →
        R x y → refl-step-closure R x y
rsc-R = λ R x y z → rsc-step x y y z (rsc-refl y)

rsc-trans : ∀ {a b} {X : Set a} (R : Rel X b) (x y z : X) →
            refl-step-closure R x y → refl-step-closure R y z → refl-step-closure R x z
rsc-trans R .y y z (rsc-refl .y) rsc₂ = rsc₂
rsc-trans R x y z (rsc-step .x y₁ .y x₁ rsc₁) rsc₂ = rsc-step x y₁ z x₁ (rsc-trans R y₁ y z rsc₁ rsc₂)

suc-inversion : ∀ n m → suc n ≡ suc m → n ≡ m
suc-inversion .m m refl = refl

data idℕ : Set where
  Idℕ : ℕ → idℕ

Idℕ-inversion : ∀ n m → Idℕ n ≡ Idℕ m → n ≡ m
Idℕ-inversion .m m refl = refl

beq-id : idℕ → idℕ → Bool
beq-id (Idℕ n) (Idℕ m) = beq-nat n m

beq-nat-refl : ∀ n → true ≡ beq-nat n n
beq-nat-refl zero = refl
beq-nat-refl (suc n) = beq-nat-refl n

beq-nat-eq : ∀ n m → true ≡ beq-nat n m → n ≡ m
beq-nat-eq zero zero t = refl
beq-nat-eq zero (suc m) ()
beq-nat-eq (suc n) zero ()
beq-nat-eq (suc n) (suc m) t = cong suc (beq-nat-eq n m t)

beq-nat-false : ∀ n m → beq-nat n m ≡ false → n ≢ m
beq-nat-false zero zero ()
beq-nat-false zero (suc m) f₁ = λ ()
beq-nat-false (suc n) zero f₁ = λ ()
beq-nat-false (suc n) (suc m) f₁ = beq-nat-false n m f₁ ∘ suc-inversion n m

beq-id-refl : ∀ i → true ≡ beq-id i i
beq-id-refl (Idℕ n) = beq-nat-refl n

beq-id-eq : ∀ i₁ i₂ → true ≡ beq-id i₁ i₂ → i₁ ≡ i₂
beq-id-eq (Idℕ n) (Idℕ m) t = cong Idℕ (beq-nat-eq n m t)

beq-id-false-not-eq : ∀ i₁ i₂ → beq-id i₁ i₂ ≡ false → i₁ ≢ i₂
beq-id-false-not-eq (Idℕ n) (Idℕ m) f = beq-nat-false n m f ∘ Idℕ-inversion n m

not-eq-beq-id-false : ∀ i₁ i₂ → i₁ ≢ i₂ → beq-id i₁ i₂ ≡ false
not-eq-beq-id-false (Idℕ n) (Idℕ m) i₁≢i₂ = not-eq-beq-false n m (i₁≢i₂ ∘ cong Idℕ)

beq-id-sym : ∀ i₁ i₂ → beq-id i₁ i₂ ≡ beq-id i₂ i₁
beq-id-sym (Idℕ n) (Idℕ m) = beq-nat-sym n m

partial-map : ∀ {a} (X : Set a) → Set a
partial-map X = idℕ → Maybe X

empty : ∀ {a} {X : Set a} → partial-map X
empty = const nothing

extend : ∀ {a} {X : Set a} (Γ : partial-map X) (x : idℕ) (T : X) → idℕ → Maybe X
extend Γ x T = λ x' → if beq-id x x' then just T else Γ x'

extend-eq : ∀ {a} {X : Set a} (ctxt : partial-map X) x T → extend ctxt x T x ≡ just T
extend-eq ctxt x T rewrite sym (beq-id-refl x) = refl

extend-neq : ∀ {a} {X : Set a} (ctxt : partial-map X) x1 T x2 →
             beq-id x2 x1 ≡ false → extend ctxt x2 T x1 ≡ ctxt x1
extend-neq ctxt x₁ T x₂ neq rewrite neq = refl

extend-shadow : ∀ {a} {X : Set a} (ctxt : partial-map X) t1 t2 x1 x2 →
                extend (extend ctxt x2 t1) x2 t2 x1 ≡ extend ctxt x2 t2 x1
extend-shadow ctxt t1 t2 x1 x2 with beq-id x2 x1
extend-shadow ctxt t1 t2 x1 x2 | true = refl
extend-shadow ctxt t1 t2 x1 x2 | false = refl

-- 使い勝手のいいタクティックをいくつか ---------------------------------------