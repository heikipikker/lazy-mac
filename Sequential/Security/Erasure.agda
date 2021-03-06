import Lattice as L

-- A is the security level of the attacker
module Sequential.Security.Erasure (𝓛 : L.Lattice) (A : L.Label 𝓛) where

open import Types 𝓛
open import Sequential.Calculus 𝓛
open import Sequential.Semantics 𝓛

open import Data.Sum
open import Relation.Binary.PropositionalEquality hiding (subst ; [_])
open import Relation.Nullary
open import Data.Empty

εᵀ : ∀ {τ π} -> Term π τ -> Term π τ
εᵀ （） = （）
εᵀ True = True
εᵀ False = False
εᵀ (Id t) = Id (εᵀ t)
εᵀ (unId t) = unId (εᵀ t)
εᵀ (Var τ∈π) = Var τ∈π
εᵀ (Abs t) = Abs (εᵀ t)
εᵀ (App t t₁) = App (εᵀ t) (εᵀ t₁)
εᵀ (If t Then t₁ Else t₂) = If (εᵀ t) Then (εᵀ t₁) Else (εᵀ t₂)
εᵀ (Return l t) = Return l (εᵀ t)
εᵀ (t >>= t₁) = (εᵀ t) >>= (εᵀ t₁)
εᵀ (Mac l t) = Mac l (εᵀ t)
εᵀ (Res l t) with l ⊑? A
εᵀ (Res l t) | yes p = Res l (εᵀ t)
εᵀ (Res l t) | no ¬p = Res l ∙
εᵀ (label {h = H} l⊑h t) with H ⊑? A
εᵀ (label l⊑h t) | yes p = label l⊑h (εᵀ t)
εᵀ (label l⊑h t) | no ¬p = label∙ l⊑h (εᵀ t)
εᵀ (label∙ l⊑h t) = label∙ l⊑h (εᵀ t)
εᵀ (unlabel l⊑h t) = unlabel l⊑h (εᵀ t)
εᵀ (new {h = H} l⊑h t) with H ⊑? A
... | yes p = new l⊑h (εᵀ t)
... | no ¬p = new∙ l⊑h (εᵀ t)
εᵀ (new∙ l⊑h t) = new∙ l⊑h (εᵀ t)
εᵀ (read l⊑h t) = read l⊑h (εᵀ t)
εᵀ (write {h = H} l⊑h t₁ t₂) with H ⊑? A
... | yes p = write l⊑h (εᵀ t₁) (εᵀ t₂)
... | no ¬p = write∙ l⊑h (εᵀ t₁) (εᵀ t₂)
εᵀ (write∙ l⊑h t₁ t₂) = write∙ l⊑h (εᵀ t₁) (εᵀ t₂)
εᵀ (#[ n ]) = #[ n ]
εᵀ (#[ n ]ᴰ) = #[ n ]ᴰ
εᵀ (fork {h = h} l⊑h t) with h ⊑? A
... | yes _ = fork l⊑h (εᵀ t)
... | no _ = fork∙ l⊑h (εᵀ t)
εᵀ (fork∙ l⊑h t) = fork∙ l⊑h (εᵀ t)
εᵀ (deepDup t) = deepDup (εᵀ t)
εᵀ ∙ = ∙

-- TODO use graph
εᵀ¬Val : ∀ {π τ} {t : Term π τ} -> ¬ Value t -> ¬ (Value (εᵀ t))
εᵀ¬Val {t = （）} ¬val val-ε = ¬val val-ε
εᵀ¬Val {t = True} ¬val val-ε = ¬val val-ε
εᵀ¬Val {t = False} ¬val val-ε = ¬val val-ε
εᵀ¬Val {t = Id t} ¬val val-ε = ¬val (Id t)
εᵀ¬Val {t = unId t} ¬val ()
εᵀ¬Val {t = Var τ∈π} ¬val val-ε = ¬val val-ε
εᵀ¬Val {t = Abs t} ¬val val-ε = ¬val (Abs t)
εᵀ¬Val {t = App t t₁} ¬val ()
εᵀ¬Val {t = If t Then t₁ Else t₂} ¬val ()
εᵀ¬Val {t = Return l t} ¬val ()
εᵀ¬Val {t = t >>= t₁} ¬val ()
εᵀ¬Val {t = Mac l t} ¬val val-ε = ¬val (Mac t)
εᵀ¬Val {t = Res l t} ¬val val-ε = ¬val (Res t)
εᵀ¬Val {t = label {h = H} l⊑h t} ¬val val-ε with H ⊑? A
εᵀ¬Val {π} {._} {label l⊑h t} ¬val () | yes p
εᵀ¬Val {π} {._} {label l⊑h t} ¬val () | no ¬p
εᵀ¬Val {t = label∙ l⊑h t} ¬val ()
εᵀ¬Val {t = unlabel l⊑h t} ¬val ()
εᵀ¬Val {t = new {h = H} l⊑h t} ¬val val-ε with H ⊑? A
εᵀ¬Val {π} {._} {new l⊑h t} ¬val () | yes p
εᵀ¬Val {π} {._} {new l⊑h t} ¬val () | no ¬p
εᵀ¬Val {t = new∙ l⊑h t} ¬val ()
εᵀ¬Val {t = read l⊑h t} ¬val ()
εᵀ¬Val {t = write {h = H} l⊑h t₁ t₂} ¬val val-ε with H ⊑? A
εᵀ¬Val {π} {._} {write l⊑h t₁ t₂} ¬val () | yes p
εᵀ¬Val {π} {._} {write l⊑h t₁ t₂} ¬val () | no ¬p
εᵀ¬Val {t = write∙ l⊑h t₁ t₂} ¬val ()
εᵀ¬Val {t = #[ t ]} ¬val val-ε = ¬val #[ t ]
εᵀ¬Val {t = #[ t ]ᴰ} ¬val val-ε = ¬val #[ t ]ᴰ
εᵀ¬Val {t = fork {h = h} l⊑h t} ¬val val-ε with h ⊑? A
εᵀ¬Val {t = fork l⊑h t} ¬val ()  | yes _
εᵀ¬Val {t = fork l⊑h t} ¬val () | no _
εᵀ¬Val {t = fork∙ l⊑h t} ¬val ()
εᵀ¬Val {t = deepDup t} ¬val ()
εᵀ¬Val {t = ∙} ¬val ()


-- TODO use graph
εᵀ-Val : ∀ {τ π} {v : Term π τ} -> Value v -> Value (εᵀ v)
εᵀ-Val （） = （）
εᵀ-Val True = True
εᵀ-Val False = False
εᵀ-Val (Abs t) = Abs (εᵀ t)
εᵀ-Val (Id t) = Id (εᵀ t)
εᵀ-Val {Mac l τ} (Mac t) = Mac _
εᵀ-Val {Res l τ} (Res t) with l ⊑? A
εᵀ-Val {Res l τ} (Res t) | yes p = Res (εᵀ t)
εᵀ-Val {Res l τ} (Res t) | no ¬p = Res ∙
εᵀ-Val (#[ n ]) = #[ n ]
εᵀ-Val (#[ n ]ᴰ) = #[ n ]ᴰ

-- TODO use graph
εᵀ¬Var : ∀ {π τ} {t : Term π τ} -> ¬ IsVar t -> ¬ (IsVar (εᵀ t))
εᵀ¬Var {t = （）} ¬var var-ε = ¬var var-ε
εᵀ¬Var {t = True} ¬var var-ε = ¬var var-ε
εᵀ¬Var {t = False} ¬var var-ε = ¬var var-ε
εᵀ¬Var {t = Id t} ¬var ()
εᵀ¬Var {t = unId t} ¬var ()
εᵀ¬Var {t = Var τ∈π} ¬var var-ε = ¬var (Var τ∈π)
εᵀ¬Var {t = Abs t} ¬var ()
εᵀ¬Var {t = App t t₁} ¬var ()
εᵀ¬Var {t = If t Then t₁ Else t₂} ¬var ()
εᵀ¬Var {t = Return l t} ¬var ()
εᵀ¬Var {t = t >>= t₁} ¬var ()
εᵀ¬Var {t = Mac l t} ¬var ()
εᵀ¬Var {t = Res l t} ¬var var-ε with l ⊑? A
εᵀ¬Var {π} {._} {Res l t} ¬var () | yes p
εᵀ¬Var {π} {._} {Res l t} ¬var () | no ¬p
εᵀ¬Var {t = label {h = H} l⊑h t} ¬var var-ε with H ⊑? A
εᵀ¬Var {π} {._} {label l⊑h t} ¬var () | yes p
εᵀ¬Var {π} {._} {label l⊑h t} ¬var () | no ¬p
εᵀ¬Var {t = label∙ l⊑h t} ¬var ()
εᵀ¬Var {t = unlabel l⊑h t} ¬var ()
εᵀ¬Var {t = new {h = H} l⊑h t} ¬var val-ε with H ⊑? A
εᵀ¬Var {π} {._} {new l⊑h t} ¬var () | yes p
εᵀ¬Var {π} {._} {new l⊑h t} ¬var () | no ¬p
εᵀ¬Var {t = new∙ l⊑h t} ¬var ()
εᵀ¬Var {t = read l⊑h t} ¬var ()
εᵀ¬Var {t = write {h = H} l⊑h t₁ t₂} ¬var val-ε with H ⊑? A
εᵀ¬Var {π} {._} {write l⊑h t₁ t₂} ¬var () | yes p
εᵀ¬Var {π} {._} {write l⊑h t₁ t₂} ¬var () | no ¬p
εᵀ¬Var {t = write∙ l⊑h t₁ t₂} ¬var ()
εᵀ¬Var {t = #[ t ]} ¬var ()
εᵀ¬Var {t = #[ t ]ᴰ} ¬var ()
εᵀ¬Var {t = fork {h = h} l⊑h t} ¬var var-ε with h ⊑? A
εᵀ¬Var {t = fork l⊑h t} ¬var () | yes _
εᵀ¬Var {t = fork l⊑h t} ¬var () | no _
εᵀ¬Var {t = fork∙ l⊑h t} ¬var ()
εᵀ¬Var {t = deepDup t} ¬var ()
εᵀ¬Var {t = ∙} ¬var ()

open import Data.Maybe as M
open import Function

map-εᵀ : ∀ {l π} ->  Heap l π -> Heap l π
map-εᵀ [] = []
map-εᵀ (t ∷ Δ) = (M.map εᵀ t) ∷ (map-εᵀ Δ)
map-εᵀ ∙ = ∙

εᶜ : ∀ {π τ₁ τ₂ l} -> Cont l π τ₁ τ₂ -> Cont l π τ₁ τ₂
εᶜ (Var x∈π) = Var x∈π
εᶜ (# x∈π) = # x∈π
εᶜ {τ₂ = τ₂} (Then t₁ Else t₂) = Then (εᵀ t₁) Else εᵀ t₂
εᶜ {τ₁ = Mac .l α} {τ₂ = Mac l β} (Bind t) = Bind (εᵀ t)
εᶜ (unlabel {τ = τ} p) = unlabel p
εᶜ (write {H = H}  l⊑h τ∈π) with H ⊑? A
... | yes p = write l⊑h τ∈π
... | no ¬p = write∙ l⊑h τ∈π
εᶜ (write∙ l⊑h τ∈π) = write∙ l⊑h τ∈π
εᶜ (read l⊑h) = read l⊑h
εᶜ unId = unId

-- Fully homomorphic erasure on stack
εˢ : ∀ {τ₁ τ₂ π l} -> Stack l π τ₁ τ₂ -> Stack l π τ₁ τ₂
εˢ [] = []
εˢ (c ∷ S) = (εᶜ c) ∷ εˢ S
εˢ ∙ = ∙

ε : ∀ {l τ} -> Dec (l ⊑ A) -> State l τ -> State l τ
ε (no x) s = ∙
ε (yes y) ⟨ Δ , t , S ⟩ = ⟨ map-εᵀ Δ , εᵀ t , εˢ S ⟩
ε (yes y) ∙ = ∙

--------------------------------------------------------------------------------

ε-wken : ∀ {τ π₁ π₂} -> (t : Term π₁ τ) (p : π₁ ⊆ π₂) -> εᵀ (wken t p) ≡ wken (εᵀ t) p
ε-wken （） p = refl
ε-wken True p = refl
ε-wken False p = refl
ε-wken (Id t) p rewrite ε-wken t p = refl
ε-wken (unId t) p rewrite ε-wken t p = refl
ε-wken (Var τ∈π) p = refl
ε-wken (Abs t) p with ε-wken t (cons p)
... | x rewrite x = refl
ε-wken (App t t₁) p
  rewrite ε-wken t p | ε-wken t₁ p = refl
ε-wken (If t Then t₁ Else t₂) p
  rewrite ε-wken t p | ε-wken t₁ p | ε-wken t₂ p = refl
ε-wken (Return l t) p rewrite ε-wken t p = refl
ε-wken (t >>= t₁) p
  rewrite ε-wken t p | ε-wken t₁ p = refl
ε-wken (Mac l t) p rewrite ε-wken t p = refl
ε-wken (Res l t) p with l ⊑? A
... | no _ = refl
... | yes _ rewrite ε-wken t p = refl
ε-wken (label {h = H} l⊑h t) p with H ⊑? A
... | no ¬p rewrite ε-wken t p = refl
... | yes _ rewrite ε-wken t p = refl
ε-wken (label∙ l⊑h t) p rewrite ε-wken t p = refl
ε-wken (unlabel l⊑h t) p rewrite ε-wken t p = refl
ε-wken (read x t) p rewrite ε-wken t p = refl
ε-wken (write {h = H} x t t₁) p with H ⊑? A
... | yes _ rewrite ε-wken t p | ε-wken t₁ p = refl
... | no _ rewrite ε-wken t p | ε-wken t₁ p = refl
ε-wken (write∙ x t t₁) p rewrite ε-wken t p | ε-wken t₁ p = refl
ε-wken (new {h = H} x t) p with H ⊑? A
... | yes _  rewrite ε-wken t p = refl
... | no _ rewrite ε-wken t p = refl
ε-wken (new∙ x t) p rewrite ε-wken t p = refl
ε-wken #[ n ] p = refl
ε-wken #[ n ]ᴰ p = refl
ε-wken (fork {h = h} l⊑h t) p with h ⊑? A
... | yes _ rewrite ε-wken t p = refl
... | no _ rewrite ε-wken t p = refl
ε-wken (fork∙ l⊑h t) p rewrite ε-wken t p = refl
ε-wken (deepDup t) p rewrite ε-wken t p = refl
ε-wken ∙ p = refl

{-# REWRITE ε-wken #-}

--------------------------------------------------------------------------------


εᶜ-wken : ∀ {τ₁ τ₂ l π₁ π₂} -> (C : Cont l π₁ τ₁ τ₂) (p : π₁ ⊆ π₂) -> εᶜ (wkenᶜ C p) ≡ wkenᶜ (εᶜ C) p
εᶜ-wken (Var τ∈π) p = refl
εᶜ-wken (# τ∈π) p = refl
εᶜ-wken (Then x Else x₁) p = refl
εᶜ-wken (Bind x) p = refl
εᶜ-wken (unlabel p) p₁ = refl
εᶜ-wken unId p = refl
εᶜ-wken (write {H = H} x τ∈π) p with H ⊑? A
... | yes _ = refl
... | no _ = refl
εᶜ-wken (write∙ x τ∈π) p = refl
εᶜ-wken (read x) p = refl

{-# REWRITE εᶜ-wken #-}

εˢ-wken : ∀ {τ₁ τ₂ l π₁ π₂} -> (S : Stack l π₁ τ₁ τ₂) (p : π₁ ⊆ π₂) -> εˢ (wkenˢ S p) ≡ wkenˢ (εˢ S) p
εˢ-wken [] p = refl
εˢ-wken (C ∷ S) p rewrite εˢ-wken S p = refl
εˢ-wken ∙ p = refl

{-# REWRITE εˢ-wken #-}

--------------------------------------------------------------------------------


ε-subst : ∀ {τ τ' π} (t₁ : Term π τ') (t₂ : Term (τ' ∷ π) τ) -> εᵀ (subst t₁ t₂) ≡ subst (εᵀ t₁) (εᵀ t₂)
ε-subst = ε-tm-subst [] _
  where ε-var-subst  :  ∀ {l} {α β} (π₁ : Context) (π₂ : Context) (t₁ : Term π₂ α) (β∈π : β ∈⟨ l ⟩ (π₁ ++ [ α ] ++ π₂))
                      ->  εᵀ (var-subst π₁ π₂ t₁ β∈π) ≡ var-subst π₁ π₂ (εᵀ t₁) β∈π
        ε-var-subst [] π₂ t₁ ⟪ here ⟫ = refl
        ε-var-subst [] π₁ t₁ (⟪ there β∈π ⟫) = refl
        ε-var-subst (β ∷ π₁) π₂ t₁ ⟪ here ⟫ = refl
        ε-var-subst {l} (τ ∷ π₁) π₂ t₁ (⟪ there β∈π ⟫)
          rewrite ε-wken (var-subst π₁ π₂ t₁ ⟪ β∈π ⟫) (drop {_} {τ} refl-⊆) | ε-var-subst {l} π₁ π₂ t₁ ⟪ β∈π ⟫ = refl

        ε-tm-subst : ∀ {τ τ'} (π₁ : Context) (π₂ : Context) (t₁ : Term π₂ τ') (t₂ : Term (π₁ ++ [ τ' ] ++ π₂) τ)
                   ->  εᵀ (tm-subst π₁ π₂ t₁ t₂) ≡ tm-subst π₁ π₂ (εᵀ t₁) (εᵀ t₂)
        ε-tm-subst π₁ π₂ t₁ （） = refl
        ε-tm-subst π₁ π₂ t₁ True = refl
        ε-tm-subst π₁ π₂ t₁ False = refl
        ε-tm-subst π₁ π₂ t₁ (Id t₂) rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (unId t₂) rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (Var {l} ⟪ τ∈π ⟫) rewrite ε-var-subst {l} π₁ π₂ t₁ (⟪ ∈ᴿ-∈  τ∈π ⟫) = refl
        ε-tm-subst π₁ π₂ t₁ (Abs t₂)  rewrite ε-tm-subst (_ ∷ π₁) π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (App t₂ t₃)
          rewrite ε-tm-subst π₁ π₂ t₁ t₂ | ε-tm-subst π₁ π₂ t₁ t₃ = refl
        ε-tm-subst π₁ π₂ t₁ (If t₂ Then t₃ Else t₄)
          rewrite ε-tm-subst π₁ π₂ t₁ t₂ | ε-tm-subst π₁ π₂ t₁ t₃ | ε-tm-subst π₁ π₂ t₁ t₄ = refl
        ε-tm-subst π₁ π₂ t₁ (Return l t₂) rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (t₂ >>= t₃)
          rewrite ε-tm-subst π₁ π₂ t₁ t₂ | ε-tm-subst π₁ π₂ t₁ t₃ = refl
        ε-tm-subst π₁ π₂ t₁ (Mac l t₂) rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (Res l t₂) with l ⊑? A
        ε-tm-subst π₁ π₂ t₁ (Res l t₂) | yes p rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (Res l t₂) | no ¬p = refl
        ε-tm-subst π₁ π₂ t₁ (label {h = H} l⊑h t₂) with H ⊑? A
        ε-tm-subst π₁ π₂ t₁ (label l⊑h t₂) | yes p rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (label l⊑h t₂) | no ¬p rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (label∙ l⊑h t₂) rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (unlabel l⊑h t₂) rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (read x t₂) rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (write {h = H} x t₂ t₃) with H ⊑? A
        ... | yes _ rewrite ε-tm-subst π₁ π₂ t₁ t₂ | ε-tm-subst π₁ π₂ t₁ t₃ = refl
        ... | no _ rewrite ε-tm-subst π₁ π₂ t₁ t₂ | ε-tm-subst π₁ π₂ t₁ t₃ = refl
        ε-tm-subst π₁ π₂ t₁ (write∙ x t₂ t₃)
          rewrite ε-tm-subst π₁ π₂ t₁ t₂ | ε-tm-subst π₁ π₂ t₁ t₃ = refl
        ε-tm-subst π₁ π₂ t₁ (new {h = H} x t₂) with H ⊑? A
        ... | yes _ rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ... | no _ rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (new∙ x t₂) rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ #[ n ] = refl
        ε-tm-subst π₁ π₂ t₁ #[ n ]ᴰ = refl
        ε-tm-subst π₁ π₂ t₁ (fork {h = h} l⊑h t₂) with h ⊑? A
        ... | yes _ rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ... | no _ rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (fork∙ l⊑h t₂) rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ (deepDup t₂) rewrite ε-tm-subst π₁ π₂ t₁ t₂ = refl
        ε-tm-subst π₁ π₂ t₁ ∙ = refl


{-# REWRITE ε-subst #-}

ε-deepDupᵀ-≡ : ∀ {π τ} -> (t : Term π τ) ->  εᵀ (deepDupᵀ t) ≡ deepDupᵀ (εᵀ t)
ε-deepDupᵀ-≡ = εᵀ-dup-ufv-≡ []
  where εᵀ-dup-ufv-≡ : ∀ {π τ} -> (vs : Vars π) (t : Term π τ) ->  εᵀ (dup-ufv vs t) ≡ dup-ufv vs (εᵀ t)
        εᵀ-dup-ufv-≡ vs （） = refl
        εᵀ-dup-ufv-≡ vs True = refl
        εᵀ-dup-ufv-≡ vs False = refl
        εᵀ-dup-ufv-≡ vs (Id t)
          rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (unId t)
          rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (Var ⟪ τ∈π ⟫) with memberⱽ (∈ᴿ-∈ τ∈π) vs
        εᵀ-dup-ufv-≡ vs (Var ⟪ τ∈π ⟫) | yes p = refl
        εᵀ-dup-ufv-≡ vs (Var ⟪ τ∈π ⟫) | no ¬p = refl
        εᵀ-dup-ufv-≡ vs (Abs t)
          rewrite εᵀ-dup-ufv-≡ (here ∷ (mapⱽ there vs)) t = refl
        εᵀ-dup-ufv-≡ vs (App t t₁)
          rewrite εᵀ-dup-ufv-≡ vs t | εᵀ-dup-ufv-≡ vs t₁ = refl
        εᵀ-dup-ufv-≡ vs (If t Then t₁ Else t₂)
          rewrite εᵀ-dup-ufv-≡ vs t | εᵀ-dup-ufv-≡ vs t₁ | εᵀ-dup-ufv-≡ vs t₂ = refl
        εᵀ-dup-ufv-≡ vs (Return l t) rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (t >>= t₁)
          rewrite εᵀ-dup-ufv-≡ vs t | εᵀ-dup-ufv-≡ vs t₁ = refl
        εᵀ-dup-ufv-≡ vs (Mac l t) rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (Res l t) with l ⊑? A
        εᵀ-dup-ufv-≡ vs (Res l t) | yes p rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (Res l t) | no ¬p = refl
        εᵀ-dup-ufv-≡ vs (label {h = H} l⊑h t) with H ⊑? A
        εᵀ-dup-ufv-≡ vs (label l⊑h t) | yes p rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (label l⊑h t) | no ¬p rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (label∙ l⊑h t) rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (unlabel l⊑h t) rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (read x t) rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (write {h = H} x t t₁) with H ⊑? A
        ... | yes _ rewrite εᵀ-dup-ufv-≡ vs t |  εᵀ-dup-ufv-≡ vs t₁ = refl
        ... | no _ rewrite εᵀ-dup-ufv-≡ vs t |  εᵀ-dup-ufv-≡ vs t₁ = refl
        εᵀ-dup-ufv-≡ vs (write∙ x t t₁) rewrite εᵀ-dup-ufv-≡ vs t |  εᵀ-dup-ufv-≡ vs t₁ = refl
        εᵀ-dup-ufv-≡ vs (new {h = H} x t) with H ⊑? A
        ... | yes _ rewrite εᵀ-dup-ufv-≡ vs t = refl
        ... | no _ rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (new∙ x t) rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs #[ n ] = refl
        εᵀ-dup-ufv-≡ vs #[ n ]ᴰ = refl
        εᵀ-dup-ufv-≡ vs (fork {h = h} l⊑h t) with h ⊑? A
        ... | yes _ rewrite εᵀ-dup-ufv-≡ vs t = refl
        ... | no _ rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (fork∙ l⊑h t) rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs (deepDup t) rewrite εᵀ-dup-ufv-≡ vs t = refl
        εᵀ-dup-ufv-≡ vs ∙ = refl

{-# REWRITE ε-deepDupᵀ-≡ #-}

--------------------------------------------------------------------------------
-- Heap lemmas

memberᴱ : ∀ {l π π' τ} {Δ : Heap l π} {t : Term π' τ} (τ∈π : τ ∈⟨ l ⟩ᴿ π) ->
           τ∈π ↦ t ∈ᴴ Δ -> τ∈π ↦ (εᵀ t) ∈ᴴ (map-εᵀ Δ)
memberᴱ {l} ⟪ τ∈π ⟫ = aux ⟪ (∈ᴿ-∈ τ∈π) ⟫
  where aux : ∀ {π π' τ} {Δ : Heap l π} {t : Term π' τ} (τ∈π : τ ∈⟨ l ⟩ π)
            -> Memberᴴ (just t) τ∈π Δ -> Memberᴴ (just (εᵀ t)) τ∈π (map-εᵀ Δ)
        aux (⟪ here ⟫) here = here
        aux (⟪ there τ∈π' ⟫) (there x) = there (aux ⟪ τ∈π' ⟫ x)

updateᴱ : ∀ {l π π' τ} {Δ Δ' : Heap l π} {mt : Maybe (Term π' τ)} {τ∈π : τ ∈⟨ l ⟩ π}
          -> Updateᴴ mt τ∈π Δ Δ' -> Updateᴴ (M.map εᵀ mt) τ∈π (map-εᵀ Δ) (map-εᵀ Δ')
updateᴱ here = here
updateᴱ (there x) = there (updateᴱ x)

--------------------------------------------------------------------------------

εᴴ : ∀ {l} -> Dec (l ⊑ A) -> Heap∙ l -> Heap∙ l
εᴴ (yes p) ⟨ Δ ⟩ = ⟨ map-εᵀ Δ ⟩
εᴴ (yes p) ∙ = ∙
εᴴ (no ¬p) Δ = ∙

εᴴ-ext : ∀ {l} -> (x y : Dec (l ⊑ A)) (Δ : Heap∙ l) -> εᴴ x Δ ≡ εᴴ y Δ
εᴴ-ext (yes p) (yes p₁) ⟨ x ⟩ = refl
εᴴ-ext (yes p) (yes p₁) ∙ = refl
εᴴ-ext (yes p) (no ¬p) Δ = ⊥-elim (¬p p)
εᴴ-ext (no ¬p) (yes p) Δ = ⊥-elim (¬p p)
εᴴ-ext (no ¬p) (no ¬p₁) Δ = refl

map-εᴴ : ∀ {ls} -> Heaps ls -> Heaps ls
map-εᴴ [] = []
map-εᴴ {l ∷ ls} (Δ ∷ Γ) = εᴴ (_ ⊑? A) Δ ∷ map-εᴴ Γ

εᴹ : ∀ {l} -> Dec (l ⊑ A) -> Memory l -> Memory l
εᴹ (yes p) M = M
εᴹ (no ¬p) M = ∙

map-εᴹ : ∀ {ls} -> Memories ls -> Memories ls
map-εᴹ [] = []
map-εᴹ (M ∷ Ms) = (εᴹ (_ ⊑? A) M) ∷ (map-εᴹ Ms)

εᵀˢ : ∀ {l τ} -> Dec (l ⊑ A) -> TS∙ l  τ -> TS∙ l τ
εᵀˢ (yes _) ⟨ t , S ⟩ = ⟨ εᵀ t , εˢ S ⟩
εᵀˢ (yes _) ∙ = ∙
εᵀˢ (no _) _ = ∙

εᵀˢ-ext-≡ : ∀ {l τ} -> (x y : Dec (l ⊑ A)) (Ts : TS∙ l τ) -> εᵀˢ x Ts ≡ εᵀˢ y Ts
εᵀˢ-ext-≡ (yes p) (yes p₁) ⟨ t , S ⟩ = refl
εᵀˢ-ext-≡ (yes p) (yes p₁) ∙ = refl
εᵀˢ-ext-≡ (yes p) (no ¬p) Ts = ⊥-elim (¬p p)
εᵀˢ-ext-≡ (no ¬p) (yes p) Ts = ⊥-elim (¬p p)
εᵀˢ-ext-≡ (no ¬p) (no ¬p₁) Ts = refl

-- Erasure for Programs
ε₁ᴾ : ∀ {l ls τ} -> (x : Dec (l ⊑ A)) -> Program l ls τ -> Program l ls τ
ε₁ᴾ x ⟨ Ms , Γ , TS ⟩ = ⟨ map-εᴹ Ms , map-εᴴ Γ , εᵀˢ x TS ⟩

writeᴹ∙-≡ : ∀ {H ls} {Ms₁ Ms₂ : Memories ls} {X Y : Memory H} -> H ⋤ A -> H ↦ X ∈ˢ Ms₁ -> Ms₂ ≔ Ms₁ [ H ↦ Y ]ˢ -> (map-εᴹ Ms₁) ≡ (map-εᴹ Ms₂)
writeᴹ∙-≡ {H} H⋢A here here with H ⊑? A
writeᴹ∙-≡ H⋢A here here | yes p = ⊥-elim (H⋢A p)
writeᴹ∙-≡ H⋢A here here | no ¬p = refl
writeᴹ∙-≡ H⋢A here (there {u = u} y) = ⊥-elim (∈-not-unique (updateˢ-∈ y) u)
writeᴹ∙-≡ H⋢A (there {u = u} x) here = ⊥-elim (∈-not-unique (memberˢ-∈ x) u)
writeᴹ∙-≡ H⋢A (there x) (there y) rewrite writeᴹ∙-≡ H⋢A x y = refl

writeᴴ∙-≡ : ∀ {H ls} {Γ₁ Γ₂ : Heaps ls} {Δ₁ Δ₂ : Heap∙ H} -> H ⋤ A -> H ↦ Δ₁ ∈ᴱ Γ₁ -> Γ₂ ≔ Γ₁ [ H ↦ Δ₂ ]ᴱ -> (map-εᴴ Γ₁) ≡ (map-εᴴ Γ₂)
writeᴴ∙-≡ {H} H⋤A here here with H ⊑? A
... | yes H⊑A = ⊥-elim (H⋤A H⊑A)
... | no _ = refl
writeᴴ∙-≡ H⋤A here (there {u = u} uᴴ) = ⊥-elim (∈-not-unique (updateᴱ-∈ uᴴ) u)
writeᴴ∙-≡ H⋤A (there {u = u} H∈Γ) here = ⊥-elim (∈-not-unique (memberᴱ-∈ H∈Γ) u)
writeᴴ∙-≡ H⋤A (there H∈Γ) (there uᴴ) rewrite writeᴴ∙-≡ H⋤A H∈Γ uᴴ = refl

memberᴹ : ∀ {l ls} {Ms : Memories ls} {M : Memory l} -> l ⊑ A -> l ↦ M ∈ˢ Ms -> l ↦ M ∈ˢ (map-εᴹ Ms)
memberᴹ {l} l⊑A here with l ⊑? A
... | yes _ = here
... | no ¬p = ⊥-elim (¬p l⊑A)
memberᴹ l⊑A (there x) = there (memberᴹ l⊑A x)

updateᴹ : ∀ {l ls} {Ms Ms' : Memories ls} {M : Memory l} -> l ⊑ A -> Ms' ≔ Ms [ l ↦ M ]ˢ -> (map-εᴹ Ms') ≔ (map-εᴹ Ms) [ l ↦ M ]ˢ
updateᴹ {l} l⊑A here with l ⊑? A
... | yes _ = here
... | no ¬p = ⊥-elim (¬p l⊑A)
updateᴹ l⊑A (there x) = there (updateᴹ l⊑A x)

memberᴴ : ∀ {l ls} {Γ : Heaps ls} {Δ : Heap∙ l} -> (p : l ⊑ A) -> l ↦ Δ ∈ᴱ Γ -> l ↦ εᴴ (yes p) Δ ∈ᴱ map-εᴴ Γ
memberᴴ {l} {Δ = Δ}  l⊑A here with l ⊑? A
... | yes p rewrite εᴴ-ext (yes p) (yes l⊑A) Δ = here
... | no ¬p = ⊥-elim (¬p l⊑A)
memberᴴ l⊑A (there x) = there (memberᴴ l⊑A x)

updateᴴ : ∀ {l ls} {Γ Γ' : Heaps ls} {Δ : Heap∙ l} -> (p : l ⊑ A) -> Γ' ≔ Γ [ l ↦ Δ ]ᴱ -> (map-εᴴ Γ') ≔ (map-εᴴ Γ) [ l ↦ εᴴ (yes p) Δ ]ᴱ
updateᴴ {l} {Δ = Δ} l⊑A here with l ⊑? A
... | yes p rewrite εᴴ-ext (yes p) (yes l⊑A) Δ = here
... | no ¬p = ⊥-elim (¬p l⊑A)
updateᴴ l⊑A (there x) = there (updateᴴ l⊑A x)
