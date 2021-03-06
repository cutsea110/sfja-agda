module Imp-J where

------ Sflib ------------------------------------------------------------------
open import SfLib-J

-- 算術式とブール式 -----------------------------------------------------------
module AExp where

---- 構文 ---------------------------------------------------------------------
  data aexp : Set where
    ANum : ℕ → aexp
    APlus : aexp → aexp → aexp
    AMinus : aexp → aexp → aexp
    AMult : aexp → aexp → aexp

  data bexp : Set where
    BTrue : bexp
    BFalse : bexp
    BEq : aexp → aexp → bexp
    BLe : aexp → aexp → bexp
    BNot : bexp → bexp
    BAnd : bexp → bexp → bexp

---- 評価 ---------------------------------------------------------------------
  aeval : aexp → ℕ
  aeval (ANum n) = n
  aeval (APlus exp₁ exp₂) = aeval exp₁ + aeval exp₂
  aeval (AMinus exp₁ exp₂) = aeval exp₁ ∸ aeval exp₂
  aeval (AMult exp₁ exp₂) = aeval exp₁ * aeval exp₂

  test-aeval1 : aeval (APlus (ANum 2) (ANum 2)) ≡ 4
  test-aeval1 = refl

  beval : bexp → Bool
  beval BTrue = true
  beval BFalse = false
  beval (BEq exp₁ exp₂) = beq-nat (aeval exp₁) (aeval exp₂)
  beval (BLe exp₁ exp₂) = ble-nat (aeval exp₁) (aeval exp₂)
  beval (BNot exp) = not (beval exp)
  beval (BAnd exp₁ exp₂) = beval exp₁ ∧ beval exp₂

---- 最適化(Optimization) -----------------------------------------------------
  optimize-0plus : aexp → aexp
  optimize-0plus (ANum n) = ANum n
  optimize-0plus (APlus (ANum 0) exp₂) = optimize-0plus exp₂
  optimize-0plus (APlus exp₁ exp₂) = APlus (optimize-0plus exp₁) (optimize-0plus exp₂)
  optimize-0plus (AMinus exp₁ exp₂) = AMinus (optimize-0plus exp₁) (optimize-0plus exp₂)
  optimize-0plus (AMult exp₁ exp₂) = AMult (optimize-0plus exp₁) (optimize-0plus exp₂)

  test-optimize-0plus : optimize-0plus
                          (APlus (ANum 2) (APlus (ANum 0) (APlus (ANum 0) (ANum 1))))
                          ≡ APlus (ANum 2) (ANum 1)
  test-optimize-0plus = refl

  optimize-0plus-sound : ∀ e → aeval (optimize-0plus e) ≡ aeval e
  optimize-0plus-sound (ANum x) = refl
  optimize-0plus-sound (APlus (ANum zero) exp₂) = optimize-0plus-sound exp₂
  optimize-0plus-sound (APlus (ANum (suc n)) exp₂)
    rewrite optimize-0plus-sound exp₂
          = refl
  optimize-0plus-sound (APlus (APlus exp₁ exp₂) exp₃)
    rewrite optimize-0plus-sound (APlus exp₁ exp₂)
          | optimize-0plus-sound exp₃
          = refl
  optimize-0plus-sound (APlus (AMinus exp₁ exp₂) exp₃)
    rewrite optimize-0plus-sound (AMinus exp₁ exp₂)
          | optimize-0plus-sound exp₃
          = refl
  optimize-0plus-sound (APlus (AMult exp₁ exp₂) exp₃)
    rewrite optimize-0plus-sound (AMult exp₁ exp₂)
          | optimize-0plus-sound exp₃
          = refl
  optimize-0plus-sound (AMinus exp₁ exp₂)
    rewrite optimize-0plus-sound exp₁
          | optimize-0plus-sound exp₂
          = refl
  optimize-0plus-sound (AMult exp₁ exp₂)
    rewrite optimize-0plus-sound exp₁
          | optimize-0plus-sound exp₂
          = refl

-- Coq の自動化 ---------------------------------------------------------------

-- このへんからAgdaだとキツくなってくる予感

---- タクティカル(Tacticals) --------------------------------------------------

------ tryタクティカル --------------------------------------------------------

------ ;タクティカル ----------------------------------------------------------

--- NEEEEEEEEEEEEEEEEEEE

---- 新しいタクティック記法を定義する -----------------------------------------
----- 場合分けを万全にする ----------------------------------------------------

{-
練習問題: ★★★ (optimize_0plus_b)

optimize_0plusの変換がaexpの値を変えないことから、 bexpの値を変えずに、bexpに現れるaexpをすべて変換するために optimize_0plusが適用できるべきでしょう。 bexpについてこの変換をする関数を記述しなさい。そして、 それが健全であることを証明しなさい。 ここまで見てきたタクティカルを使って証明を可能な限りエレガントにしなさい。
-}
  optimize-0plus-b : bexp → bexp
  optimize-0plus-b BTrue = BTrue
  optimize-0plus-b BFalse = BFalse
  optimize-0plus-b (BEq exp₁ exp₂) = BEq (optimize-0plus exp₁) (optimize-0plus exp₂)
  optimize-0plus-b (BLe exp₁ exp₂) = BLe (optimize-0plus exp₁) (optimize-0plus exp₂)
  optimize-0plus-b (BNot exp) = BNot (optimize-0plus-b exp)
  optimize-0plus-b (BAnd exp₁ exp₂) = BAnd (optimize-0plus-b exp₁) (optimize-0plus-b exp₂)

  optimize-0plus-b-sound : ∀ e → beval (optimize-0plus-b e) ≡ beval e
  optimize-0plus-b-sound BTrue = refl
  optimize-0plus-b-sound BFalse = refl
  optimize-0plus-b-sound (BEq exp₁ exp₂)
    rewrite optimize-0plus-sound exp₁
          | optimize-0plus-sound exp₂
          = refl
  optimize-0plus-b-sound (BLe exp₁ exp₂)
    rewrite optimize-0plus-sound exp₁
          | optimize-0plus-sound exp₂
          = refl
  optimize-0plus-b-sound (BNot exp₁)
    rewrite optimize-0plus-b-sound exp₁
          = refl
  optimize-0plus-b-sound (BAnd exp₁ exp₂)
    rewrite optimize-0plus-b-sound exp₁
          | optimize-0plus-b-sound exp₂
          = refl
{-
練習問題: ★★★★, optional (optimizer)

設計練習: 定義したoptimize_0plus関数で実装された最適化は、 算術式やブール式に対して考えられるいろいろな最適化の単なる1つに過ぎません。 より洗練された最適化関数を記述し、その正しさを証明しなさい。
-}
  optimize-false-and-b : bexp → bexp
  optimize-false-and-b BTrue = BTrue
  optimize-false-and-b BFalse = BFalse
  optimize-false-and-b (BEq exp₁ exp₂) = BEq exp₁ exp₂
  optimize-false-and-b (BLe exp₁ exp₂) = BLe exp₁ exp₂
  optimize-false-and-b (BNot exp₁) = BNot (optimize-false-and-b exp₁)
  optimize-false-and-b (BAnd BTrue exp₂) = exp₂
  optimize-false-and-b (BAnd BFalse exp₂) = BFalse
  optimize-false-and-b (BAnd exp₁ exp₂) = BAnd (optimize-false-and-b exp₁) (optimize-false-and-b exp₂)

  optimize-false-and-b-sound : ∀ e → beval (optimize-false-and-b e) ≡ beval e
  optimize-false-and-b-sound BTrue = refl
  optimize-false-and-b-sound BFalse = refl
  optimize-false-and-b-sound (BEq x x₁) = refl
  optimize-false-and-b-sound (BLe x x₁) = refl
  optimize-false-and-b-sound (BNot exp₁)
    rewrite optimize-false-and-b-sound exp₁
          = refl
  optimize-false-and-b-sound (BAnd BTrue exp₂) = refl
  optimize-false-and-b-sound (BAnd BFalse exp₂) = refl
  optimize-false-and-b-sound (BAnd (BEq x x₁) exp₂)
    rewrite optimize-false-and-b-sound exp₂
          = refl
  optimize-false-and-b-sound (BAnd (BLe x x₁) exp₂)
    rewrite optimize-false-and-b-sound exp₂
          = refl
  optimize-false-and-b-sound (BAnd (BNot exp₁) exp₂)
    rewrite optimize-false-and-b-sound (BNot exp₁)
          | optimize-false-and-b-sound exp₂
          = refl
  optimize-false-and-b-sound (BAnd (BAnd exp₁ exp₂) exp₃)
    rewrite optimize-false-and-b-sound (BAnd exp₁ exp₂)
          | optimize-false-and-b-sound exp₃
          = refl

---- omegaタクティック --------------------------------------------------------
--- 甘え

---- 便利なタクティックをさらにいくつか ---------------------------------------
--- 甘え

-- 関係としての評価 -----------------------------------------------------------
  module aevalR-first-try where

    data aevalR : aexp → ℕ → Set where
      E-ANum : ∀ n → aevalR (ANum n) n
      E-APlus : ∀ e1 e2 n1 n2 → aevalR e1 n1 → aevalR e2 n2 → aevalR (APlus e1 e2) (n1 + n2)
      E-AMinus : ∀ e1 e2 n1 n2 → aevalR e1 n1 → aevalR e2 n2 → aevalR (AMinus e1 e2) (n1 ∸ n2)
      E-AMult : ∀ e1 e2 n1 n2 → aevalR e1 n1 → aevalR e2 n2 → aevalR (AMult e1 e2) (n1 * n2)

    _⇓_ = aevalR

  data _aeval⇓_ : aexp → ℕ → Set where
    E-ANum : ∀ n → ANum n aeval⇓ n
    E-APlus : ∀ e1 e2 n1 n2 → e1 aeval⇓ n1 → e2 aeval⇓ n2 → APlus e1 e2 aeval⇓ (n1 + n2)
    E-AMinus : ∀ e1 e2 n1 n2 → e1 aeval⇓ n1 → e2 aeval⇓ n2 → AMinus e1 e2 aeval⇓ (n1 ∸ n2)
    E-AMult : ∀ e1 e2 n1 n2 → e1 aeval⇓ n1 → e2 aeval⇓ n2 → AMult e1 e2 aeval⇓ (n1 * n2)

  open import Function.Equivalence hiding (sym)

  aeval-iff-aeval⇓ : ∀ a n → (a aeval⇓ n) ⇔ aeval a ≡ n
  aeval-iff-aeval⇓ = λ a n → equivalence (left a n) (right a n)
    where
      left : ∀ a n → a aeval⇓ n → aeval a ≡ n
      left .(ANum b) b (E-ANum .b) = refl
      left .(APlus e1 e2) .(n1 + n2) (E-APlus e1 e2 n1 n2 aaeval⇓n aaeval⇓n₁)
        rewrite left e1 n1 aaeval⇓n
              | left e2 n2 aaeval⇓n₁
              = refl
      left .(AMinus e1 e2) .(n1 ∸ n2) (E-AMinus e1 e2 n1 n2 aaeval⇓n aaeval⇓n₁)
        rewrite left e1 n1 aaeval⇓n
              | left e2 n2 aaeval⇓n₁
              = refl
      left .(AMult e1 e2) .(n1 * n2) (E-AMult e1 e2 n1 n2 aaeval⇓n aaeval⇓n₁)
        rewrite left e1 n1 aaeval⇓n
              | left e2 n2 aaeval⇓n₁
              = refl
      right : ∀ a n → aeval a ≡ n → a aeval⇓ n
      right (ANum x) n eq
        rewrite eq
              = E-ANum n
      right (APlus a a₁) n eq
        rewrite sym eq
              = E-APlus a a₁ (aeval a) (aeval a₁) (right a (aeval a) refl)
                  (right a₁ (aeval a₁) refl)
      right (AMinus a a₁) n eq
        rewrite sym eq
              = E-AMinus a a₁ (aeval a) (aeval a₁) (right a (aeval a) refl)
                  (right a₁ (aeval a₁) refl)
      right (AMult a a₁) n eq
        rewrite sym eq
              = E-AMult a a₁ (aeval a) (aeval a₁) (right a (aeval a) refl)
                  (right a₁ (aeval a₁) refl)
{-
練習問題: ★★, optional (bevalR)

関係bevalRをaevalRと同じスタイルで記述し、 それがbevalと同値であることを証明しなさい。
-}
  data _beval⇓_ : bexp → Bool → Set where
    E-BTrue : BTrue beval⇓ true
    E-BFalse : BFalse beval⇓ false
    E-BEq : ∀ e1 e2 n1 n2 → e1 aeval⇓ n1 → e2 aeval⇓ n2 → BEq e1 e2 beval⇓ (beq-nat n1 n2)
    E-BLe : ∀ e1 e2 n1 n2 → e1 aeval⇓ n1 → e2 aeval⇓ n2 → BLe e1 e2 beval⇓ (ble-nat n1 n2)
    E-BNot : ∀ e b → e beval⇓ b → BNot e beval⇓ (not b)
    E-BAnd : ∀ e1 e2 b1 b2 → e1 beval⇓ b1 → e2 beval⇓ b2 → BAnd e1 e2 beval⇓ (b1 ∧ b2)

  open import Function.Equality

  beval-iff-beval⇓ : ∀ e b → (e beval⇓ b) ⇔ beval e ≡ b
  beval-iff-beval⇓ = λ e b → equivalence (left e b) (right e b)
    where
      left : ∀ e b → e beval⇓ b → beval e ≡ b
      left .BTrue .true E-BTrue = refl
      left .BFalse .false E-BFalse = refl
      left .(BEq e1 e2) .(beq-nat n1 n2) (E-BEq e1 e2 n1 n2 x x₁)
        rewrite Equivalence.to (aeval-iff-aeval⇓ e1 n1) Π.⟨$⟩ x
              | Equivalence.to (aeval-iff-aeval⇓ e2 n2) Π.⟨$⟩ x₁
              = refl
      left .(BLe e1 e2) .(ble-nat n1 n2) (E-BLe e1 e2 n1 n2 x x₁)
        rewrite Equivalence.to (aeval-iff-aeval⇓ e1 n1) Π.⟨$⟩ x
              | Equivalence.to (aeval-iff-aeval⇓ e2 n2) Π.⟨$⟩ x₁
              = refl
      left .(BNot e) .(not b) (E-BNot e b e⇓b)
        rewrite left e b e⇓b
              = refl
      left .(BAnd e1 e2) .(b1 ∧ b2) (E-BAnd e1 e2 b1 b2 e⇓b e⇓b₁)
        rewrite left e1 b1 e⇓b
              | left e2 b2 e⇓b₁
              = refl
      right : ∀ e b → beval e ≡ b → e beval⇓ b
      right BTrue b eq rewrite sym eq = E-BTrue
      right BFalse b eq rewrite sym eq = E-BFalse
      right (BEq x x₁) b eq
        rewrite sym eq
              = E-BEq x x₁ (aeval x) (aeval x₁)
                  (Equivalence.from (aeval-iff-aeval⇓ x (aeval x)) ⟨$⟩ refl)
                  (Equivalence.from (aeval-iff-aeval⇓ x₁ (aeval x₁)) ⟨$⟩ refl)
      right (BLe x x₁) b eq
        rewrite sym eq
              = E-BLe x x₁ (aeval x) (aeval x₁)
                  (Equivalence.from (aeval-iff-aeval⇓ x (aeval x)) ⟨$⟩ refl)
                  (Equivalence.from (aeval-iff-aeval⇓ x₁ (aeval x₁)) ⟨$⟩ refl)
      right (BNot e) b eq
        rewrite sym eq
              = E-BNot e (beval e) (right e (beval e) refl)
      right (BAnd e e₁) b eq
        rewrite sym eq
              = E-BAnd e e₁ (beval e) (beval e₁) (right e (beval e) refl)
                  (right e₁ (beval e₁) refl)

---- 推論規則記法 -------------------------------------------------------------

-- 変数を持つ式 ---------------------------------------------------------------

---- 識別子 -------------------------------------------------------------------

---- 状態 ---------------------------------------------------------------------
state : Set
state = ident → ℕ

empty-state : state
empty-state = const 0

update : state → ident → ℕ → state
update st x n x' = if beq-id x x' then n else st x'

{-
練習問題: ★★, optional (update_eq)
-}
update-eq : ∀ n X st → update st X n X ≡ n
update-eq n X st
  rewrite sym (beq-id-refl X)
        = refl
{-
練習問題: ★★, optional (update_neq)
-}
update-neq : ∀ V2 V1 n st → beq-id V2 V1 ≡ false → update st V2 n V1 ≡ st V1
update-neq V2 V1 n st x
  rewrite x
        = refl

{-
練習問題: ★★, optional (update_example)

タクティックを使って遊び始める前に、 定理が言っていることを正確に理解していることを確認しなさい!
-}
update-example : ∀ n →  update empty-state (Ident 2) n (Ident 3) ≡ 0
update-example = λ n → refl

{-
練習問題: ★★ (update_shadow)
-}
update-shadow : ∀ x1 x2 k1 k2 f → update (update f k2 x1) k2 x2 k1 ≡ update f k2 x2 k1
update-shadow x1 x2 k1 k2 f with beq-id k2 k1
update-shadow x1 x2 k1 k2 f | true = refl
update-shadow x1 x2 k1 k2 f | false = refl

{-
練習問題: ★★, optional (update_same)
-}
-- これ f k1 = x1 ってあるけど f k2 = x1 だよね？
update-same : ∀ x1 k1 k2 f → f k2 ≡ x1 → update f k1 x1 k2 ≡ f k2
update-same x1 k1 k2 f eq rewrite eq with beq-id k1 k2
update-same x1 k1 k2 f eq | true = refl
update-same x1 k1 k2 f eq | false = refl

{-
練習問題: ★★, optional (update_permute)
-}
update-permute : ∀ x1 x2 k1 k2 k3 f → beq-id k2 k1 ≡ false →
                 update (update f k2 x1) k1 x2 k3 ≡ update (update f k1 x2) k2 x1 k3
update-permute x1 x2 k1 k2 k3 f x = update-permute' x1 x2 k1 k2 k3 f x (b≡t∨b≡f (beq-id k2 k3)) (b≡t∨b≡f (beq-id k1 k3))
  where
    b≡t∨b≡f : ∀ b → b ≡ true ⊎ b ≡ false
    b≡t∨b≡f true = inj₁ refl
    b≡t∨b≡f false = inj₂ refl
    update-permute' : ∀ x1 x2 k1 k2 k3 f → beq-id k2 k1 ≡ false →
                      beq-id k2 k3 ≡ true ⊎ beq-id k2 k3 ≡ false →
                      beq-id k1 k3 ≡ true ⊎ beq-id k1 k3 ≡ false →
                      update (update f k2 x1) k1 x2 k3 ≡ update (update f k1 x2) k2 x1 k3
    update-permute' x1 x2 k1 k2 k3 f x (inj₁ x₂) (inj₁ x₃)
      = ⊥-elim (beq-id-false-not-eq k2 k1 x (beq-id-eq k2 k3 (sym x₂) ⟨ trans ⟩ sym (beq-id-eq k1 k3 (sym x₃)) ))
    update-permute' x1 x2 k1 k2 k3 f x (inj₁ x₂) (inj₂ y)
      rewrite x₂
            | y
            | x
            = refl
    update-permute' x1 x2 k1 k2 k3 f x (inj₂ y) (inj₁ x₂)
      rewrite x₂
            | y
            | x
            = refl
    update-permute' x1 x2 k1 k2 k3 f x (inj₂ y) (inj₂ y₁)
      rewrite y
            | y₁
            | x
            = refl

---- 構文 ---------------------------------------------------------------------
data aexp : Set where
  ANum : ℕ → aexp
  AId : ident → aexp
  APlus : aexp → aexp → aexp
  AMinus : aexp → aexp → aexp
  AMult : aexp → aexp → aexp

X : ident
X = Ident 0
Y : ident
Y = Ident 1
Z : ident
Z = Ident 2

data bexp : Set where
  BTrue : bexp
  BFalse : bexp
  BEq : aexp → aexp → bexp
  BLe : aexp → aexp → bexp
  BNot : bexp → bexp
  BAnd : bexp → bexp → bexp

---- 評価 ---------------------------------------------------------------------
aeval : state → aexp → ℕ
aeval st (ANum n) = n
aeval st (AId X) = st X
aeval st (APlus exp₁ exp₂) = aeval st exp₁ + aeval st exp₂
aeval st (AMinus exp₁ exp₂) = aeval st exp₁ ∸ aeval st exp₂
aeval st (AMult exp₁ exp₂) = aeval st exp₁ * aeval st exp₂

beval : state → bexp → Bool
beval st BTrue = true
beval st BFalse = false
beval st (BEq exp₁ exp₂) = beq-nat (aeval st exp₁) (aeval st exp₂)
beval st (BLe exp₁ exp₂) = ble-nat (aeval st exp₁) (aeval st exp₂)
beval st (BNot exp) = not (beval st exp)
beval st (BAnd exp₁ exp₂) = beval st exp₁ ∧ beval st exp₂

aexp1 : aeval (update empty-state X 5) (APlus (ANum 3) (AMult (AId X) (ANum 2))) ≡ 13
aexp1 = refl

bexp1 : beval (update empty-state X 5) (BAnd BTrue (BNot (BLe (AId X) (ANum 4)))) ≡ true
bexp1 = refl

-- コマンド -------------------------------------------------------------------
infixl 5 _∷=_
infixr 4 _#_

-- Agdaは;が演算子に使えない
data com : Set where
  SKIP : com
  _∷=_ : ident → aexp → com
  _#_ : com → com → com
  IFB_THEN_ELSE_FI : bexp → com → com → com
  WHILE_DO_END : bexp → com → com

fact-in-coq : com
fact-in-coq =
  Z ∷= AId X #
  Y ∷= ANum 1 #
  WHILE BNot (BEq (AId Z) (ANum 0)) DO
    Y ∷= AMult (AId Y) (AId Z) #
    Z ∷= AMinus (AId Z) (ANum 1)
  END

---- 例 -----------------------------------------------------------------------
plus2 : com
plus2 =
  X ∷= APlus (AId X) (ANum 2)

XtimesYinZ : com
XtimesYinZ =
  Z ∷= AMult (AId X) (AId Y)

subtract-slowly-body : com
subtract-slowly-body =
  Z ∷= AMinus (AId Z) (ANum 1) #
  X ∷= AMinus (AId X) (ANum 1)

subtract-slowly : com
subtract-slowly =
  WHILE BNot (BEq (AId X) (ANum 0)) DO
    subtract-slowly-body
  END

subtract-3-from-5-slowly : com
subtract-3-from-5-slowly =
  X ∷= ANum 3 #
  Z ∷= ANum 5 #
  subtract-slowly

loop : com
loop =
  WHILE BTrue DO
    SKIP
  END

fact-body : com
fact-body =
  Y ∷= AMult (AId Y) (AId Z) #
  Z ∷= AMinus (AId Z) (ANum 1)

fact-loop : com
fact-loop =
  WHILE BNot (BEq (AId Z) (ANum 0)) DO
    fact-body
  END

fact-com : com
fact-com =
  Z ∷= AId X #
  Y ∷= ANum 1 #
  fact-loop

-- 評価 -----------------------------------------------------------------------

---- 評価関数 -----------------------------------------------------------------

ceval-step1 : state → com → state
ceval-step1 st SKIP = st
ceval-step1 st (x ∷= x₁) = update st x (aeval st x₁)
ceval-step1 st (com # com₁) = ceval-step1 (ceval-step1 st com) com₁
ceval-step1 st IFB x THEN com ELSE com₁ FI = if beval st x
                                             then ceval-step1 st com
                                             else ceval-step1 st com₁
ceval-step1 st WHILE x DO com END = st -- まぁ止まらんかね．

ceval-step2 : state → com → ℕ → state
ceval-step2 st com zero = empty-state
ceval-step2 st SKIP (suc i) = st
ceval-step2 st (x ∷= x₁) (suc i) = update st x (aeval st x₁)
ceval-step2 st (com # com₁) (suc i) = ceval-step2 (ceval-step2 st com i) com₁ i
ceval-step2 st IFB x THEN com ELSE com₁ FI (suc i) =
  if beval st x
    then ceval-step2 st com i
    else ceval-step2 st com₁ i
ceval-step2 st WHILE x DO com END (suc i) =
  if beval st x
    then ceval-step2 (ceval-step2 st com i) (WHILE x DO com END) i
    else st

ceval-step3 : state → com → ℕ → Maybe state
ceval-step3 st com zero = nothing
ceval-step3 st SKIP (suc i) = just st
ceval-step3 st (x ∷= x₁) (suc i) = just (update st x (aeval st x₁))
ceval-step3 st (com # com₁) (suc i) =
  case ceval-step3 st com i of λ
  { (just st') → ceval-step3 st' com₁ i
  ; nothing → nothing
  }
ceval-step3 st IFB x THEN com ELSE com₁ FI (suc i) =
  if beval st x
    then ceval-step3 st com i
    else ceval-step3 st com₁ i
ceval-step3 st WHILE x DO com END (suc i) =
  if beval st x
    then (case (ceval-step3 st com i) of λ
          { (just st') → ceval-step3 st' (WHILE x DO com END) i
          ; nothing → nothing
          })
    else just st

-- LETOPT は どうみてもMonadのbindだし，みんなCategory.Monad使うよネー
ceval-step : state → com → ℕ → Maybe state
ceval-step st com zero = nothing
ceval-step st SKIP (suc i) = just st
ceval-step st (x ∷= x₁) (suc i) = just (update st x (aeval st x₁))
ceval-step st (com # com₁) (suc i) =
  ceval-step st com i >>= λ st' → ceval-step st' com₁ i
  where
    open import Category.Monad
    open import Data.Maybe using (monad)
    open RawMonad monad
ceval-step st IFB x THEN com ELSE com₁ FI (suc i) =
  if beval st x
    then ceval-step st com i
    else ceval-step st com₁ i
ceval-step st WHILE x DO com END (suc i) =
  if beval st x
    then (ceval-step st com i >>= λ st' → ceval-step st' (WHILE x DO com END) i)
    else just st
  where
    open import Category.Monad
    open import Data.Maybe using (monad)
    open RawMonad monad

-- 何故直前でMonadのbind使っててこっちをFunctorにしないのか？
test-ceval : state → com → Maybe (ℕ × ℕ × ℕ)
test-ceval st c = f <$> ceval-step st c 500
  where
    f : state → ℕ × ℕ × ℕ
    f st = st X , st Y , st Z
    open import Category.Functor
    open import Data.Maybe using (functor)
    open RawFunctor functor

{-
練習問題: ★★, recommended (pup_to_n)

1 から X までの整数を変数 Y に足す (つまり 1 + 2 + ... + X) Imp プログラムを書きなさい。下に示したテストを満たすことを確認しなさい。
-}
pup-to-n : com
pup-to-n =
  Y ∷= ANum 0 #
  Z ∷= ANum 0 #
  WHILE BLe (AId Z) (AId X) DO
    Y ∷= APlus (AId Y) (AId Z) #
    Z ∷= APlus (AId Z) (ANum 1)
  END

-- 下に示したテスト？
test-pup-to-2 : test-ceval (update empty-state X 2) pup-to-n ≡ just (_ , 3 , _)
test-pup-to-2 = refl

{-
練習問題: ★★, optional (peven)

X が偶数だったら Z に 0 を、そうでなければ Z に 1 をセットする While プログラムを書きなさい。テストには ceval_test を使いなさい。
-}
peven : com
peven =
  Z ∷= AId X #
  WHILE BLe (ANum 2) (AId Z) DO
    Z ∷= AMinus (AId Z) (ANum 2)
  END

test-peven-3 : test-ceval (update empty-state X 3) peven ≡ just (_ , _ , 1)
test-peven-3 = refl
test-peven-4 : test-ceval (update empty-state X 4) peven ≡ just (_ , _ , 0)
test-peven-4 = refl

---- 関係としての評価 ---------------------------------------------------------
data _/_⇓_ : com → state → state → Set where
  E-Skip : ∀ st →
           SKIP / st ⇓ st
  E-Ass : ∀ st a1 n l → aeval st a1 ≡ n →
          (l ∷= a1) / st ⇓ update st l n
  E-Seq : ∀ c1 c2 st st' st'' → c1 / st ⇓ st' → c2 / st' ⇓ st'' →
          (c1 # c2) / st ⇓ st''
  E-IfTrue : ∀ st st' b1 c1 c2 → beval st b1 ≡ true → c1 / st ⇓ st' →
             IFB b1 THEN c1 ELSE c2 FI / st ⇓ st'
  E-IfFalse : ∀ st st' b1 c1 c2 → beval st b1 ≡ false → c2 / st ⇓ st' →
              IFB b1 THEN c1 ELSE c2 FI / st ⇓ st'
  E-WhileEnd : ∀ b1 st c1 → beval st b1 ≡ false →
               WHILE b1 DO c1 END / st ⇓ st
  E-WhileLoop : ∀ st st' st'' b1 c1 → beval st b1 ≡ true → c1 / st ⇓ st' →
                WHILE b1 DO c1 END / st' ⇓ st'' →
                WHILE b1 DO c1 END / st ⇓ st''

ceval-example1 : (X ∷= ANum 2 #
                  IFB BLe (AId X) (ANum 1)
                    THEN Y ∷= ANum 3
                    ELSE Z ∷= ANum 4
                  FI) / empty-state ⇓ update (update empty-state X 2) Z 4
-- ceval-example1 = ? から c-c c-a でウワァァァ
ceval-example1 = E-Seq (Ident zero ∷= ANum (suc (suc zero)))
                   IFB BLe (AId (Ident zero)) (ANum (suc zero)) THEN
                   Ident (suc zero) ∷= ANum (suc (suc (suc zero))) ELSE
                   Ident (suc (suc zero)) ∷= ANum (suc (suc (suc (suc zero)))) FI
                   (λ _ → zero)
                   (λ z → if beq-id (Ident zero) z then suc (suc zero) else zero)
                   (λ z →
                      if beq-id (Ident (suc (suc zero))) z then
                      suc (suc (suc (suc zero))) else
                      (if beq-id (Ident zero) z then suc (suc zero) else zero))
                   (E-Ass (λ _ → zero) (ANum (suc (suc zero))) (suc (suc zero))
                    (Ident zero) refl)
                   (E-IfFalse
                    (λ z → if beq-id (Ident zero) z then suc (suc zero) else zero)
                    (λ z →
                       if beq-id (Ident (suc (suc zero))) z then
                       suc (suc (suc (suc zero))) else
                       (if beq-id (Ident zero) z then suc (suc zero) else zero))
                    (BLe (AId (Ident zero)) (ANum (suc zero)))
                    (Ident (suc zero) ∷= ANum (suc (suc (suc zero))))
                    (Ident (suc (suc zero)) ∷= ANum (suc (suc (suc (suc zero))))) refl
                    (E-Ass
                     (λ z → if beq-id (Ident zero) z then suc (suc zero) else zero)
                     (ANum (suc (suc (suc (suc zero))))) (suc (suc (suc (suc zero))))
                     (Ident (suc (suc zero))) refl))
{-
練習問題: ★★ (ceval_example2)
-}
ceval-example2 : (X ∷= ANum 0 # Y ∷= ANum 1 # Z ∷= ANum 2) / empty-state ⇓
                 update (update (update empty-state X 0) Y 1) Z 2
ceval-example2 = E-Seq (Ident zero ∷= ANum zero)
                   (Ident (suc zero) ∷= ANum (suc zero) #
                    Ident (suc (suc zero)) ∷= ANum (suc (suc zero)))
                   (λ _ → zero) (λ z → if beq-id (Ident zero) z then zero else zero)
                   (λ z →
                      if beq-id (Ident (suc (suc zero))) z then suc (suc zero) else
                      (if beq-id (Ident (suc zero)) z then suc zero else
                       (if beq-id (Ident zero) z then zero else zero)))
                   (E-Ass (λ _ → zero) (ANum zero) zero (Ident zero) refl)
                   (E-Seq (Ident (suc zero) ∷= ANum (suc zero))
                    (Ident (suc (suc zero)) ∷= ANum (suc (suc zero)))
                    (λ z → if beq-id (Ident zero) z then zero else zero)
                    (λ z →
                       if beq-id (Ident (suc zero)) z then suc zero else
                       (if beq-id (Ident zero) z then zero else zero))
                    (λ z →
                       if beq-id (Ident (suc (suc zero))) z then suc (suc zero) else
                       (if beq-id (Ident (suc zero)) z then suc zero else
                        (if beq-id (Ident zero) z then zero else zero)))
                    (E-Ass (λ z → if beq-id (Ident zero) z then zero else zero)
                     (ANum (suc zero)) (suc zero) (Ident (suc zero)) refl)
                    (E-Ass
                     (λ z →
                        if beq-id (Ident (suc zero)) z then suc zero else
                        (if beq-id (Ident zero) z then zero else zero))
                     (ANum (suc (suc zero))) (suc (suc zero)) (Ident (suc (suc zero)))
                     refl))

---- 関係による評価とステップ指数を利用した評価の等価性 -----------------------
ceval-step→ceval : ∀ c st st' →
                   (∃ λ i → ceval-step st c i ≡ just st') →
                   c / st ⇓ st'
ceval-step→ceval c st st' (i , jst≡jst') = ceval-step→ceval' c st st' i jst≡jst'
  where
    just-inversion : ∀ {a} {X : Set a} {x y : X} → Maybe.just x ≡ just y → x ≡ y
    just-inversion refl = refl

    ceval-step→ceval' : ∀ c st st' i →
                        ceval-step st c i ≡ just st' →
                        c / st ⇓ st'
    ceval-step→ceval' c st st' zero ()
    ceval-step→ceval' SKIP st st' (suc i) jst≡jst'
      rewrite just-inversion jst≡jst'
            = E-Skip st'
    ceval-step→ceval' (x ∷= x₁) st st' (suc i) jst≡jst'
      rewrite sym (just-inversion jst≡jst')
            = E-Ass st x₁ (aeval st x₁) x refl
    ceval-step→ceval' (c # c₁) st st' (suc i) jst≡jst'
      = Maybe-remember (ceval-step st c i)
          (assert-just jst≡jst')
          (assert-nothing jst≡jst')
      where
        assert-just : ceval-step st (c # c₁) (suc i) ≡ just st' →
                      ∃ (λ x → ceval-step st c i ≡ just x) →
                      (c # c₁) / st ⇓ st'
        assert-just jst≡jst' (proj₁ , proj₂)
          rewrite proj₂
                = E-Seq c c₁ st proj₁ st'
                    (ceval-step→ceval' c st proj₁ i proj₂)
                    (ceval-step→ceval' c₁ proj₁ st' i jst≡jst')
        assert-nothing : ceval-step st (c # c₁) (suc i) ≡ just st' →
                         ceval-step st c i ≡ nothing →
                         (c # c₁) / st ⇓ st'
        assert-nothing jst≡jst' y
          rewrite y
                = inversion jst≡jst'
          where
            inversion : nothing ≡ just st' → _
            inversion ()
    ceval-step→ceval' IFB x THEN c ELSE c₁ FI st st' (suc i) jst≡jst'
      = Bool-remember (beval st x)
          (assert-true jst≡jst')
          (assert-false jst≡jst')
      where
        assert-true : ceval-step st IFB x THEN c ELSE c₁ FI (suc i) ≡ just st' →
                      beval st x ≡ true →
                      IFB x THEN c ELSE c₁ FI / st ⇓ st'
        assert-true jst≡jst' t
          rewrite t
                = E-IfTrue st st' x c c₁ t (ceval-step→ceval' c st st' i jst≡jst')
        assert-false : ceval-step st IFB x THEN c ELSE c₁ FI (suc i) ≡ just st' →
                       beval st x ≡ false →
                       IFB x THEN c ELSE c₁ FI / st ⇓ st'
        assert-false jst≡jst' f
          rewrite f
                = E-IfFalse st st' x c c₁ f (ceval-step→ceval' c₁ st st' i jst≡jst')
    ceval-step→ceval' WHILE x DO c END st st' (suc i) jst≡jst'
      = Bool-remember (beval st x)
          (assert-true jst≡jst')
          (assert-false jst≡jst')
      where
        assert-true : ceval-step st WHILE x DO c END (suc i) ≡ just st' →
                      beval st x ≡ true →
                      WHILE x DO c END / st ⇓ st'
        assert-true jst≡jst' t
          = Maybe-remember (ceval-step st c i)
              (assert-just jst≡jst' t)
              (assert-nothing jst≡jst' t)
          where
          assert-just : ceval-step st WHILE x DO c END (suc i) ≡ just st' →
                        beval st x ≡ true →
                        ∃ (λ x₁ → ceval-step st c i ≡ just x₁) →
                        WHILE x DO c END / st ⇓ st'
          assert-just jst≡jst' f (proj₁ , proj₂)
            rewrite f
                  | proj₂
                  = E-WhileLoop st proj₁ st' x c f
                      (ceval-step→ceval' c st proj₁ i proj₂)
                      (ceval-step→ceval' WHILE x DO c END proj₁ st' i jst≡jst')
          assert-nothing : ceval-step st WHILE x DO c END (suc i) ≡ just st' →
                           beval st x ≡ true →
                           ceval-step st c i ≡ nothing →
                           WHILE x DO c END / st ⇓ st'
          assert-nothing jst≡jst' f n
            rewrite f
                  | n
                  = inversion jst≡jst'
            where
              inversion : nothing ≡ just st' → _
              inversion ()
        assert-false : ceval-step st WHILE x DO c END (suc i) ≡ just st' →
                       beval st x ≡ false →
                       WHILE x DO c END / st ⇓ st'
        assert-false jst≡jst' f
          rewrite f
                | sym (just-inversion jst≡jst')
                = E-WhileEnd x st c f


{-
練習問題: ★★★★ (ceval_step__ceval_inf)

いつものテンプレートにのっとって、 ceval_step__ceval の形式的でない証明を書きましょう。 (帰納的に定義された値の場合分けに対するテンプレートは、 帰納法の仮定がないこと以外は帰納法と同じ見た目になるはずです。) 単に形式的な証明のステップを書き写すだけでなく、 人間の読者に主要な考えが伝わるようにしなさい。
-}
-- 略
ceval-step-more : ∀ i1 i2 st st' c →
                  i1 ≤ i2 →
                  ceval-step st c i1 ≡ just st' →
                  ceval-step st c i2 ≡ just st'
ceval-step-more zero i2 st st' c i1≤i2 ()
ceval-step-more (suc i1) zero st st' c () x
ceval-step-more (suc i1) (suc i2) st st' SKIP i1≤i2 x = x
ceval-step-more (suc i1) (suc i2) st st' (x ∷= x₁) i1≤i2 x₂ = x₂
ceval-step-more (suc i1) (suc i2) st st' (c # c₁) (s≤s i1≤i2) x
  = Maybe-remember (ceval-step st c i1) (ceval-step-more-just x) (ceval-step-more-nothing x)
  where
    ceval-step-more-just : ceval-step st (c # c₁) (suc i1) ≡ just st' →
                           ∃ (λ x₁ → ceval-step st c i1 ≡ just x₁) →
                           ceval-step st (c # c₁) (suc i2) ≡ just st'
    ceval-step-more-just x (proj₁ , proj₂)
      rewrite proj₂
            | ceval-step-more i1 i2 st proj₁ c i1≤i2 proj₂
            | ceval-step-more i1 i2 proj₁ st' c₁ i1≤i2 x
            = refl
    ceval-step-more-nothing : ceval-step st (c # c₁) (suc i1) ≡ just st' →
                              ceval-step st c i1 ≡ nothing →
                              ceval-step st (c # c₁) (suc i2) ≡ just st'
    ceval-step-more-nothing x y rewrite y = inversion x
      where
        inversion : nothing ≡ just st' → _
        inversion ()
ceval-step-more (suc i1) (suc i2) st st' IFB x THEN c ELSE c₁ FI (s≤s i1≤i2) x₁
  = Bool-remember (beval st x) (ceval-step-more-true x₁) (ceval-step-more-false x₁)
  where
    ceval-step-more-true : ceval-step st IFB x THEN c ELSE c₁ FI (suc i1) ≡ just st' →
                           beval st x ≡ true →
                           ceval-step st IFB x THEN c ELSE c₁ FI (suc i2) ≡ just st'
    ceval-step-more-true x₁ x⇓t rewrite x⇓t = ceval-step-more i1 i2 st st' c i1≤i2 x₁
    ceval-step-more-false : ceval-step st IFB x THEN c ELSE c₁ FI (suc i1) ≡ just st' →
                            beval st x ≡ false →
                            ceval-step st IFB x THEN c ELSE c₁ FI (suc i2) ≡ just st'
    ceval-step-more-false x₁ x⇓f rewrite x⇓f = ceval-step-more i1 i2 st st' c₁ i1≤i2 x₁
ceval-step-more (suc i1) (suc i2) st st' WHILE x DO c END (s≤s i1≤i2) x₁
  = Maybe-remember (ceval-step st c i1) (ceval-step-more-just x₁) (ceval-step-more-nothing x₁)
  where
    ceval-step-more-just : ceval-step st WHILE x DO c END (suc i1) ≡ just st' →
                           ∃ (λ st'' → ceval-step st c i1 ≡ just st'') →
                           ceval-step st WHILE x DO c END (suc i2) ≡ just st'
    ceval-step-more-just x' (st'' , proj₂) with beval st x
    ceval-step-more-just x' (st'' , proj₂) | true
      rewrite proj₂
            | ceval-step-more i1 i2 st st'' c i1≤i2 proj₂
            | ceval-step-more i1 i2 st'' st' WHILE x DO c END i1≤i2 x'
            = refl
    ceval-step-more-just x' (st'' , proj₂) | false = x'
    ceval-step-more-nothing : ceval-step st WHILE x DO c END (suc i1) ≡ just st' →
                              ceval-step st c i1 ≡ nothing →
                              ceval-step st WHILE x DO c END (suc i2) ≡ just st'
    ceval-step-more-nothing x' y with beval st x
    ceval-step-more-nothing x' y | true rewrite y = inversion x'
      where
        inversion : nothing ≡ just st' → _
        inversion ()
    ceval-step-more-nothing x' y | false = x'

{-
練習問題: ★★★, recommended (ceval__ceval_step)

以下の証明を完成させなさい。何度か ceval_step_more が必要となり、 さらに <= と plus に関するいくつかの基本的な事実が必要となるでしょう。
-}

open import Data.Nat.Properties -- <= と plus に関するいくつかの基本的な事実

ceval→ceval-step : ∀ c st st' →
                   c / st ⇓ st' →
                   ∃ (λ i → ceval-step st c i ≡ just st')
ceval→ceval-step .SKIP .st' st' (E-Skip .st') = 1 , refl
ceval→ceval-step .(l ∷= a1) st .(λ x' → if beq-id l x' then n else st x') (E-Ass .st a1 n l x)
  rewrite sym x
        = 1 , refl
ceval→ceval-step .(c1 # c2) st st' (E-Seq c1 c2 .st st'' .st' c/st⇓st' c/st⇓st'') with ceval→ceval-step c1 st st'' c/st⇓st' | ceval→ceval-step c2 st'' st' c/st⇓st''
ceval→ceval-step .(c1 # c2) st st' (E-Seq c1 c2 .st st'' .st' c/st⇓st' c/st⇓st'') | proj₁ , proj₂ | proj₃ , proj₄ = suc (proj₁ + proj₃) , assert
  where
    assert : ceval-step st (c1 # c2) (suc (proj₁ + proj₃)) ≡ just st'
    assert
      rewrite ceval-step-more proj₁ (proj₁ + proj₃) st st'' c1 (m≤m+n proj₁ proj₃) proj₂
            | ceval-step-more proj₃ (proj₁ + proj₃) st'' st' c2 (n≤m+n proj₁ proj₃) proj₄
            = refl
ceval→ceval-step .(IFB b1 THEN c1 ELSE c2 FI) st st' (E-IfTrue .st .st' b1 c1 c2 x c/st⇓st') with ceval→ceval-step c1 st st' c/st⇓st'
ceval→ceval-step .(IFB b1 THEN c1 ELSE c2 FI) st st' (E-IfTrue .st .st' b1 c1 c2 x c/st⇓st') | proj₁ , proj₂ = suc proj₁ , assert
  where
    assert : ceval-step st IFB b1 THEN c1 ELSE c2 FI (suc proj₁) ≡ just st'
    assert
      rewrite x
            = proj₂
ceval→ceval-step .(IFB b1 THEN c1 ELSE c2 FI) st st' (E-IfFalse .st .st' b1 c1 c2 x c/st⇓st') with ceval→ceval-step c2 st st' c/st⇓st'
ceval→ceval-step .(IFB b1 THEN c1 ELSE c2 FI) st st' (E-IfFalse .st .st' b1 c1 c2 x c/st⇓st') | proj₁ , proj₂ = suc proj₁ , assert
  where
    assert : ceval-step st IFB b1 THEN c1 ELSE c2 FI (suc proj₁) ≡ just st'
    assert
      rewrite x
            = proj₂
ceval→ceval-step .(WHILE b1 DO c1 END) .st' st' (E-WhileEnd b1 .st' c1 x) = 1 , assert
  where
    assert : ceval-step st' WHILE b1 DO c1 END 1 ≡ just st'
    assert
      rewrite x
            = refl
ceval→ceval-step .(WHILE b1 DO c1 END) st st' (E-WhileLoop .st st'' .st' b1 c1 x c/st⇓st' c/st⇓st'') with ceval→ceval-step c1 st st'' c/st⇓st' | ceval→ceval-step WHILE b1 DO c1 END st'' st' c/st⇓st''
ceval→ceval-step .(WHILE b1 DO c1 END) st st' (E-WhileLoop .st st'' .st' b1 c1 x c/st⇓st' c/st⇓st'') | proj₁ , proj₂ | proj₃ , proj₄ = (suc (proj₁ + proj₃)) , assert
  where
    assert : ceval-step st WHILE b1 DO c1 END (suc (proj₁ + proj₃)) ≡ just st'
    assert
      rewrite x
            | ceval-step-more proj₁ (proj₁ + proj₃) st st'' c1 (m≤m+n proj₁ proj₃) proj₂
            | ceval-step-more proj₃ (proj₁ + proj₃) st'' st' WHILE b1 DO c1 END (n≤m+n proj₁ proj₃) proj₄
            = refl

open import Function.Equivalence hiding (sym)

ceval-and-ceval-step-coincide : ∀ c st st' →
                                c / st ⇓ st' ⇔ ∃ (λ i → ceval-step st c i ≡ just st')
ceval-and-ceval-step-coincide = λ c st st' → equivalence (ceval→ceval-step c st st') (ceval-step→ceval c st st')

---- 実行の決定性 -------------------------------------------------------------
ceval-deterministic : ∀ c st st1 st2 →
                      c / st ⇓ st1 →
                      c / st ⇓ st2 →
                      st1 ≡ st2
ceval-deterministic .SKIP .st2 .st2 st2 (E-Skip .st2) (E-Skip .st2) = refl
ceval-deterministic .(l ∷= a1) st .(λ x' → if beq-id l x' then n else st x') .(λ x' → if beq-id l x' then n₁ else st x') (E-Ass .st a1 n l x) (E-Ass .st .a1 n₁ .l x₁)
  rewrite sym x
        | sym x₁
        = refl
ceval-deterministic .(c1 # c2) st st1 st2 (E-Seq c1 c2 .st st' .st1 x₁ x₂) (E-Seq .c1 .c2 .st st'' .st2 x₃ x₄)
  rewrite ceval-deterministic c1 st st' st'' x₁ x₃
        | ceval-deterministic c2 st'' st1 st2 x₂ x₄
        = refl
ceval-deterministic .(IFB b1 THEN c1 ELSE c2 FI) st st1 st2 (E-IfTrue .st .st1 b1 c1 c2 x x₁) (E-IfTrue .st .st2 .b1 .c1 .c2 x₂ x₃) = ceval-deterministic c1 st st1 st2 x₁ x₃
ceval-deterministic .(IFB b1 THEN c1 ELSE c2 FI) st st1 st2 (E-IfTrue .st .st1 b1 c1 c2 x x₁) (E-IfFalse .st .st2 .b1 .c1 .c2 x₂ x₃)
  rewrite x
        = inversion x₂
  where
    inversion : true ≡ false → _
    inversion ()
ceval-deterministic .(IFB b1 THEN c1 ELSE c2 FI) st st1 st2 (E-IfFalse .st .st1 b1 c1 c2 x x₁) (E-IfTrue .st .st2 .b1 .c1 .c2 x₂ x₃)
  rewrite x
        = inversion x₂
  where
    inversion : false ≡ true → _
    inversion ()
ceval-deterministic .(IFB b1 THEN c1 ELSE c2 FI) st st1 st2 (E-IfFalse .st .st1 b1 c1 c2 x x₁) (E-IfFalse .st .st2 .b1 .c1 .c2 x₂ x₃) = ceval-deterministic c2 st st1 st2 x₁ x₃
ceval-deterministic .(WHILE b1 DO c1 END) .st2 .st2 st2 (E-WhileEnd b1 .st2 c1 x) (E-WhileEnd .b1 .st2 .c1 x₁) = refl
ceval-deterministic .(WHILE b1 DO c1 END) .st1 st1 st2 (E-WhileEnd b1 .st1 c1 x) (E-WhileLoop .st1 st' .st2 .b1 .c1 x₁ x₂ x₃)
  rewrite x
        = inversion x₁
  where
    inversion : false ≡ true → _
    inversion ()
ceval-deterministic .(WHILE b1 DO c1 END) .st2 st1 st2 (E-WhileLoop .st2 st' .st1 b1 c1 x x₁ x₂) (E-WhileEnd .b1 .st2 .c1 x₃)
  rewrite x
        = inversion x₃
  where
    inversion : true ≡ false → _
    inversion ()
ceval-deterministic .(WHILE b1 DO c1 END) st st1 st2 (E-WhileLoop .st st' .st1 b1 c1 x x₁ x₂) (E-WhileLoop .st st'' .st2 .b1 .c1 x₃ x₄ x₅)
  rewrite ceval-deterministic c1 st st' st'' x₁ x₄
        | ceval-deterministic WHILE b1 DO c1 END st'' st1 st2 x₂ x₅
        = refl

ceval-deterministic' : ∀ c st st1 st2 →
                       c / st ⇓ st1 →
                       c / st ⇓ st2 →
                       st1 ≡ st2
ceval-deterministic' c st st1 st2 He1 He2 with ceval→ceval-step c st st1 He1 | ceval→ceval-step c st st2 He2
ceval-deterministic' c st st1 st2 He1 He2 | i1 , E1 | i2 , E2
  = just-inversion (sym (ceval-step-more i1 (i1 + i2) st st1 c (m≤m+n i1 i2) E1) ⟨ trans ⟩
                    ceval-step-more i2 (i1 + i2) st st2 c (n≤m+n i1 i2) E2)
  where
    just-inversion : ∀ {a} {X : Set a} {x y : X} → Maybe.just x ≡ just y → x ≡ y
    just-inversion refl = refl

-- プログラムの検証 -----------------------------------------------------------

---- 基本的な例 ---------------------------------------------------------------
plus2-spec : ∀ st n st' →
             st X ≡ n →
             plus2 / st ⇓ st' →
             st' X ≡ n + 2
plus2-spec st n .(λ x' → if beq-id X x' then n₁ else st x') HX (E-Ass .st .(APlus (AId X) (ANum 2)) n₁ .X x)
  rewrite HX
        | x
        = refl

{-
練習問題: ★★★, recommended (XtimesYinZ_spec)

XtimesYinZ の Imp プログラムの仕様を書いて証明しなさい。
-}
XtimesYinZ-spec : ∀ st st' x y →
                  st X ≡ x →
                  st Y ≡ y →
                  XtimesYinZ / st ⇓ st' →
                  st' Z ≡ x * y
XtimesYinZ-spec st .(λ x' → if beq-id Z x' then n else st x') x y HX HY (E-Ass .st .(AMult (AId X) (AId Y)) n .Z x₁)
  rewrite HX
        | HY
        | x₁
        = refl

{-
練習問題: ★★★, recommended (loop_never_stops)
-}
loop-never-stops : ∀ st st' →
                   ¬ (loop / st ⇓ st')
loop-never-stops .st' st' (E-WhileEnd .BTrue .st' .SKIP x) = inversion x
  where
    inversion : true ≡ false → _
    inversion ()
loop-never-stops st st' (E-WhileLoop .st st'' .st' .BTrue .SKIP x Heval Heval₁) = loop-never-stops st'' st' Heval₁


no-whiles : com → Bool
no-whiles SKIP = true
no-whiles (x ∷= x₁) = true
no-whiles (c # c₁) = no-whiles c ∧ no-whiles c₁
no-whiles IFB x THEN c ELSE c₁ FI = no-whiles c ∧ no-whiles c₁
no-whiles WHILE x DO c END = false

{-
練習問題: ★★, optional (no_whilesR)

性質 no_whiles はプログラムが while ループを含まない場合 true を返します。 Inductive を使って c が while ループのないプログラムのとき証明可能な性質 no_whilesR を書きなさい。 さらに、それが no_whiles と等価であることを示しなさい。
-}
data no-whilesR : com → Set where
  SKIP : no-whilesR SKIP
  _∷=_ : ∀ {i a} → no-whilesR (i ∷= a)
  _#_ : ∀ {com₁ com₂} → no-whilesR com₁ → no-whilesR com₂ → no-whilesR (com₁ # com₂)
  IFB_THEN_ELSE_FI : ∀ b {com₁ com₂}→ no-whilesR com₁ → no-whilesR com₂ → no-whilesR (IFB b THEN com₁ ELSE com₂ FI)

no-whiles-eqv : ∀ c → no-whiles c ≡ true ⇔ no-whilesR c
no-whiles-eqv = λ c → equivalence (assert→ c) (assert← c)
  where
    assert→ : ∀ c → no-whiles c ≡ true → no-whilesR c
    assert→ SKIP eq = SKIP
    assert→ (x ∷= x₁) eq = _∷=_
    assert→ (c # c₁) eq
      = assert→ c (andb-true-elim1 (no-whiles c) (no-whiles c₁) eq) #
        assert→ c₁ (andb-true-elim2 (no-whiles c) (no-whiles c₁) eq)
    assert→ IFB x THEN c ELSE c₁ FI eq
      = IFB x
          THEN assert→ c (andb-true-elim1 (no-whiles c) (no-whiles c₁) eq)
          ELSE assert→ c₁ (andb-true-elim2 (no-whiles c) (no-whiles c₁) eq)
        FI
    assert→ WHILE x DO c END ()
    assert← : ∀ c → no-whilesR c → no-whiles c ≡ true
    assert← .SKIP SKIP = refl
    assert← .(i ∷= a) (_∷=_ {i} {a}) = refl
    assert← .(com₁ # com₂) (_#_ {com₁} {com₂} HR₁ HR₂)
      rewrite assert← com₁ HR₁
            | assert← com₂ HR₂
            = refl
    assert← .(IFB b THEN com₁ ELSE com₂ FI) (IFB_THEN_ELSE_FI b {com₁} {com₂} HR₁ HR₂)
      rewrite assert← com₁ HR₁
            | assert← com₂ HR₂
            = refl

{-
練習問題: ★★★★, optional (no_whiles_terminating)

while ループを含まない Imp プログラムは必ず停止します。 これを定理として記述し、証明しなさい。
(no_whiles と no_whilesR のどちらでも好きなほうを使いなさい。)
-}
no-whiles-terminating : ∀ st com → no-whilesR com → ∃ (λ st' → com / st ⇓ st')
no-whiles-terminating st .SKIP SKIP = st , E-Skip st
no-whiles-terminating st .(i ∷= a) (_∷=_ {i} {a}) = (λ x → if beq-id i x then aeval st a else st x) ,
                                                      E-Ass st a (aeval st a) i refl
no-whiles-terminating st .(com₁ # com₂) (_#_ {com₁} {com₂} Hcom₁ Hcom₂) with no-whiles-terminating st com₁ Hcom₁
no-whiles-terminating st .(com₁ # com₂) (_#_ {com₁} {com₂} Hcom₁ Hcom₂) | (st' , H₁) with no-whiles-terminating st' com₂ Hcom₂
no-whiles-terminating st .(com₁ # com₂) (_#_ {com₁} {com₂} Hcom₁ Hcom₂) | st' , H₁ | st'' , H₂ = st'' , E-Seq com₁ com₂ st st' st'' H₁ H₂
no-whiles-terminating st .(IFB b THEN com₁ ELSE com₂ FI) (IFB_THEN_ELSE_FI b {com₁} {com₂} Hcom₁ Hcom₂)
  = Bool-remember (beval st b) assert-true assert-false
  where
    assert-true : beval st b ≡ true →
                  ∃ (λ st' → IFB b THEN com₁ ELSE com₂ FI / st ⇓ st')
    assert-true with no-whiles-terminating st com₁ Hcom₁
    assert-true | proj₁ , proj₂ = λ z → proj₁ , E-IfTrue st proj₁ b com₁ com₂ z proj₂
    assert-false : beval st b ≡ false →
                   ∃ (λ st' → IFB b THEN com₁ ELSE com₂ FI / st ⇓ st')
    assert-false with no-whiles-terminating st com₂ Hcom₂
    assert-false | proj₁ , proj₂ = λ z → proj₁ , E-IfFalse st proj₁ b com₁ com₂ z proj₂

---- プログラム正当性 (Optional) ----------------------------------------------
real-fact : ℕ → ℕ
real-fact zero = 1
real-fact (suc n) = suc n * real-fact n

fact-invariant : ℕ → state → Set
fact-invariant x st = st Y * real-fact (st Z) ≡ real-fact x

private
  *-assoc' = *-assoc
    where
      open import Algebra
      open Algebra.CommutativeSemiring commutativeSemiring

fact-body-preserves-invariant : ∀ st st' x →
                                fact-invariant x st →
                                st Z ≢ 0 →
                                fact-body / st ⇓ st' →
                                fact-invariant x st'
fact-body-preserves-invariant st .(λ x' → if beq-id (Z) x' then n₁ else (if beq-id (Y) x' then n else st x')) x Hinv Z≢0 (E-Seq .(Y ∷= AMult (AId (Y)) (AId (Z))) .(Z ∷= AMinus (AId (Z)) (ANum 1)) .st .(λ x' → if beq-id (Y) x' then n else st x') .(λ x' → if beq-id (Z) x' then n₁ else (if beq-id (Y) x' then n else st x')) (E-Ass .st .(AMult (AId (Y)) (AId (Z))) n .(Y) x₁) (E-Ass .(λ x' → if beq-id (Y) x' then n else st x') .(AMinus (AId (Z)) (ANum 1)) n₁ .(Z) x₂)) with st Z
fact-body-preserves-invariant st ._ x Hinv Z≢0 (E-Seq .(Ident _ ∷= AMult (AId (Ident _)) (AId (Ident _))) .(Ident _ ∷= AMinus (AId (Ident _)) (ANum _)) .st ._ ._ (E-Ass .st .(AMult (AId (Ident _)) (AId (Ident _))) n .(Ident _) x₁) (E-Ass ._ .(AMinus (AId (Ident _)) (ANum _)) n₁ .(Ident _) x₂)) | zero = ⊥-elim (Z≢0 refl)
fact-body-preserves-invariant st ._ x Hinv Z≢0 (E-Seq .(Ident _ ∷= AMult (AId (Ident _)) (AId (Ident _))) .(Ident _ ∷= AMinus (AId (Ident _)) (ANum _)) .st ._ ._ (E-Ass .st .(AMult (AId (Ident _)) (AId (Ident _))) n .(Ident _) x₁) (E-Ass ._ .(AMinus (AId (Ident _)) (ANum _)) n₁ .(Ident _) x₂)) | suc m
  rewrite sym Hinv
        | sym x₁
        | sym x₂
        | *-assoc' (st Y) (suc m) (real-fact m)
        = refl

fact-loop-preserves-invariant : ∀ st st' x →
                                fact-invariant x st →
                                fact-loop / st ⇓ st' →
                                fact-invariant x st'
fact-loop-preserves-invariant .st' st' x Hinv (E-WhileEnd .(BNot (BEq (AId (Ident 2)) (ANum 0))) .st' .(Ident 1 ∷= AMult (AId (Ident 1)) (AId (Ident 2)) # Ident 2 ∷= AMinus (AId (Ident 2)) (ANum 1)) x₁) = Hinv
fact-loop-preserves-invariant st st' x Hinv (E-WhileLoop .st st'' .st' .(BNot (BEq (AId (Ident 2)) (ANum 0))) .(Ident 1 ∷= AMult (AId (Ident 1)) (AId (Ident 2)) # Ident 2 ∷= AMinus (AId (Ident 2)) (ANum 1)) x₁ He He₁) = fact-loop-preserves-invariant st'' st' x He' He₁
  where
    open import Data.Bool.Properties
    He' = fact-body-preserves-invariant st st'' x Hinv (beq-nat-false (st Z) 0 (sym (not-involutive (beq-nat (st Z) 0)) ⟨ trans ⟩ cong not x₁)) He

guard-false-after-loop : ∀ b c st st' →
                         (WHILE b DO c END) / st ⇓ st' →
                         beval st' b ≡ false
guard-false-after-loop b c .st' st' (E-WhileEnd .b .st' .c x) = x
guard-false-after-loop b c st st' (E-WhileLoop .st st'' .st' .b .c x H H₁) = guard-false-after-loop b c st'' st' H₁


fact-com-correct : ∀ st st' x →
                   st X ≡ x →
                   fact-com / st ⇓ st' →
                   st' Y ≡ real-fact x
fact-com-correct st st' x HX (E-Seq .(Ident 2 ∷= AId (Ident 0)) .(Ident 1 ∷= ANum 1 # WHILE BNot (BEq (AId (Ident 2)) (ANum 0)) DO Ident 1 ∷= AMult (AId (Ident 1)) (AId (Ident 2)) # Ident 2 ∷= AMinus (AId (Ident 2)) (ANum 1) END) .st .(λ x' → if beq-id (Ident 2) x' then n else st x') .st' (E-Ass .st .(AId (Ident 0)) n .(Ident 2) x₁) (E-Seq .(Ident 1 ∷= ANum 1) .(WHILE BNot (BEq (AId (Ident 2)) (ANum 0)) DO Ident 1 ∷= AMult (AId (Ident 1)) (AId (Ident 2)) # Ident 2 ∷= AMinus (AId (Ident 2)) (ANum 1) END) .(λ x' → if beq-id (Ident 2) x' then n else st x') .(λ x' → if beq-id (Ident 1) x' then n₁ else (if beq-id (Ident 2) x' then n else st x')) .st' (E-Ass .(λ x' → if beq-id (Ident 2) x' then n else st x') .(ANum 1) n₁ .(Ident 1) x₂) Hce₂))
  rewrite sym x₂
        | HX
        | x₁
        = assert assert1
  where
    n+0≡n : ∀ n → n + 0 ≡ n
    n+0≡n zero    = refl
    n+0≡n (suc n) = cong suc $ n+0≡n n

    n*1≡n : ∀ n → n * 1 ≡ n
    n*1≡n zero    = refl
    n*1≡n (suc n) = cong suc $ n*1≡n n

    assert1 : fact-invariant n st'
    assert1 = fact-loop-preserves-invariant
                (λ x' →
                   if beq-id Y x' then 1 else (if beq-id Z x' then n else st x'))
                st' n (n+0≡n (real-fact n)) Hce₂

    assert2 : ∀ st' → beval st' (BNot (BEq (AId Z) (ANum 0))) ≡ false → st' Z ≡ 0
    assert2 st' H with st' Z
    assert2 st' H | zero = refl
    assert2 st' () | suc _

    assert : fact-invariant n st' → st' Y ≡ real-fact n
    assert
      rewrite assert2 st' (guard-false-after-loop _ _ _ _ Hce₂)
            | n*1≡n (st' Y)
            = λ z → z
{-
練習問題: ★★★★, optional (subtract_slowly_spec)
上の fact_com の仕様、および以下の不変式をガイドとして、 subtract_slowly の仕様を証明しなさい。
-}
ss-invariant : (x z : ℕ) (st : state) → Set
ss-invariant x z st = st Z ∸ st X ≡ z ∸ x

ss-body-preserves-invariant : ∀ st st' x z →
                              ss-invariant x z st →
                              st X ≢ 0 →
                              subtract-slowly-body / st ⇓ st' →
                              ss-invariant x z st'
ss-body-preserves-invariant st .(λ x' → if beq-id X x' then n₁ else (if beq-id Z x' then n else st x')) x z Hinv HstX0 (E-Seq .(Z ∷= AMinus (AId Z) (ANum 1)) .(X ∷= AMinus (AId X) (ANum 1)) .st .(λ x' → if beq-id Z x' then n else st x') .(λ x' → if beq-id X x' then n₁ else (if beq-id Z x' then n else st x')) (E-Ass .st .(AMinus (AId Z) (ANum 1)) n .Z x₁) (E-Ass .(λ x' → if beq-id Z x' then n else st x') .(AMinus (AId X) (ANum 1)) n₁ .X x₂)) with st X
ss-body-preserves-invariant st ._ x z Hinv HstX0 (E-Seq .(Ident _ ∷= AMinus (AId (Ident _)) (ANum _)) .(Ident _ ∷= AMinus (AId (Ident _)) (ANum _)) .st ._ ._ (E-Ass .st .(AMinus (AId (Ident _)) (ANum _)) n .(Ident _) x₁) (E-Ass ._ .(AMinus (AId (Ident _)) (ANum _)) n₁ .(Ident _) x₂)) | zero = ⊥-elim (HstX0 refl)
ss-body-preserves-invariant st ._ x z Hinv HstX0 (E-Seq .(Ident _ ∷= AMinus (AId (Ident _)) (ANum _)) .(Ident _ ∷= AMinus (AId (Ident _)) (ANum _)) .st ._ ._ (E-Ass .st .(AMinus (AId (Ident _)) (ANum _)) n .(Ident _) x₁) (E-Ass ._ .(AMinus (AId (Ident _)) (ANum _)) n₁ .(Ident _) x₂)) | suc m
  rewrite sym (∸-+-assoc (st Z) 1 m)
        | x₁
        | x₂
        = Hinv

ss-loop-preserves-invariant : ∀ st st' x z →
                              ss-invariant x z st →
                              subtract-slowly / st ⇓ st' →
                              ss-invariant x z st'
ss-loop-preserves-invariant .st' st' x z Hinv (E-WhileEnd .(BNot (BEq (AId (Ident 0)) (ANum 0))) .st' .(Ident 2 ∷= AMinus (AId (Ident 2)) (ANum 1) # Ident 0 ∷= AMinus (AId (Ident 0)) (ANum 1)) x₁) = Hinv
ss-loop-preserves-invariant st st' x z Hinv (E-WhileLoop .st st'' .st' .(BNot (BEq (AId (Ident 0)) (ANum 0))) .(Ident 2 ∷= AMinus (AId (Ident 2)) (ANum 1) # Ident 0 ∷= AMinus (AId (Ident 0)) (ANum 1)) x₁ He He₁) = ss-loop-preserves-invariant st'' st' x z He' He₁
  where
    open import Data.Bool.Properties
    He' = ss-body-preserves-invariant st st'' x z Hinv (beq-nat-false (st X) 0
                                                          (sym (not-involutive (beq-nat (st X) 0)) ⟨ trans ⟩ cong not x₁)) He

subtract-slowly-spec : ∀ st st' x z →
                       st X ≡ x →
                       st Z ≡ z →
                       subtract-slowly / st ⇓ st' →
                       st' Z ≡ z ∸ x
subtract-slowly-spec st st' x z HX HZ He = assert assert1
  where

    assert1 : ss-invariant x z st'
    assert1 = ss-loop-preserves-invariant st st' x z (cong₂ _∸_ HZ HX) He

    assert2 : ∀ st' → beval st' (BNot (BEq (AId X) (ANum 0))) ≡ false → st' X ≡ 0
    assert2 st' H with st' X
    assert2 st' H | zero = refl
    assert2 st' () | suc _

    assert : ss-invariant x z st' → st' Z ≡ z ∸ x
    assert
      rewrite assert2 st' (guard-false-after-loop _ _ _ _ He)
            = λ z → z

-- 追加の練習問題 -------------------------------------------------------------
{-
練習問題: ★★★★, optional (add_for_loop)
-}
-- 略 (メンドクサイ)

{-
練習問題: ★★★, optional (short_circuit)
-}
-- 略

{-
練習問題: ★★★★, recommended (stack_compiler)
-}
data sinstr : Set where
  SPush : ℕ → sinstr
  SLoad : ident → sinstr
  SPlus : sinstr
  SMinus : sinstr
  SMult : sinstr

s-execute : state → List ℕ → List sinstr → List ℕ
s-execute st stack [] = stack
s-execute st stack (SPush x ∷ prog) = s-execute st (x ∷ stack) prog
s-execute st stack (SLoad x ∷ prog) = s-execute st (st x ∷ stack) prog
s-execute st [] (SPlus ∷ prog) = s-execute st [] prog
s-execute st (x ∷ []) (SPlus ∷ prog) = s-execute st [ x ] prog
s-execute st (x ∷ x₁ ∷ stack) (SPlus ∷ prog) = s-execute st (x₁ + x ∷ stack) prog
s-execute st [] (SMinus ∷ prog) = s-execute st [] prog
s-execute st (x ∷ []) (SMinus ∷ prog) = s-execute st [ x ] prog
s-execute st (x ∷ x₁ ∷ stack) (SMinus ∷ prog) = s-execute st (x₁ ∸ x ∷ stack) prog
s-execute st [] (SMult ∷ prog) = s-execute st [] prog
s-execute st (x ∷ []) (SMult ∷ prog) = s-execute st [ x ] prog
s-execute st (x ∷ x₁ ∷ stack) (SMult ∷ prog) = s-execute st (x₁ * x ∷ stack) prog

s-execute1 : s-execute empty-state [] (SPush 5 ∷ SPush 3 ∷ SPush 1 ∷ SMinus ∷ []) ≡ 2 ∷ 5 ∷ []
s-execute1 = refl

s-execute2 : s-execute (update empty-state X 3) (3 ∷ 4 ∷ []) (SPush 4 ∷ SLoad X ∷ SMult ∷ SPlus ∷ []) ≡ 15 ∷ 4 ∷ []
s-execute2 = refl

s-compile : aexp → List sinstr
s-compile (ANum x) = [ SPush x ]
s-compile (AId x) = [ SLoad x ]
s-compile (APlus e e₁) = s-compile e ++ s-compile e₁ ++ [ SPlus ]
s-compile (AMinus e e₁) = s-compile e ++ s-compile e₁ ++ [ SMinus ]
s-compile (AMult e e₁) = s-compile e ++ s-compile e₁ ++ [ SMult ]

s-compile-correct : ∀ (st : state) (e : aexp) →
                    s-execute st [] (s-compile e) ≡ [ aeval st e ]
s-compile-correct st e = s-compile-correct' st [] e
  where
    s-compile-dist : ∀ (st : state) (stack : List ℕ) (e₁ e₂ : List sinstr) →
                     s-execute st stack (e₁ ++ e₂) ≡ s-execute st (s-execute st stack e₁) e₂
    s-compile-dist st stack [] e₂ = refl
    s-compile-dist st stack (SPush x ∷ e₁) e₂ = s-compile-dist st (x ∷ stack) e₁ e₂
    s-compile-dist st stack (SLoad x ∷ e₁) e₂ = s-compile-dist st (st x ∷ stack) e₁ e₂
    s-compile-dist st [] (SPlus ∷ e₁) e₂ = s-compile-dist st [] e₁ e₂
    s-compile-dist st (x ∷ []) (SPlus ∷ e₁) e₂ = s-compile-dist st [ x ] e₁ e₂
    s-compile-dist st (x ∷ x₁ ∷ stack) (SPlus ∷ e₁) e₂ = s-compile-dist st (x₁ + x ∷ stack) e₁ e₂
    s-compile-dist st [] (SMinus ∷ e₁) e₂ = s-compile-dist st [] e₁ e₂
    s-compile-dist st (x ∷ []) (SMinus ∷ e₁) e₂ = s-compile-dist st [ x ] e₁ e₂
    s-compile-dist st (x ∷ x₁ ∷ stack) (SMinus ∷ e₁) e₂ = s-compile-dist st (x₁ ∸ x ∷ stack) e₁ e₂
    s-compile-dist st [] (SMult ∷ e₁) e₂ = s-compile-dist st [] e₁ e₂
    s-compile-dist st (x ∷ []) (SMult ∷ e₁) e₂ = s-compile-dist st [ x ] e₁ e₂
    s-compile-dist st (x ∷ x₁ ∷ stack) (SMult ∷ e₁) e₂ = s-compile-dist st (x₁ * x ∷ stack) e₁ e₂

    s-compile-correct' : ∀ (st : state) (stack : List ℕ) (e : aexp) →
                         s-execute st stack (s-compile e) ≡ [ aeval st e ] ++ stack
    s-compile-correct' st stack (ANum x) = refl
    s-compile-correct' st stack (AId x) = refl
    s-compile-correct' st stack (APlus e₁ e₂)
      rewrite s-compile-dist st stack (s-compile e₁) (s-compile e₂ ++ [ SPlus ])
            | s-compile-correct' st stack e₁
            | s-compile-dist st (aeval st e₁ ∷ stack) (s-compile e₂) [ SPlus ]
            | s-compile-correct' st (aeval st e₁ ∷ stack) e₂
            = refl
    s-compile-correct' st stack (AMinus e₁ e₂)
      rewrite s-compile-dist st stack (s-compile e₁) (s-compile e₂ ++ [ SMinus ])
            | s-compile-correct' st stack e₁
            | s-compile-dist st (aeval st e₁ ∷ stack) (s-compile e₂) [ SMinus ]
            | s-compile-correct' st (aeval st e₁ ∷ stack) e₂
            = refl
    s-compile-correct' st stack (AMult e₁ e₂)
      rewrite s-compile-dist st stack (s-compile e₁) (s-compile e₂ ++ [ SMult ])
            | s-compile-correct' st stack e₁
            | s-compile-dist st (aeval st e₁ ∷ stack) (s-compile e₂) [ SMult ]
            | s-compile-correct' st (aeval st e₁ ∷ stack) e₂
            = refl
