-- This module defines the graph of the erasure function on terms

-- TODO move all erasure related modules in a new Security module

import Lattice as L

module Sequential.Graph (𝓛 : L.Lattice) (A : L.Label 𝓛) where

import Types as T
open T 𝓛

import Sequential.Calculus as S
open S 𝓛
open import Sequential.Erasure 𝓛 A as SE hiding (memberᴴ ; updateᴴ ; memberᴱ)

open import Relation.Nullary

data Eraseᵀ {π} : ∀ {τ} -> Term π τ -> Term π τ -> Set where
  （） : Eraseᵀ （） （）
  True : Eraseᵀ True True
  False : Eraseᵀ False False
  Id : ∀ {τ} {t t' : Term π τ} -> Eraseᵀ t t' -> Eraseᵀ (Id t) (Id t')
  unId : ∀ {τ} {t t' : Term π (Id τ)} -> Eraseᵀ t t' -> Eraseᵀ (unId t) (unId t')
  Var : ∀ {l} {τ} ->  (τ∈π : τ ∈⟨ l ⟩ᴿ π) -> Eraseᵀ (Var τ∈π) (Var τ∈π)
  Abs : ∀ {α β} {t t' : Term (α ∷ π) β} -> Eraseᵀ t t' -> Eraseᵀ (Abs t) (Abs t')
  App : ∀ {α β} {t₁ t₁' : Term π (α => β)} {t₂ t₂' : Term π α} ->
          Eraseᵀ t₁ t₁' -> Eraseᵀ t₂ t₂' -> Eraseᵀ (App t₁ t₂) (App t₁' t₂')

  If_Then_Else_ : ∀ {α} {t₁ t₁'} {t₂ t₂' t₃ t₃' : Term _ α} ->
                  Eraseᵀ t₁ t₁' -> Eraseᵀ t₂ t₂' -> Eraseᵀ t₃ t₃' ->
                  Eraseᵀ (If t₁ Then t₂ Else t₃) (If t₁' Then t₂' Else t₃')

  Return : ∀ {α l} {t t' : Term _ α} -> Eraseᵀ t t' -> Eraseᵀ (Return l t) (Return l t')
  _>>=_ : ∀ {l} {α β} {t₁ t₁' : Term π (Mac l α)} {t₂ t₂' :  Term π (α => Mac l β)} ->
            Eraseᵀ t₁ t₁' -> Eraseᵀ t₂ t₂' -> Eraseᵀ (t₁ >>= t₂) (t₁' >>= t₂')

  Mac : ∀ {α l} {t t' : Term π α} -> Eraseᵀ t t' -> Eraseᵀ (Mac l t) (Mac l t')

  Res : ∀ {α l} {t t' : Term π α} -> l ⊑ A -> Eraseᵀ t t' -> Eraseᵀ (Res l t) (Res l t')
  Res∙ : ∀ {α l} {t : Term π α} -> l ⋤ A ->  Eraseᵀ (Res l t) (Res l ∙)

  label : ∀ {l h α} {l⊑h : l ⊑ h} {t t' : Term _ α} -> (h⊑A : h ⊑ A) -> Eraseᵀ t t' -> Eraseᵀ (label l⊑h t) (label l⊑h t')
  label' : ∀ {l h α} {l⊑h : l ⊑ h} {t t' : Term _ α} -> (h⋤A : h ⋤ A) -> Eraseᵀ t t' -> Eraseᵀ (label l⊑h t) (label∙ l⊑h t')
  label∙ : ∀ {l h α} {l⊑h : l ⊑ h} {t t' : Term _ α} -> Eraseᵀ t t' -> Eraseᵀ (label∙ l⊑h t) (label∙ l⊑h t')

  unlabel : ∀ {l h τ} {t t' : Term _ (Labeled l τ)} -> (l⊑h : l ⊑ h) -> Eraseᵀ t t' -> Eraseᵀ (unlabel l⊑h t) (unlabel l⊑h t')

  read : ∀ {l h τ} {t t' : Term _ (Ref l τ)} -> (l⊑h : l ⊑ h) -> Eraseᵀ t t' -> Eraseᵀ (read {τ = τ} l⊑h t) (read l⊑h t')

  write : ∀ {l h τ} -> {t₁ t₁' : Term _ (Ref h τ)} {t₂ t₂' : Term _ τ} -> (l⊑h : l ⊑ h) (h⊑A : h ⊑ A) ->
               Eraseᵀ t₁ t₁' -> Eraseᵀ t₂ t₂' -> Eraseᵀ (write l⊑h t₁ t₂) (write l⊑h t₁' t₂')

  write' : ∀ {l h τ} -> {t₁ t₁' : Term _ (Ref h τ)} {t₂ t₂' : Term _ τ} -> (l⊑h : l ⊑ h) (h⋤A : h ⋤ A) ->
               Eraseᵀ t₁ t₁' -> Eraseᵀ t₂ t₂' -> Eraseᵀ (write l⊑h t₁ t₂) (write∙ l⊑h t₁' t₂')


  write∙ : ∀ {l h τ} {t₁ t₁' : Term _ (Ref h τ)} {t₂ t₂' : Term _ τ} -> (l⊑h : l ⊑ h) ->
             Eraseᵀ t₁ t₁' -> Eraseᵀ t₂ t₂' -> Eraseᵀ (write∙ l⊑h t₁ t₂) (write∙ l⊑h t₁' t₂')

  new : ∀ {l h τ} {t t' : Term _ τ} (l⊑h : l ⊑ h) (h⊑A : h ⊑ A) -> Eraseᵀ t t' -> Eraseᵀ (new l⊑h t) (new l⊑h t')
  new' : ∀ {l h τ} {t t' : Term _ τ} (l⊑h : l ⊑ h) (h⋤A : h ⋤ A) -> Eraseᵀ t t' -> Eraseᵀ (new l⊑h t) (new∙ l⊑h t')
  new∙ : ∀ {l h τ} {t t' : Term _ τ} (l⊑h : l ⊑ h) -> Eraseᵀ t t' -> Eraseᵀ (new∙ l⊑h t) (new∙ l⊑h t')

  #[_] :  ∀ n -> Eraseᵀ #[ n ] #[ n ]
  #[_]ᴰ :  ∀ n -> Eraseᵀ #[ n ]ᴰ #[ n ]ᴰ

  fork : ∀ {l h} {t t' : Term _ _} -> (l⊑h : l ⊑ h) (h⊑A : h ⊑ A) -> Eraseᵀ t t' -> Eraseᵀ (fork l⊑h t) (fork l⊑h t')
  fork' : ∀ {l h} {t t' : Term _ _} -> (l⊑h : l ⊑ h) (h⋤A : h ⋤ A) -> Eraseᵀ t t' -> Eraseᵀ (fork l⊑h t) (fork∙ l⊑h t')
  fork∙ : ∀ {l h} {t t' : Term _ _} -> (l⊑h : l ⊑ h) -> Eraseᵀ t t' -> Eraseᵀ (fork∙ l⊑h t) (fork∙ l⊑h t')

  deepDup : ∀ {τ} {t t' : Term π τ} -> Eraseᵀ t t' -> Eraseᵀ (deepDup t) (deepDup t')

  ∙ : ∀ {τ} -> Eraseᵀ {τ = τ} ∙ ∙


lift-εᵀ : ∀ {τ π} -> (t : Term π τ) -> Eraseᵀ t (εᵀ t)
lift-εᵀ S.（） = （）
lift-εᵀ S.True = True
lift-εᵀ S.False = False
lift-εᵀ (S.Id t) = Id (lift-εᵀ t)
lift-εᵀ (S.unId t) = unId (lift-εᵀ t)
lift-εᵀ (S.Var τ∈π) = Var τ∈π
lift-εᵀ (S.Abs t) = Abs (lift-εᵀ t)
lift-εᵀ (S.App t t₁) = App (lift-εᵀ t) (lift-εᵀ t₁)
lift-εᵀ (S.If t Then t₁ Else t₂) = If (lift-εᵀ t) Then (lift-εᵀ t₁) Else (lift-εᵀ t₂)
lift-εᵀ (S.Return l t) = Return (lift-εᵀ t)
lift-εᵀ (t S.>>= t₁) = (lift-εᵀ t) >>= (lift-εᵀ t₁)
lift-εᵀ (S.Mac l t) = Mac (lift-εᵀ t)
lift-εᵀ (S.Res l t) with l ⊑? A
lift-εᵀ (S.Res l t) | yes p = Res p (lift-εᵀ t)
lift-εᵀ (S.Res l t) | no ¬p = Res∙ ¬p
lift-εᵀ (S.label {h = h} l⊑h t) with h ⊑? A
lift-εᵀ (S.label l⊑h t) | yes p = label p (lift-εᵀ t)
lift-εᵀ (S.label l⊑h t) | no ¬p = label' ¬p (lift-εᵀ t)
lift-εᵀ (S.label∙ l⊑h t) = label∙ (lift-εᵀ t)
lift-εᵀ (S.unlabel l⊑h t) = unlabel l⊑h (lift-εᵀ t)
lift-εᵀ (S.read x t) = read x (lift-εᵀ t)
lift-εᵀ (S.write {h = h} x t t₁) with h ⊑? A
lift-εᵀ (S.write x t t₁) | yes p = write x p (lift-εᵀ t) (lift-εᵀ t₁)
lift-εᵀ (S.write x t t₁) | no ¬p = write' x ¬p (lift-εᵀ t) (lift-εᵀ t₁)
lift-εᵀ (S.write∙ x t t₁) = write∙ x (lift-εᵀ t) (lift-εᵀ t₁)
lift-εᵀ (S.new {h = h} x t) with h ⊑? A
lift-εᵀ (S.new x t) | yes p = new x p (lift-εᵀ t)
lift-εᵀ (S.new x t) | no ¬p = new' x ¬p (lift-εᵀ t)
lift-εᵀ (S.new∙ x t) = new∙ x (lift-εᵀ t)
lift-εᵀ S.#[ x ] = #[ x ]
lift-εᵀ S.#[ x ]ᴰ = #[ x ]ᴰ
lift-εᵀ (S.fork {h = h} l⊑h t) with h ⊑? A
lift-εᵀ (S.fork l⊑h t) | yes p = fork l⊑h p (lift-εᵀ t)
lift-εᵀ (S.fork l⊑h t) | no ¬p = fork' l⊑h ¬p (lift-εᵀ t)
lift-εᵀ (S.fork∙ l⊑h t) = fork∙ l⊑h (lift-εᵀ t)
lift-εᵀ (S.deepDup t) = deepDup (lift-εᵀ t)
lift-εᵀ S.∙ = ∙

open import Relation.Binary.PropositionalEquality hiding (subst)
open import Data.Empty

unlift-εᵀ : ∀ {π τ} {t t' : Term π τ} -> Eraseᵀ t t' -> εᵀ t ≡ t'
unlift-εᵀ （） = refl
unlift-εᵀ True = refl
unlift-εᵀ False = refl
unlift-εᵀ (Id x) rewrite unlift-εᵀ x = refl
unlift-εᵀ (unId x) rewrite unlift-εᵀ x = refl
unlift-εᵀ (Var τ∈π) = refl
unlift-εᵀ (Abs x) rewrite unlift-εᵀ x = refl
unlift-εᵀ (App x x₁)
  rewrite unlift-εᵀ x | unlift-εᵀ x₁ = refl
unlift-εᵀ (If x Then x₁ Else x₂)
    rewrite unlift-εᵀ x | unlift-εᵀ x₁ | unlift-εᵀ x₂ = refl
unlift-εᵀ (Return x) rewrite unlift-εᵀ x = refl
unlift-εᵀ (x >>= x₁)
  rewrite unlift-εᵀ x | unlift-εᵀ x₁ = refl
unlift-εᵀ (Mac x) rewrite unlift-εᵀ x = refl
unlift-εᵀ (Res {l = l} p x) with l ⊑? A
unlift-εᵀ (Res p x) | yes p' rewrite unlift-εᵀ x = refl
unlift-εᵀ (Res p x) | no ¬p = ⊥-elim (¬p p)
unlift-εᵀ (Res∙ {l = l} x) with l ⊑? A
unlift-εᵀ (Res∙ x) | yes p = ⊥-elim (x p)
unlift-εᵀ (Res∙ x) | no ¬p = refl
unlift-εᵀ (label {h = h} p x) with h ⊑? A
unlift-εᵀ (label p₁ x) | yes p rewrite unlift-εᵀ x = refl
unlift-εᵀ (label p x) | no ¬p = ⊥-elim (¬p p)
unlift-εᵀ (label' {h = h} h⋤A x₁) with h ⊑? A
unlift-εᵀ (label' h⋤A x₁) | yes p = ⊥-elim (h⋤A p)
unlift-εᵀ (label' h⋤A x₁) | no ¬p rewrite unlift-εᵀ x₁ = refl
unlift-εᵀ (label∙ x) rewrite unlift-εᵀ x = refl
unlift-εᵀ (unlabel l⊑h x) rewrite unlift-εᵀ x = refl
unlift-εᵀ (read l⊑h x) rewrite unlift-εᵀ x = refl
unlift-εᵀ (write {h = h} l⊑h p x x₁) with h ⊑? A
unlift-εᵀ (write l⊑h p₁ x x₁) | yes p
  rewrite unlift-εᵀ x | unlift-εᵀ x₁ = refl
unlift-εᵀ (write l⊑h p x x₁) | no ¬p = ⊥-elim (¬p p)
unlift-εᵀ (write' {h = h} l⊑h x x₁ x₂) with h ⊑? A
unlift-εᵀ (write' l⊑h x x₁ x₂) | yes p = ⊥-elim (x p)
unlift-εᵀ (write' l⊑h x x₁ x₂) | no ¬p
  rewrite unlift-εᵀ x₁ | unlift-εᵀ x₂ = refl
unlift-εᵀ (write∙ {h = h} l⊑h x x₁) with h ⊑? A
unlift-εᵀ (write∙ l⊑h x x₁) | yes p
  rewrite unlift-εᵀ x | unlift-εᵀ x₁ = refl
unlift-εᵀ (write∙ l⊑h x x₁) | no ¬p
  rewrite unlift-εᵀ x | unlift-εᵀ x₁ = refl
unlift-εᵀ (new {h = h} l⊑h p x) with h ⊑? A
unlift-εᵀ (new l⊑h p₁ x) | yes p rewrite unlift-εᵀ x = refl
unlift-εᵀ (new l⊑h p x) | no ¬p = ⊥-elim (¬p p)
unlift-εᵀ (new' {h = h} l⊑h h⋤A x) with h ⊑? A
unlift-εᵀ (new' l⊑h h⋤A x) | yes p = ⊥-elim (h⋤A p)
unlift-εᵀ (new' l⊑h h⋤A x) | no ¬p rewrite unlift-εᵀ x = refl
unlift-εᵀ (new∙ {h = h} l⊑h x) with h ⊑? A
unlift-εᵀ (new∙ l⊑h x) | yes p rewrite unlift-εᵀ x = refl
unlift-εᵀ (new∙ l⊑h x) | no ¬p rewrite unlift-εᵀ x = refl
unlift-εᵀ #[ n ] = refl
unlift-εᵀ #[ n ]ᴰ = refl
unlift-εᵀ (fork {h = h} l⊑h p x) with h ⊑? A
unlift-εᵀ (fork l⊑h p₁ x) | yes p rewrite unlift-εᵀ x = refl
unlift-εᵀ (fork l⊑h p x) | no ¬p = ⊥-elim (¬p p)
unlift-εᵀ (fork' {h = h} l⊑h h⋤A x) with h ⊑? A
unlift-εᵀ (fork' l⊑h h⋤A x) | yes p = ⊥-elim (h⋤A p)
unlift-εᵀ (fork' l⊑h h⋤A x) | no ¬p rewrite unlift-εᵀ x = refl
unlift-εᵀ (fork∙ l⊑h x) rewrite unlift-εᵀ x = refl
unlift-εᵀ (deepDup x) rewrite unlift-εᵀ x = refl
unlift-εᵀ ∙ = refl

wkenᴱ : ∀ {π₁ π₂ τ} {t t' : Term π₁ τ} -> Eraseᵀ t t' -> (p : π₁ ⊆ π₂) ->  Eraseᵀ (wken t p) (wken t' p)
wkenᴱ {π₁} {π₂} {τ} {t} e p with lift-εᵀ (wken t p)
... | x rewrite unlift-εᵀ e = x

substᴱ :  ∀ {π α β} {x x' : Term π α} {t t' : Term (α ∷ π) β} -> Eraseᵀ x x' -> Eraseᵀ t t' -> Eraseᵀ (subst x t) (subst x' t')
substᴱ {x = x} {t = t} e₁ e₂ with lift-εᵀ (subst x t)
... | e rewrite unlift-εᵀ e₁ | unlift-εᵀ e₂ = e

deepDupᵀᴱ : ∀ {π τ} {t t' : Term π τ} -> Eraseᵀ t t' -> Eraseᵀ (deepDupᵀ t) (deepDupᵀ t')
deepDupᵀᴱ {t = t} e with lift-εᵀ (deepDupᵀ t)
... | e' rewrite unlift-εᵀ e = e'

¬valᴱ : ∀ {π τ} {t t' : Term π τ} -> Eraseᵀ t t' -> ¬ (Value t') -> ¬ (Value t)
¬valᴱ （） ¬val S.（） = ¬val S.（）
¬valᴱ True ¬val S.True = ¬val S.True
¬valᴱ False ¬val S.False = ¬val S.False
¬valᴱ (Abs x) ¬val (S.Abs t) = ¬val (S.Abs _)
¬valᴱ (Id x) ¬val (S.Id t) = ¬val (S.Id _)
¬valᴱ (Mac x) ¬val (S.Mac t) = ¬val (S.Mac _)
¬valᴱ (Res x x₁) ¬val (S.Res t) = ¬val (S.Res _)
¬valᴱ (Res∙ x) ¬val (S.Res t) = ¬val (S.Res _)
¬valᴱ #[ n ] ¬val S.#[ .n ] = ¬val S.#[ n ]
¬valᴱ #[ n ]ᴰ ¬val S.#[ .n ]ᴰ = ¬val S.#[ n ]ᴰ

¬varᴱ : ∀ {π τ} {t t' : Term π τ} -> Eraseᵀ t t' -> ¬ (IsVar t') -> ¬ (IsVar t)
¬varᴱ (Var τ∈π) ¬var (S.Var .τ∈π) = ¬var (S.Var τ∈π)

valᴱ : ∀ {π τ} {t t' : Term π τ} -> Eraseᵀ t t' -> Value t' -> Value t
valᴱ （） S.（） = S.（）
valᴱ True S.True = S.True
valᴱ False S.False = S.False
valᴱ (Abs e) (S.Abs t₁) = S.Abs _
valᴱ (Id e) (S.Id t₁) = S.Id _
valᴱ (Mac e) (S.Mac t₁) = S.Mac _
valᴱ (Res x e) (S.Res t₁) = S.Res _
valᴱ (Res∙ x) (S.Res .S.∙) = S.Res _
valᴱ #[ n ] S.#[ .n ] = S.#[ n ]
valᴱ #[ n ]ᴰ S.#[ .n ]ᴰ = S.#[ n ]ᴰ

val₁ᴱ : ∀ {π τ} {t t' : Term π τ} -> Eraseᵀ t t' -> Value t -> Value t'
val₁ᴱ e val with εᵀ-Val val
... | val' rewrite unlift-εᵀ e = val'

--------------------------------------------------------------------------------

data Eraseᵀᶜ {π l} : ∀ {τ₁ τ₂} -> Cont l π τ₁ τ₂ -> Cont l π τ₁ τ₂ -> Set where
 Var : ∀ {τ₁ τ₂} -> (τ∈π : τ₁ ∈⟨ l ⟩ᴿ π) -> Eraseᵀᶜ {τ₂ = τ₂} (Var τ∈π) (Var τ∈π)
 # :  ∀ {τ} -> (τ∈π : τ ∈⟨ l ⟩ᴿ π)  -> Eraseᵀᶜ (# τ∈π) (# τ∈π)
 Then_Else_ : ∀ {τ} {t₁ t₁' t₂ t₂' : Term π τ} -> Eraseᵀ t₁ t₁' -> Eraseᵀ t₂ t₂' -> Eraseᵀᶜ (Then t₁ Else t₂) (Then t₁' Else t₂')
 Bind :  ∀ {τ₁ τ₂} {t t' : Term π (τ₁ => Mac l τ₂)} -> Eraseᵀ t t' -> Eraseᵀᶜ (Bind t) (Bind t')
 unlabel : ∀ {l' τ} (p : l' ⊑ l) -> Eraseᵀᶜ {τ₁ = Labeled l' τ} (unlabel p) (unlabel p)
 unId : ∀ {τ} -> Eraseᵀᶜ {τ₂ = τ} unId unId
 write : ∀ {τ H} (l⊑H : l ⊑ H) (H⊑A : H ⊑ A) -> (τ∈π : τ ∈⟨ l ⟩ᴿ π) -> Eraseᵀᶜ (write l⊑H τ∈π) (write l⊑H τ∈π)
 write' : ∀ {τ H} (l⊑H : l ⊑ H) (H⋤A : H ⋤ A) -> (τ∈π : τ ∈⟨ l ⟩ᴿ π) -> Eraseᵀᶜ (write l⊑H τ∈π) (write∙ l⊑H τ∈π)
 write∙ : ∀ {τ H} (l⊑H : l ⊑ H) -> (τ∈π : τ ∈⟨ l ⟩ᴿ π) -> Eraseᵀᶜ (write∙ l⊑H τ∈π) (write∙ l⊑H τ∈π)
 read : ∀ {τ L} (L⊑H : L ⊑ l) -> Eraseᵀᶜ (read {τ = τ} L⊑H) (read L⊑H)

lift-εᵀᶜ : ∀ {l π τ₁ τ₂} -> (C : Cont l π τ₁ τ₂) -> Eraseᵀᶜ C (εᶜ C)
lift-εᵀᶜ (S.Var τ∈π) = Var τ∈π
lift-εᵀᶜ (S.# τ∈π) = # τ∈π
lift-εᵀᶜ (S.Then x Else x₁) = Then (lift-εᵀ x) Else (lift-εᵀ x₁)
lift-εᵀᶜ (S.Bind x) = Bind (lift-εᵀ x)
lift-εᵀᶜ (S.unlabel p) = unlabel p
lift-εᵀᶜ S.unId = unId
lift-εᵀᶜ (S.write {H = H} x τ∈π) with H ⊑? A
lift-εᵀᶜ (S.write x τ∈π) | yes p = write x p τ∈π
lift-εᵀᶜ (S.write x τ∈π) | no ¬p = write' x ¬p τ∈π
lift-εᵀᶜ (S.write∙ x τ∈π) = write∙ x τ∈π
lift-εᵀᶜ (S.read x) = read x

unlift-εᵀᶜ : ∀ {l π τ₁ τ₂} {C C' : Cont l π τ₁ τ₂} -> Eraseᵀᶜ C C' -> C' ≡ εᶜ C
unlift-εᵀᶜ (Var τ∈π) = refl
unlift-εᵀᶜ (# τ∈π) = refl
unlift-εᵀᶜ (Then x Else x₁)
  rewrite unlift-εᵀ x | unlift-εᵀ x₁ = refl
unlift-εᵀᶜ (Bind x) rewrite unlift-εᵀ x = refl
unlift-εᵀᶜ (unlabel p) = refl
unlift-εᵀᶜ unId = refl
unlift-εᵀᶜ (write {H = H} l⊑H H⊑A τ∈π) with H ⊑? A
unlift-εᵀᶜ (write l⊑H H⊑A τ∈π) | yes p = refl
unlift-εᵀᶜ (write l⊑H H⊑A τ∈π) | no ¬p = ⊥-elim (¬p H⊑A)
unlift-εᵀᶜ (write' {H = H} l⊑H H⋤A τ∈π) with H ⊑? A
unlift-εᵀᶜ (write' l⊑H H⋤A τ∈π) | yes p = ⊥-elim (H⋤A p)
unlift-εᵀᶜ (write' l⊑H H⋤A τ∈π) | no ¬p = refl
unlift-εᵀᶜ (write∙ l⊑H τ∈π) = refl
unlift-εᵀᶜ (read L⊑H) = refl

--------------------------------------------------------------------------------

data Eraseˢ {l π} : ∀ {τ₁ τ₂} -> Stack l π τ₁ τ₂ -> Stack l π τ₁ τ₂ -> Set where
  [] : ∀ {τ} -> Eraseˢ ([] {τ = τ}) []
  _∷_ : ∀ {τ₁ τ₂ τ₃} {C₁ C₂ : Cont l π τ₁ τ₂} {S₁ S₂ : Stack l π τ₂ τ₃} -> Eraseᵀᶜ C₁ C₂ -> Eraseˢ S₁ S₂ -> Eraseˢ (C₁ ∷ S₁) (C₂ ∷ S₂)
  ∙ : ∀ {τ} -> Eraseˢ (∙ {τ = τ}) ∙

lift-εˢ : ∀ {l π τ₁ τ₂} -> (S : Stack l π τ₁ τ₂) -> Eraseˢ S (εˢ S)
lift-εˢ S.[] = []
lift-εˢ (x S.∷ S) = (lift-εᵀᶜ x) ∷ (lift-εˢ S)
lift-εˢ S.∙ = ∙

unlift-εˢ : ∀ {l π τ₁ τ₂} {S S' : Stack l π τ₁ τ₂} -> Eraseˢ S S' -> S' ≡ εˢ S
unlift-εˢ [] = refl
unlift-εˢ (x ∷ x₁) rewrite unlift-εᵀᶜ x | unlift-εˢ x₁ = refl
unlift-εˢ ∙ = refl

--------------------------------------------------------------------------------

open import Data.Maybe as M

data Eraseᴹᵀ {π τ} : (mt₁ mt₂ : Maybe (Term π τ)) -> Set where
  nothing : Eraseᴹᵀ nothing nothing
  just : ∀ {t₁ t₂} -> Eraseᵀ t₁ t₂ -> Eraseᴹᵀ (just t₁) (just t₂)

lift-εᴹᵀ : ∀ {π τ} (mt : Maybe (Term π τ)) -> Eraseᴹᵀ mt (M.map εᵀ mt)
lift-εᴹᵀ (just x) = just (lift-εᵀ x)
lift-εᴹᵀ nothing = nothing

unlift-εᴹᵀ : ∀ {π τ} {mt mt' : Maybe (Term π τ)} -> Eraseᴹᵀ mt mt' -> mt' ≡ M.map εᵀ mt
unlift-εᴹᵀ nothing = refl
unlift-εᴹᵀ (just x) rewrite unlift-εᵀ x = refl

--------------------------------------------------------------------------------

data EraseMapᵀ {l} : ∀ {π} -> (Δ₁ Δ₂ : Heap l π) -> Set where
  [] : EraseMapᵀ [] []
  _∷_ : ∀ {π τ} {mt mt' : Maybe (Term π τ)} {Δ Δ' : Heap l π} -> Eraseᴹᵀ mt mt' -> EraseMapᵀ Δ Δ' -> EraseMapᵀ (mt ∷ Δ) (mt' ∷ Δ')
  ∙ : ∀ {π} -> EraseMapᵀ {π = π} ∙ ∙

lift-map-εᵀ : ∀ {l π} -> (Δ : Heap l π) -> EraseMapᵀ Δ (map-εᵀ Δ)
lift-map-εᵀ S.[] = []
lift-map-εᵀ (t S.∷ Δ) = (lift-εᴹᵀ t) ∷ (lift-map-εᵀ Δ)
lift-map-εᵀ S.∙ = ∙

unlift-map-εᵀ : ∀ {l π} {Δ Δ' : Heap l π} -> EraseMapᵀ Δ Δ' -> Δ' ≡ map-εᵀ Δ
unlift-map-εᵀ [] = refl
unlift-map-εᵀ (x ∷ x₁) rewrite unlift-εᴹᵀ x | unlift-map-εᵀ x₁ = refl
unlift-map-εᵀ ∙ = refl

--------------------------------------------------------------------------------

data Erase {l τ} : Dec (l ⊑ A) -> State l τ -> State l τ -> Set where
  ⟨_,_,_⟩ : ∀ {l⊑A : l ⊑ A} {π τ'} {Δ Δ' : Heap l π} {t t' : Term π τ'} {S S' : Stack _ π _ _} ->
              EraseMapᵀ Δ Δ' -> Eraseᵀ t t' -> Eraseˢ S S' -> Erase (yes l⊑A) ⟨ Δ , t , S ⟩ ⟨ Δ' , t' , S' ⟩
  ∙ᴸ : ∀ {l⊑A : l ⊑ A} ->  Erase (yes l⊑A) ∙ ∙
  ∙ : ∀ {l⋤A : l ⋤ A} {p} ->  Erase (no l⋤A) p ∙

lift-ε : ∀ {l τ} -> (x : Dec (l ⊑ A)) (s : State l τ) -> Erase x s (ε x s)
lift-ε (yes p) S.⟨ Δ , t , S ⟩ = ⟨ lift-map-εᵀ Δ , lift-εᵀ t , lift-εˢ S ⟩
lift-ε (yes p) S.∙ = ∙ᴸ
lift-ε (no ¬p) p = ∙

unlift-ε : ∀ {l τ} {s s' : State l τ} {x : Dec (l ⊑ A)} -> Erase x s s' -> s' ≡ ε x s
unlift-ε ⟨ Δ , t , S ⟩
  rewrite unlift-map-εᵀ Δ | unlift-εᵀ t | unlift-εˢ S = refl
unlift-ε ∙ = refl
unlift-ε ∙ᴸ = refl

--------------------------------------------------------------------------------

data Eraseᴴ {l π} : (x : Dec (l ⊑ A)) (Δ₁ Δ₂ : Heap l π) -> Set where
  Mapᵀ : ∀ {Δ Δ' : Heap l π} (l⊑A : l ⊑ A) -> EraseMapᵀ Δ Δ' -> Eraseᴴ (yes l⊑A) Δ Δ'
  ∙ : ∀ {Δ : Heap l π} {l⋤A : l ⋤ A} -> Eraseᴴ (no l⋤A) Δ ∙

lift-εᴴ : ∀ {l π} (x : Dec (l ⊑ A)) (Δ : Heap l π) -> Eraseᴴ x Δ (εᴴ x Δ)
lift-εᴴ (yes p) Δ = Mapᵀ p (lift-map-εᵀ Δ)
lift-εᴴ (no ¬p) Δ = ∙

unlift-εᴴ : ∀ {l π} {Δ Δ' : Heap l π} {x : Dec (l ⊑ A)} -> Eraseᴴ x Δ Δ' -> Δ' ≡ εᴴ x Δ
unlift-εᴴ {x = yes .p} (Mapᵀ p x) rewrite unlift-map-εᵀ x = refl
unlift-εᴴ {x = no ¬p} ∙ = refl

--------------------------------------------------------------------------------

data Eraseᴹ {l} : (x : Dec (l ⊑ A)) (M₁ M₂ : Memory l) -> Set where
  Id : ∀ {M : Memory l} (l⊑A : l ⊑ A) -> Eraseᴹ (yes l⊑A) M M
  ∙ : ∀ {M : Memory l} {l⋤A : l ⋤ A} -> Eraseᴹ (no l⋤A) M ∙

lift-εᴹ : ∀ {l} (x : Dec (l ⊑ A)) (M : Memory l) -> Eraseᴹ x M (εᴹ x M)
lift-εᴹ (yes p) M = Id p
lift-εᴹ (no ¬p) M = ∙

unlift-εᴹ : ∀ {l} {M M' : Memory l} {x : Dec (l ⊑ A)} -> Eraseᴹ x M M' -> M' ≡ εᴹ x M
unlift-εᴹ (Id l⊑A) = refl
unlift-εᴹ ∙ = refl

--------------------------------------------------------------------------------

data EraseMapᴴ : ∀ {ls} -> Heaps ls -> Heaps ls -> Set where
  [] : EraseMapᴴ [] []
  _∷_ : ∀ {l π ls} {u : Unique l ls} {Δ₁ Δ₂ : Heap l π} {Γ₁ Γ₂ : Heaps ls}  ->
          Eraseᴴ (l ⊑? A) Δ₁ Δ₂ -> EraseMapᴴ Γ₁ Γ₂ -> EraseMapᴴ (Δ₁ ∷ Γ₁) (Δ₂ ∷ Γ₂)

lift-map-εᴴ : ∀ {ls} (Γ : Heaps ls) -> EraseMapᴴ Γ (map-εᴴ Γ)
lift-map-εᴴ S.[] = []
lift-map-εᴴ (Δ S.∷ Γ) = (lift-εᴴ (_ ⊑? A) Δ) ∷ (lift-map-εᴴ Γ)

unlift-map-εᴴ : ∀ {ls} {Γ Γ' : Heaps ls} -> EraseMapᴴ Γ Γ' -> Γ' ≡ map-εᴴ Γ
unlift-map-εᴴ [] = refl
unlift-map-εᴴ {l ∷ ls} (Δ ∷ Γ) rewrite unlift-εᴴ Δ | unlift-map-εᴴ Γ = refl

--------------------------------------------------------------------------------


data EraseMapᴹ : ∀ {ls} -> Memories ls -> Memories ls -> Set where
  [] : EraseMapᴹ [] []
  _∷_ : ∀ {l ls} {u : Unique l ls} {M₁ M₂ : Memory l} {Ms₁ Ms₂ : Memories ls}  ->
          Eraseᴹ (l ⊑? A) M₁ M₂ -> EraseMapᴹ Ms₁ Ms₂ -> EraseMapᴹ (M₁ ∷ Ms₁) (M₂ ∷ Ms₂)

lift-map-εᴹ : ∀ {ls} (Ms : Memories ls) -> EraseMapᴹ Ms (map-εᴹ Ms)
lift-map-εᴹ S.[] = []
lift-map-εᴹ (M S.∷ Ms) = (lift-εᴹ (_ ⊑? A) M) ∷ (lift-map-εᴹ Ms)

unlift-map-εᴹ : ∀ {ls} {Ms Ms' : Memories ls} -> EraseMapᴹ Ms Ms' -> Ms' ≡ map-εᴹ Ms
unlift-map-εᴹ [] = refl
unlift-map-εᴹ {l ∷ ls} (M ∷ Ms) rewrite unlift-εᴹ M | unlift-map-εᴹ Ms = refl


--------------------------------------------------------------------------------

data Eraseᴾ {l ls τ} : Dec (l ⊑ A) -> Program l ls τ -> Program l ls τ -> Set where
  ⟨_,_,_,_⟩ : ∀ {τ' π Γ Γ' Ms Ms'} {S S' : Stack l π τ' τ} {t t' : Term π τ'} {l⊑A : l ⊑ A} ->
              EraseMapᴹ Ms Ms' -> EraseMapᴴ Γ Γ' -> Eraseᵀ t t' -> Eraseˢ S S' -> Eraseᴾ (yes l⊑A) ⟨ Ms , Γ , t , S ⟩ ⟨ Ms' , Γ' , t' , S' ⟩
  ∙ : ∀ {p} {l⋤A : l ⋤ A} -> Eraseᴾ (no l⋤A) p ∙
  ∙ᴸ : ∀ {l⊑A : l ⊑ A} -> Eraseᴾ (yes l⊑A) ∙ ∙

lift-εᴾ : ∀ {l ls τ} -> (x : Dec (l ⊑ A)) (p : Program l ls τ) -> Eraseᴾ x p (ε₁ᴾ x p)
lift-εᴾ (yes p) S.⟨ Ms , Γ , t , S ⟩ = ⟨ lift-map-εᴹ Ms , (lift-map-εᴴ Γ) , (lift-εᵀ t) , (lift-εˢ S) ⟩
lift-εᴾ (yes p) S.∙ = ∙ᴸ
lift-εᴾ (no ¬p) p = ∙

unlift-εᴾ : ∀ {l ls τ} {p p' : Program l ls τ} {x : Dec (l ⊑ A)} -> Eraseᴾ x p p' -> p' ≡ ε₁ᴾ x p
unlift-εᴾ ⟨ Ms , Γ , t , S ⟩
  rewrite unlift-map-εᴹ Ms | unlift-map-εᴴ Γ | unlift-εᵀ t | unlift-εˢ S = refl
unlift-εᴾ ∙ = refl
unlift-εᴾ ∙ᴸ = refl
