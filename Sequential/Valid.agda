import Lemmas as L₁
import Lattice as L

module Sequential.Valid (𝓛 : L.Lattice) where

import Types as T hiding (wken-∈)
open T 𝓛

import Sequential.Calculus as S renaming (⟨_,_,_⟩ to mkP ; ⟨_,_⟩ to mkTS)
open S 𝓛 hiding (wkenˢ ; wkenᴴ)

open import Data.Nat using (_≤_ ; _<_ ; s≤s ; z≤n ; decTotalOrder)
open import Data.Empty
--import Data.List as LL
open import Data.Product as P
open import Data.Maybe

data ValidAddr {l} : Memory l -> ℕ -> Ty -> Set where
  here : ∀ {τ} {M : Memory l} {c : Cell l τ} -> ValidAddr (c ∷ M) 0 τ
  there : ∀ {n τ τ'} {c : Cell l τ'} {M : Memory l} -> ValidAddr M n τ -> ValidAddr (c ∷ M) (suc n) τ

data IsAddr {π τ} : Term π (Addr τ) -> ℕ -> Set where
  is#[_] : (n : ℕ) -> IsAddr #[ n ] n
  is#[_]ᴰ : (n : ℕ) -> IsAddr #[ n ]ᴰ n

-- A valid term contains only valid references, that contain a valid address.
validᵀ : ∀ {ls τ π} -> Memories ls -> Term π τ -> Set
validᵀ Ms S.（） = ⊤
validᵀ Ms S.True = ⊤
validᵀ Ms S.False = ⊤
validᵀ Ms (S.Id t) = validᵀ Ms t
validᵀ Ms (S.unId t) = validᵀ Ms t
validᵀ Ms (S.Var τ∈π) = ⊤
validᵀ Ms (S.Abs t) = validᵀ Ms t
validᵀ Ms (S.App t t₁) = validᵀ Ms t × validᵀ Ms t₁
validᵀ Ms (S.If t Then t₁ Else t₂) = (validᵀ Ms t) × (validᵀ Ms t₁) × validᵀ Ms t₂
validᵀ Ms (S.Return l t) = validᵀ Ms t
validᵀ Ms (t S.>>= t₁) = (validᵀ Ms t) × (validᵀ Ms t₁)
validᵀ Ms (S.Mac l t) = validᵀ Ms t
validᵀ {ls} {τ = Res .l (Addr τ)} Ms (S.Res l t) = Σ (l ∈ ls) (λ l∈ls -> ∃ (λ n -> IsAddr t n × ValidAddr (lookupˢ l∈ls Ms) n τ))
validᵀ Ms (S.Res l t) = validᵀ Ms t
validᵀ Ms (S.label l⊑h t) = validᵀ Ms t
validᵀ Ms (S.label∙ l⊑h t) = ⊥
validᵀ Ms (S.unlabel l⊑h t) = validᵀ Ms t
validᵀ Ms (S.read x t) = validᵀ Ms t
validᵀ Ms (S.write x t t₁) = (validᵀ Ms t) × (validᵀ Ms t₁)
validᵀ Ms (S.write∙ x t t₁) = ⊥
validᵀ {ls} {π = π} Ms (S.new {h = H} x t) = H ∈ ls × validᵀ Ms t
validᵀ Ms (S.new∙ x t) = ⊥
validᵀ Ms S.#[ x ] = ⊤
validᵀ Ms S.#[ x ]ᴰ = ⊤
validᵀ Ms (S.fork l⊑h t) = validᵀ Ms t
validᵀ Ms (S.fork∙ l⊑h t) = ⊥
validᵀ Ms (S.deepDup t) = validᵀ Ms t
validᵀ Ms S.∙ = ⊥

validᶜ : ∀ {l π ls τ₁ τ₂} -> Memories ls -> Cont l π τ₁ τ₂ -> Set
validᶜ Ms (S.Var τ∈π) = ⊤
validᶜ Ms (S.# τ∈π) = ⊤
validᶜ Ms (S.Then x Else x₁) = (validᵀ Ms x) × validᵀ Ms x₁
validᶜ Ms (S.Bind x) = validᵀ Ms x
validᶜ Ms (S.unlabel p) = ⊤
validᶜ Ms S.unId = ⊤
validᶜ Ms (S.write x τ∈π) = ⊤
validᶜ Ms (S.write∙ x τ∈π) = ⊥
validᶜ Ms (S.read x) = ⊤

validˢ : ∀ {l  π ls τ₁ τ₂} -> Memories ls -> Stack l π τ₁ τ₂ -> Set
validˢ Ms S.[] = ⊤
validˢ Ms (C S.∷ S) = validᶜ Ms C × validˢ Ms S
validˢ Ms S.∙ = ⊥

validᴹᵀ : ∀ {π τ ls} -> Memories ls -> Maybe (Term π τ) -> Set
validᴹᵀ Ms (just x) = validᵀ Ms x
validᴹᵀ Ms nothing = ⊤


validᴴ : ∀ {l π ls} -> Memories ls -> Heap l π -> Set
validᴴ Ms S.[] = ⊤
validᴴ Ms (mt S.∷ Δ) = validᴹᵀ Ms mt × validᴴ Ms Δ
validᴴ Ms S.∙ = ⊥

validᴹ : ∀ {l} -> (M : Memory l) -> Set
validᴹ S.[] = ⊤
validᴹ (cᴸ S.∷ M) = validᴹ M
validᴹ S.∙ = ⊥

validᴴ∙ : ∀ {l ls} (Ms : Memories ls) (H : Heap∙ l) -> Set
validᴴ∙ Ms S.⟨ Δ ⟩ = validᴴ Ms Δ
validᴴ∙ Ms S.∙ = ⊥

valid-state : ∀ {l ls τ} -> Memories ls -> State l τ -> Set
valid-state Ms (S.mkP Δ t S) = validᴴ Ms Δ × validᵀ Ms t × validˢ Ms S
valid-state _ S.∙ = ⊥

map-validᴹ : ∀ {ls} -> Memories ls -> Set
map-validᴹ S.[] = ⊤
map-validᴹ (M S.∷ Ms) = validᴹ M × map-validᴹ Ms

map-validᴴ : ∀ {ls₁ ls₂} -> Memories ls₁ -> Heaps ls₂ -> Set
map-validᴴ Ms S.[] = ⊤
map-validᴴ Ms (x S.∷ Γ) = validᴴ∙ Ms x × map-validᴴ Ms Γ

validTS∙ : ∀ {l τ ls} -> Memories ls -> TS∙ l τ -> Set
validTS∙ Ms (mkTS t S) = validᵀ Ms t × validˢ Ms S
validTS∙ _ S.∙ = ⊥

validᴾ : ∀ {l ls τ} -> Program l ls τ -> Set
validᴾ (S.mkP Ms Γ TS ) = map-validᴹ Ms × map-validᴴ Ms Γ × validTS∙ Ms TS

valid-𝓛 : (ls : List Label) -> Set
valid-𝓛 [] = ⊤
valid-𝓛 (l ∷ ls) = Unique l ls × valid-𝓛 ls

--------------------------------------------------------------------------------

open import Relation.Binary as B
open B.DecTotalOrder Data.Nat.decTotalOrder hiding (_≤_) renaming (trans to trans-≤ ; refl to refl-≤)

open import Function

data _⊆ᴹ_ {l : Label} : Memory l -> Memory l -> Set where
  ∙ : ∙ ⊆ᴹ ∙
  nil : ∀ {M} -> [] ⊆ᴹ M
  cons : ∀ {τ M₁ M₂} {c₁ c₂ : Cell l τ} -> M₁ ⊆ᴹ M₂ -> (c₁ ∷ M₁) ⊆ᴹ (c₂ ∷ M₂)

data _⊆ˢ_ : ∀ {ls₁ ls₂} -> Memories ls₁ -> Memories ls₂ -> Set where
  nil : [] ⊆ˢ []
  cons : ∀ {ls₁ ls₂ l} {u₁ : Unique l ls₁} {u₂ : Unique l ls₂} {Ms₁ : Memories ls₁} {Ms₂ : Memories ls₂} {M₁ M₂ : Memory l}
         -> M₁ ⊆ᴹ M₂ -> Ms₁ ⊆ˢ Ms₂ -> (M₁ ∷ Ms₁) ⊆ˢ (M₂ ∷ Ms₂)
  drop : ∀ {ls₁ ls₂ l} {u₂ : Unique l ls₂} {Ms₁ : Memories ls₁} {Ms₂ : Memories ls₂} {M : Memory l}
           -> Ms₁ ⊆ˢ Ms₂ -> Ms₁ ⊆ˢ (M ∷ Ms₂)

refl-⊆ᴹ : ∀ {l} {M : Memory l} -> M ⊆ᴹ M
refl-⊆ᴹ {M = S.[]} = nil
refl-⊆ᴹ {M = cᴸ S.∷ M} = cons refl-⊆ᴹ
refl-⊆ᴹ {M = S.∙} = ∙

refl-⊆ˢ : ∀ {ls} {Ms : Memories ls} -> Ms ⊆ˢ Ms
refl-⊆ˢ {Ms = S.[]} = nil
refl-⊆ˢ {Ms = x S.∷ Ms} = cons refl-⊆ᴹ refl-⊆ˢ

open import Function

-- wken-Addr

wken-Addr : ∀ {n l τ} {M₁ M₂ : Memory l} -> M₁ ⊆ᴹ M₂ -> ValidAddr M₁ n τ -> ValidAddr M₂ n τ
wken-Addr (cons x) here = here
wken-Addr (cons x) (there y) = there (wken-Addr x y)

⊆ˢ-⊆ : ∀ {ls₁ ls₂} {Ms₁ : Memories ls₁} {Ms₂ : Memories ls₂} -> Ms₁ ⊆ˢ Ms₂ -> ls₁ ⊆ ls₂
⊆ˢ-⊆ nil = T.base
⊆ˢ-⊆ (cons x x₁) = T.cons (⊆ˢ-⊆ x₁)
⊆ˢ-⊆ (drop x) = T.drop (⊆ˢ-⊆ x)


wken-lookupˢ : ∀ {l ls₁ ls₂} {Ms₁ : Memories ls₁} {Ms₂ : Memories ls₂} -> (Ms₁⊆Ms₂ : Ms₁ ⊆ˢ Ms₂) (l∈ls : l ∈ ls₁)
               -> lookupˢ l∈ls Ms₁ ⊆ᴹ lookupˢ (L₁.wken-∈ (⊆ˢ-⊆ Ms₁⊆Ms₂) l∈ls) Ms₂
wken-lookupˢ (cons x x₁) L₁.here = x
wken-lookupˢ (cons x₁ x) (L₁.there l∈ls) = wken-lookupˢ x l∈ls
wken-lookupˢ (drop x) y = wken-lookupˢ x y

wkenᵀ : ∀ {π τ ls₁ ls₂} {Ms₁ : Memories ls₁} {Ms₂ : Memories ls₂} -> Ms₁ ⊆ˢ Ms₂ -> (t : Term π τ) -> validᵀ Ms₁ t -> validᵀ Ms₂ t
wkenᵀ Ms₁⊆Ms₂ S.（） ok = T.tt
wkenᵀ Ms₁⊆Ms₂ S.True ok = T.tt
wkenᵀ Ms₁⊆Ms₂ S.False ok = T.tt
wkenᵀ Ms₁⊆Ms₂ (S.Id t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ Ms₁⊆Ms₂ (S.unId t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ Ms₁⊆Ms₂ (S.Var τ∈π) ok = T.tt
wkenᵀ Ms₁⊆Ms₂ (S.Abs t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ Ms₁⊆Ms₂ (S.App t t₁) (proj₁ , proj₂) = (wkenᵀ Ms₁⊆Ms₂ t proj₁) , (wkenᵀ Ms₁⊆Ms₂ t₁ proj₂)
wkenᵀ Ms₁⊆Ms₂ (S.If t Then t₁ Else t₂) (proj₁ , proj₂ , proj₃) = (wkenᵀ Ms₁⊆Ms₂ t proj₁) , ((wkenᵀ Ms₁⊆Ms₂ t₁ proj₂) , (wkenᵀ Ms₁⊆Ms₂ t₂ proj₃))
wkenᵀ Ms₁⊆Ms₂ (S.Return l₁ t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ Ms₁⊆Ms₂ (t S.>>= t₁) (proj₁ , proj₂) = (wkenᵀ Ms₁⊆Ms₂ t proj₁) , (wkenᵀ Ms₁⊆Ms₂ t₁ proj₂)
wkenᵀ Ms₁⊆Ms₂ (S.Mac l₁ t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ {τ = T.Res .l₁ T.（）} Ms₁⊆Ms₂ (S.Res l₁ t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ {τ = T.Res .l₁ T.Bool} Ms₁⊆Ms₂ (S.Res l₁ t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ {τ = T.Res .l₁ (τ T.=> τ₁)} Ms₁⊆Ms₂ (S.Res l₁ t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ {τ = T.Res .l₂ (T.Mac l₁ τ)} Ms₁⊆Ms₂ (S.Res l₂ t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ {τ = T.Res .l₂ (T.Res l₁ τ)} Ms₁⊆Ms₂ (S.Res l₂ t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ {τ = T.Res .l₁ (T.Id τ)} Ms₁⊆Ms₂ (S.Res l₁ t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ {τ = T.Res .l₁ (T.Addr τ)} Ms₁⊆Ms₂ (S.Res l₁ t) (l∈ls₁ , n , isA , isV)
  = (L₁.wken-∈ (⊆ˢ-⊆ Ms₁⊆Ms₂) l∈ls₁) , (n , (isA , (wken-Addr (wken-lookupˢ Ms₁⊆Ms₂ l∈ls₁) isV)))
wkenᵀ Ms₁⊆Ms₂ (S.label l⊑h t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ Ms₁⊆Ms₂ (S.label∙ l⊑h t) ()
wkenᵀ Ms₁⊆Ms₂ (S.unlabel l⊑h t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ Ms₁⊆Ms₂ (S.read x t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ Ms₁⊆Ms₂ (S.write x t t₁) (proj₁ , proj₂) = (wkenᵀ Ms₁⊆Ms₂ t proj₁) , (wkenᵀ Ms₁⊆Ms₂ t₁ proj₂)
wkenᵀ Ms₁⊆Ms₂ (S.write∙ x t t₁) ()
wkenᵀ Ms₁⊆Ms₂ (S.new x t) (h∈ls , ok₃) = L₁.wken-∈ (⊆ˢ-⊆ Ms₁⊆Ms₂) h∈ls , (wkenᵀ Ms₁⊆Ms₂ t ok₃)
wkenᵀ Ms₁⊆Ms₂ (S.new∙ x t) ()
wkenᵀ Ms₁⊆Ms₂ S.#[ x ] ok = T.tt
wkenᵀ Ms₁⊆Ms₂ S.#[ x ]ᴰ ok = T.tt
wkenᵀ Ms₁⊆Ms₂ (S.fork l⊑h t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ Ms₁⊆Ms₂ (S.fork∙ l⊑h t) ()
wkenᵀ Ms₁⊆Ms₂ (S.deepDup t) ok = wkenᵀ Ms₁⊆Ms₂ t ok
wkenᵀ Ms₁⊆Ms₂ S.∙ ()

wkenᴹᵀ : ∀ {ls₁ ls₂ π τ} {Ms₁ : Memories ls₁} {Ms₂ : Memories ls₂} {mt : Maybe (Term π τ)} -> Ms₁ ⊆ˢ Ms₂ -> validᴹᵀ Ms₁ mt -> validᴹᵀ Ms₂ mt
wkenᴹᵀ {mt = just x} Ms₁⊆Ms₂ v = wkenᵀ Ms₁⊆Ms₂ x v
wkenᴹᵀ {mt = nothing} Ms₁⊆Ms₂ v = T.tt

wkenᴴ : ∀ {l π ls₁ ls₂} {Δ : Heap l π} {Ms₁ : Memories ls₁} {Ms₂ : Memories ls₂} -> Ms₁ ⊆ˢ Ms₂ -> validᴴ Ms₁ Δ -> validᴴ Ms₂ Δ
wkenᴴ {Δ = S.[]} Ms₁⊆Ms₂ Δᴱ = tt
wkenᴴ {Δ = mt S.∷ Δ} Ms₁⊆Ms₂  (mtⱽ  , Δᴱ) = wkenᴹᵀ {mt = mt} Ms₁⊆Ms₂ mtⱽ  , wkenᴴ {Δ = Δ} Ms₁⊆Ms₂ Δᴱ
wkenᴴ {Δ = S.∙} _ ()

wkenˢ : ∀ {ls₁ ls₂ l π τ₁ τ₂} {S : Stack l π τ₁ τ₂} {Ms₁ : Memories ls₁} {Ms₂ : Memories ls₂} -> Ms₁ ⊆ˢ Ms₂ -> validˢ Ms₁ S -> validˢ Ms₂ S
wkenˢ {S = S} Ms₁⊆Ms₂ Sᵛ = {!!}

-- wkenᴹ : ∀ {l} {M₁ M₂ : Memory l} -> M₁ ⊆ᴹ M₂ -> validᴹ M₁ -> validᴹ M₂
-- wkenᴹ ∙ ()
-- wkenᴹ nil isV = {!!}
-- wkenᴹ (cons M₁⊆M₂) isV = {!!}

wkenᴴ∙ : ∀ {l ls₁ ls₂} {Ms₁ : Memories ls₁} {Ms₂ : Memories ls₂} {H : Heap∙ l} -> Ms₁ ⊆ˢ Ms₂ -> validᴴ∙ Ms₁ H -> validᴴ∙ Ms₂ H
wkenᴴ∙ {H = S.⟨ Δ ⟩} Ms₁⊆Ms₂ x = wkenᴴ {Δ = Δ} Ms₁⊆Ms₂ x
wkenᴴ∙ {H = S.∙} _ ()

-- wkenᴴ : ∀ {ls₁ ls₂} {Ms₁ : Heaps ls₁} {Ms₂ : Heaps ls₂} -> Ms₁ ⊆ˢ Ms₂ -> validᴴ Ms₁ -> validᴴ Ms₂
-- wkenᴴ nil x = tt
-- wkenᴴ (cons x x₁) (proj₁ , proj₂) = (wkenᴴ₂' (cons x x₁) x proj₁) , wkenᴴ x₁ proj₂
-- wkenᴴ {Ms₁ = Ms₁} (drop x) x₁ = {!!} , (wkenᴴ x x₁)

map-wkenᴴ : ∀ {ls ls₁ ls₂} {Ms₁ : Memories ls₁} {Ms₂ : Memories ls₂} {Γ : Heaps ls} -> Ms₁ ⊆ˢ Ms₂ -> map-validᴴ Ms₁ Γ -> map-validᴴ Ms₂ Γ
map-wkenᴴ {Γ = S.[]} Ms₁⊆Ms₂ v = T.tt
map-wkenᴴ {Γ = H S.∷ Γ} Ms₁⊆Ms₂ v = (wkenᴴ∙ {H = H} Ms₁⊆Ms₂ (proj₁ v)) , (map-wkenᴴ Ms₁⊆Ms₂ (proj₂ v))



--------------------------------------------------------------------------------
-- Initial Valid configurations

-- TODO move to different module?

Ms₀ : {{ls : List Label}} {{us : valid-𝓛 ls}} -> Memories ls
Ms₀ {{[]}} {{_}} = []
Ms₀ {{l ∷ ls}} {{u , us}} = [] ∷ Ms₀

map-validᴹ₀ : ∀ {ls : List Label} {{us : valid-𝓛 ls}} -> map-validᴹ (Ms₀ {{ls}})
map-validᴹ₀ {T.[]} = tt
map-validᴹ₀ {x T.∷ ls} = tt , map-validᴹ₀

Γ₀ : {{ls  : List Label}} {{us : valid-𝓛 ls}} -> Heaps ls
Γ₀ {{T.[]}} {{T.tt}} = S.[]
Γ₀ {{x T.∷ ls}} {{proj₁ , proj₂}} = ⟨ [] ⟩ S.∷ Γ₀

map-validᴴ₀ : ∀ {ls : List Label} {{us : valid-𝓛 ls}} -> map-validᴴ (Ms₀ {{ls}}) (Γ₀ {{ls}})
map-validᴴ₀ {T.[]} = T.tt
map-validᴴ₀ {_ T.∷ ls} {{_ , us}} = T.tt , map-wkenᴴ (drop refl-⊆ˢ) (map-validᴴ₀ {ls})

S₀ : ∀ {l τ} -> Stack l [] τ τ
S₀ = []

validˢ₀ : ∀ {l τ ls} -> (Ms : Memories ls) -> validˢ Ms (S₀ {l} {τ})
validˢ₀ Ms = tt

TS₀ : ∀ {l τ} -> Term [] τ -> TS∙ l τ
TS₀ t = mkTS t S₀

P₀ : ∀ {ls l τ} {{us : valid-𝓛 ls}} -> Term [] τ -> Program l ls τ
P₀ {{us = us}} t = mkP Ms₀ Γ₀ (TS₀ t)

-- Initial configurations are valid given a valid initial term,
-- i.e. it does not have no free variables and references.
validᴾ₀ : ∀ {τ l ls} {t : Term [] τ} {{us : valid-𝓛 ls}} -> validᵀ (Ms₀ {{ls}}) t -> validᴾ (P₀ {l = l} {{us}} t)
validᴾ₀ vᵀ = map-validᴹ₀ , (map-validᴴ₀ , (vᵀ , tt))

valid-∈ᴱ : ∀ {l ls₁ ls₂} {Ms : Memories ls₁} {Γ : Heaps ls₂} {Δ : Heap∙ l} -> map-validᴴ Ms Γ -> l ↦ Δ ∈ᴱ Γ -> validᴴ∙ Ms Δ
valid-∈ᴱ (proj₁ , proj₂) S.here = proj₁
valid-∈ᴱ (proj₁ , proj₂) (S.there y₁) = valid-∈ᴱ proj₂ y₁

--------------------------------------------------------------------------------

import Sequential.Semantics as SS
open SS 𝓛

open import Relation.Binary.PropositionalEquality hiding (subst)

-- valid-memberᴴ : ∀ {l ls} {Ms : Heaps ls} {H : Heap l} -> validᴴ Ms -> l ↦ H ∈ᴴ Ms -> validᴴ₂ Ms H
-- valid-memberᴴ (proj₁ , proj₂) S.here = proj₁
-- valid-memberᴴ (proj₁ , proj₂) (S.there l∈Ms) = wkenᴴ₂ (drop refl-⊆ˢ) (valid-memberᴴ proj₂ l∈Ms)

-- valid-memberᴱ : ∀ {l τ π₁ π₂ ls} {Ms : Memories ls} {Δ : Heap l π₁} {t : Term π₂ τ} {x : τ ∈⟨ l ⟩ᴿ π₁} -> validᴴ Ms Δ -> x ↦ t ∈ᴴ Δ -> validᵀ Ms t
-- valid-memberᴱ {x = T.⟪ τ∈π ⟫} = {!!} -- aux
--   -- where aux : ∀ {l τ π₁ π₂ ls} {Ms : Memories ls} {Δ : Heap l π₁} {t : Term π₂ τ} {x : τ ∈⟨ l ⟩ π₁} -> validᴴ Ms Δ -> Memberᴴ (just t) x Δ -> validᵀ Ms t
--   --       aux (proj₁ , proj₂) S.here = proj₁
--   --       aux {Δ = just x S.∷ Δ} (_ , Δⱽ) (S.there t∈Δ) = aux Δⱽ t∈Δ
--   --       aux {Δ = nothing S.∷ Δ} Δⱽ (S.there t∈Δ) = aux Δⱽ t∈Δ

-- valid-newᴹ : ∀ {l τ} (c : Cell l τ) (M : Memory l) -> validᴹ M -> validᴹ (newᴹ c M) × (lengthᴹ M ≤ lengthᴹ (newᴹ c M))
-- valid-newᴹ c S.[] ok-M = tt , z≤n
-- valid-newᴹ c (cᴸ S.∷ M) ok-M = P.map id s≤s (valid-newᴹ c M ok-M)
-- valid-newᴹ c S.∙ ()

-- valid-writeᴹ : ∀ {l τ} {c : Cell l τ} {M M' : Memory l} {n} -> M' ≔ M [ n ↦ c ]ᴹ -> validᴹ M -> validᴹ M' × lengthᴹ M ≤ lengthᴹ M'
-- valid-writeᴹ {M = _ ∷ M} S.here Mⱽ = Mⱽ , s≤s refl-≤
-- valid-writeᴹ (S.there u) Mⱽ = P.map id s≤s (valid-writeᴹ u Mⱽ)

-- valid-new-Addr : ∀ {l ls τ} {Ms Ms' : Memories ls} {M : Memory l} -> validᴹ M -> (c : Cell l τ) ->
--               (uˢ : Ms' ≔ Ms [ l ↦ newᴹ c M ]ˢ) -> validAddr (lookupˢ (updateˢ-∈ uˢ) Ms') (lengthᴹ M)
-- valid-new-Addr {M = M} Mᵛ c (S.there uᴴ) = valid-new-Addr {M = M} Mᵛ c uᴴ
-- valid-new-Addr {M = M} Mᵛ c S.here = aux {c = c} {M = M} Mᵛ
--  where aux : ∀ {l τ} {c : Cell l τ} {M : Memory l} -> validᴹ M -> lengthᴹ M < lengthᴹ (newᴹ c M)
--        aux {M = S.[]} M≠∙ = s≤s z≤n
--        aux {M = cᴸ S.∷ M} M≠∙ = s≤s (aux {M = M} M≠∙)
--        aux {M = S.∙} ()


-- update-valid-Addr : ∀ {l} {M₁ M₂ : Memory l} {n : ℕ} -> validAddr M₁ n ->
--                     validᴹ M₁ -> validᴹ M₂ -> lengthᴹ M₁ ≤ lengthᴹ M₂ -> validAddr M₂ n
-- update-valid-Addr {_} {M₁} {M₂} aⱽ Mⱽ₁ Mⱽ₂ M₁≤M₂ = trans-≤ aⱽ M₁≤M₂

-- newᴹ-≤ : ∀ {l τ} (M : Memory l) (c : Cell l τ) -> lengthᴹ M ≤ lengthᴹ (newᴹ c M)
-- newᴹ-≤ S.[] c = z≤n
-- newᴹ-≤ (cᴸ S.∷ M) c = s≤s (newᴹ-≤ M c)
-- newᴹ-≤ S.∙ c = refl-≤

-- -- newᴴ-≤ : ∀ {l ls} {M₁ M₂ : Heaps ls} {M₁ M₂ : Memory l} {Δ : Heap l π} -> l ↦ ⟨ Δ ⟩ ∈ᴱ Ms₁ -> Ms₂ ≔ Ms₁ [ l ↦ ⟨ Δ ⟩ ]ᴱ ->
-- --            (lengthᴹ M₁) ≤ (lengthᴹ M₂) ->
-- --           (∀ {l} -> (l∈ls : l ∈ ls) ->
-- --              lengthᴹ (lookupˢ l∈ls Ms₁) ≤ lengthᴹ (lookupˢ l∈ls Ms₂))
-- -- newᴴ-≤ = ?
-- -- S.here S.here M₁≤M₂ T.here = M₁≤M₂
-- -- newᴴ-≤ S.here S.here _ (T.there l∈ls) = refl-≤
-- -- newᴴ-≤ {l} S.here (S.there {u = u} y) = ⊥-elim (∈-not-unique (updateᴱ-∈ y) u)
-- -- newᴴ-≤ (S.there {u = u} x) S.here = ⊥-elim (∈-not-unique (memberᴱ-∈ x) u)
-- -- newᴴ-≤ {Ms₁ = S.⟨ x , x₁ ⟩ S.∷ Ms₁} (S.there x₂) (S.there y) _ T.here = refl-≤
-- -- newᴴ-≤ {Ms₁ = S.∙ S.∷ Ms₁} (S.there x) (S.there y) _ T.here = refl-≤
-- -- newᴴ-≤ (S.there x) (S.there y) M₁≤M₂ (T.there z) = newᴴ-≤ x y M₁≤M₂ z

-- update-validᵀ : ∀ {l π  τ ls} {Ms₁ Ms₂ : Memories ls} {M₁ M₂ : Memory l} ->
--                 l ↦ M₁ ∈ˢ Ms₁ ->
--                 Ms₂ ≔ Ms₁ [ l ↦ M₁ ]ˢ -> (lengthᴹ M₁) ≤ (lengthᴹ M₂) -> (t : Term π τ) -> validᵀ Ms₁ t -> validᵀ Ms₂ t
-- update-validᵀ l∈Ms u M₁≤M₂ S.（） tⱽ = tt
-- update-validᵀ l∈Ms u M₁≤M₂ S.True tⱽ = tt
-- update-validᵀ l∈Ms u M₁≤M₂ S.False tⱽ = tt
-- update-validᵀ l∈Ms u M₁≤M₂ (S.Id t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (S.unId t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (S.Var τ∈π) tⱽ = tt
-- update-validᵀ l∈Ms u M₁≤M₂ (S.Abs t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (S.App t t₁) (tⱽ , t₁ⱽ) = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ , update-validᵀ l∈Ms u M₁≤M₂ t₁ t₁ⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (S.If t Then t₁ Else t₂) (tⱽ , t₁ⱽ , t₂ⱽ)
--   = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ , update-validᵀ l∈Ms u M₁≤M₂ t₁ t₁ⱽ , update-validᵀ l∈Ms u M₁≤M₂ t₂ t₂ⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (S.Return l₁ t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (t S.>>= t₁) (tⱽ , t₁ⱽ) = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ , update-validᵀ l∈Ms u M₁≤M₂ t₁ t₁ⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (S.Mac l₁ t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ {τ = Res .l₁ （）} l∈Ms u M₁≤M₂ (S.Res l₁ t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ {τ = Res .l₁ Bool} l∈Ms u M₁≤M₂ (S.Res l₁ t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ {τ = Res .l₁ (τ => τ₁)} l∈Ms u M₁≤M₂ (S.Res l₁ t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ {τ = Res .l₂ (Mac l₁ τ)} l∈Ms u M₁≤M₂ (S.Res l₂ t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ {τ = Res .l₂ (Res l₁ τ)} l∈Ms u M₁≤M₂ (S.Res l₂ t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ {τ = Res .l₁ (Id τ)} l∈Ms u M₁≤M₂ (S.Res l₁ t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ {τ = Res .l₁ Addr} l∈Ms u M₁≤M₂ (S.Res l₁ (S.unId t)) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ {τ = Res .l₁ Addr} l∈Ms u M₁≤M₂ (S.Res l₁ (S.Var τ∈π)) tⱽ = tt
-- update-validᵀ {τ = Res .l₁ Addr} l∈Ms u M₁≤M₂ (S.Res l₁ (S.App t t₁)) (tⱽ , t₁ⱽ) = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ , update-validᵀ l∈Ms u M₁≤M₂ t₁ t₁ⱽ
-- update-validᵀ {τ = Res .l₁ Addr} l∈Ms u M₁≤M₂ (S.Res l₁ (S.If t Then t₁ Else t₂)) (tⱽ , t₁ⱽ , t₂ⱽ)
--   = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ , update-validᵀ l∈Ms u M₁≤M₂ t₁ t₁ⱽ , update-validᵀ l∈Ms u M₁≤M₂ t₂ t₂ⱽ
-- update-validᵀ {τ = Res .l₁ Addr} l∈Ms u M₁≤M₂ (S.Res l₁ S.#[ n ]) (l∈ls , tⱽ) = l∈ls , trans-≤ tⱽ {!!} -- (newᴴ-≤ l∈Ms u M₁≤M₂ l∈ls)
-- update-validᵀ {τ = Res .l₁ Addr} l∈Ms u M₁≤M₂ (S.Res l₁ S.#[ n ]ᴰ) (l∈ls , tⱽ) = l∈ls , trans-≤ tⱽ {!!} -- (newᴴ-≤ l∈Ms u M₁≤M₂ l∈ls)
-- update-validᵀ {τ = Res .l₁ Addr} l∈Ms u M₁≤M₂ (S.Res l₁ (S.deepDup t)) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ {τ = Res .l₁ Addr} l∈Ms u M₁≤M₂ (S.Res l₁ S.∙) ()
-- update-validᵀ l∈Ms u M₁≤M₂ (S.label l⊑h t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (S.label∙ l⊑h t) ()
-- update-validᵀ l∈Ms u M₁≤M₂ (S.unlabel l⊑h t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (S.read x t) tⱽ =  update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (S.write x t t₁) (tⱽ , t₁ⱽ) = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ ,  update-validᵀ l∈Ms u M₁≤M₂ t₁ t₁ⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (S.write∙ x t t₁) ()
-- update-validᵀ l∈Ms u M₁≤M₂ (S.new x t) ok = {!!} -- (ok , tⱽ) = {!!} -- ok , update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (S.new∙ x t) ()
-- update-validᵀ l∈Ms u M₁≤M₂ S.#[ x ] tⱽ = tt
-- update-validᵀ l∈Ms u M₁≤M₂ S.#[ x ]ᴰ tⱽ = tt
-- update-validᵀ l∈Ms u M₁≤M₂ (S.fork l⊑h t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ (S.fork∙ l⊑h t) ()
-- update-validᵀ l∈Ms u M₁≤M₂ (S.deepDup t) tⱽ = update-validᵀ l∈Ms u M₁≤M₂ t tⱽ
-- update-validᵀ l∈Ms u M₁≤M₂ S.∙ ()

-- update-validᶜ : ∀ {l π l' ls τ₁ τ₂} {C : Cont l' π τ₁ τ₂} {Ms₁ Ms₂ : Memories ls} {M₁ M₂ : Memory l} ->
--                 l ↦ M₁ ∈ˢ Ms₁ ->
--                 Ms₂ ≔ Ms₁ [ l ↦ M₂ ]ˢ -> (lengthᴹ M₁) ≤ (lengthᴹ M₂)
--                 -> validᶜ Ms₁ C -> validᶜ Ms₂ C
-- update-validᶜ {C = S.Var τ∈π} l∈Ms u M₁≤M₂ Cⱽ = tt
-- update-validᶜ {C = S.# τ∈π} l∈Ms u M₁≤M₂ Cⱽ = tt
-- update-validᶜ {C = S.Then t₁ Else t₂} l∈Ms u M₁≤M₂ (proj₁ , proj₂) = {!!} -- (update-validᵀ l∈Ms u M₁≤M₂ t₁ proj₁) , (update-validᵀ l∈Ms u M₁≤M₂ t₂ proj₂)
-- update-validᶜ {C = S.Bind t} l∈Ms u M₁≤M₂ Cⱽ = {!!} -- update-validᵀ l∈Ms u M₁≤M₂ t Cⱽ
-- update-validᶜ {C = S.unlabel p} l∈Ms u M₁≤M₂ Cⱽ = tt
-- update-validᶜ {C = S.unId} l∈Ms u M₁≤M₂ Cⱽ = tt
-- update-validᶜ {C = S.write x τ∈π} l∈Ms u M₁≤M₂ Cⱽ = tt
-- update-validᶜ {C = S.write∙ x τ∈π} l∈Ms u M₁≤M₂ ()
-- update-validᶜ {C = S.read x} l∈Ms u M₁≤M₂ Cⱽ = tt

-- update-validˢ : ∀ {l π l' ls τ₁ τ₂} {S : Stack l' π τ₁ τ₂} {Ms Ms' : Memories ls} {M₁ M₂ : Memory l} ->
--                   l ↦ M₁ ∈ˢ Ms ->
--                   Ms' ≔ Ms [ l ↦ M₂ ]ˢ -> (lengthᴹ M₁) ≤ (lengthᴹ M₂)
--                 -> validˢ Ms S -> validˢ Ms' S
-- update-validˢ {S = S.[]} l∈Ms u M₁≤M₂ Sⱽ = tt
-- update-validˢ {S = C S.∷ S} l∈Ms u M₁≤M₂ (Cⱽ , Sⱽ) = update-validᶜ {C = C} l∈Ms u M₁≤M₂ Cⱽ , (update-validˢ l∈Ms u M₁≤M₂ Sⱽ)
-- update-validˢ {S = S.∙} l∈Ms u M₁≤M₂ ()

-- -- update-⊆ˢ : ∀ {l π ls} {Ms Ms' : Heaps ls} {Δ : Heap l π} {M₁ M₂ : Memory l} ->
-- --               l ↦ ⟨ Δ ⟩ ∈ᴴ Ms ->
-- --                 Ms' ≔ Ms [ l ↦ ⟨ Δ ⟩ ]ᴴ ->
-- --                 (lengthᴹ M₁) ≤ (lengthᴹ M₂) ->
-- --                 Ms ⊆ˢ Ms'
-- -- update-⊆ˢ S.here S.here M₁≤M₂ = ?
-- -- cons (⟨ M₁≤M₂ , refl-⊆ᴱ ⟩) refl-⊆ˢ
-- -- update-⊆ˢ S.here (S.there {u = u} uᴴ) M₁≤M₂ = ⊥-elim (∈-not-unique (update-∈ uᴴ) u)
-- -- update-⊆ˢ (S.there {u = u} l∈Δ) S.here M₁≤M₂ = ⊥-elim (∈-not-unique (member-∈ l∈Δ) u)
-- -- update-⊆ˢ (S.there l∈Δ) (S.there u₁) M₁≤M₂ = cons refl-⊆'ᴴ (update-⊆ˢ l∈Δ u₁ M₁≤M₂)

-- -- update-validᴴ : ∀ {l π ls} {Ms Ms' : Heaps ls} {Δ : Heap l π} {M₁ M₂ : Memory l} ->
-- --                   l ↦ ⟨ Δ ⟩ ∈ᴴ Ms ->
-- --                   Ms' ≔ Ms [ l ↦ ⟨ Δ ⟩ ]ᴴ ->
-- --                   (lengthᴹ M₁) ≤ (lengthᴹ M₂) ->
-- --                   validᴹ M₂ ->
-- --                   validᴴ Ms -> validᴴ Ms'
-- -- update-validᴴ = ?
-- -- {Ms = _ ∷ Ms} {Δ = Δ} {M₁} {M₂} = ?
-- -- S.here S.here M₁≤M₂ M₂ⱽ ((proj₁ , proj₂) , proj₃)
-- --   = (M₂ⱽ , wkenᴱ {Δ = Δ} (cons (⟨ M₁≤M₂ , refl-⊆ᴱ ⟩) refl-⊆ˢ) proj₂ ) , proj₃
-- -- update-validᴴ {Ms = S._∷_ {{u}} _ _} S.here (S.there b) M₁≤M₂ M₂ⱽ Msⱽ = ⊥-elim (∈-not-unique (update-∈ b) u)
-- -- update-validᴴ {Ms = S._∷_ {{u}} _ _} (S.there a) S.here M₁≤M₂ M₂ⱽ Msⱽ = ⊥-elim (∈-not-unique (member-∈ a) u)
-- -- update-validᴴ {Ms = S.⟨ M' , Δ' ⟩ S.∷ Ms} (S.there a) (S.there b) M₁≤M₂ M₂ⱽ ((proj₁ , proj₂) , proj₃)
-- --   = (proj₁ , wkenᴱ {Δ = Δ'} (update-⊆ˢ (there a) (there b) M₁≤M₂) proj₂) , (update-validᴴ a b M₁≤M₂ M₂ⱽ proj₃)
-- -- update-validᴴ {Ms = S.∙ S.∷ Ms} (S.there a) (S.there b) M₁≤M₂ M₂ⱽ (() , proj₂)



-- -- This does not go because I need to restrict Ms to get to the memory where the update occurs
-- -- which may make some references invalid.
-- -- update-valid'ᴴ : ∀ {l π₁ π₂ ls ls'} {Ms Ms' : Heaps ls} {Ms'' : Heaps ls'} {Δ₁ : Heap l π₁} {Δ₂ : Heap l π₂} {M : Memory l} ->
-- --                   l ↦ ⟨ M , Δ₁ ⟩ ∈ᴴ Ms ->
-- --                   Ms' ≔ Ms [ l ↦ ⟨ M , Δ₂ ⟩ ]ᴴ ->
-- --                   validᴴ Ms -> Ms ⊆ˢ Ms'' -> validᴴ Ms'' Δ₂ -> validᴴ Ms'
-- -- update-valid'ᴴ S.here S.here Msⱽ Ms⊆ˢMs'' Δ₂ⱽ = {!!}
-- -- update-valid'ᴴ S.here (S.there {u = u} uᴴ) Msⱽ _ Δ₂ⱽ = ⊥-elim (∈-not-unique (update-∈ uᴴ) u)
-- -- update-valid'ᴴ (S.there {u = u} l∈Ms) S.here Msⱽ _ Δ₂ⱽ = ⊥-elim (∈-not-unique (member-∈ l∈Ms) u)
-- -- update-valid'ᴴ {Ms = S.⟨ x , x₁ ⟩ S.∷ Ms} (S.there l∈Ms) (S.there u₁) (proj₁ , proj₂) Ms⊆ˢMs'' Δ₂ⱽ = {!!} , (update-valid'ᴴ l∈Ms u₁ proj₂ {!drop ?!}  Δ₂ⱽ)
-- -- update-valid'ᴴ {Ms = S.∙ S.∷ Ms} (S.there l∈Ms) (S.there u₁) (() , proj₂) Δ₂ⱽ

valid-subst : ∀ {τ τ' π ls} {Ms : Memories ls} {t₁ : Term π τ} {t₂ : Term (τ ∷ π) τ'} -> validᵀ Ms t₁ -> validᵀ Ms t₂ -> validᵀ Ms (subst t₁ t₂)
valid-subst = {!!}

valid-wkenᵀ : ∀ {τ π₁ π₂ ls} {Ms : Memories ls} {{t : Term π₁ τ}} -> validᵀ Ms t -> (π₁⊆π₂ : π₁ ⊆ π₂) -> validᵀ Ms (wken t π₁⊆π₂)
valid-wkenᵀ {{t = S.（）}} v π₁⊆π₂ = T.tt
valid-wkenᵀ {{t = S.True}} v π₁⊆π₂ = T.tt
valid-wkenᵀ {{t = S.False}} v π₁⊆π₂ = T.tt
valid-wkenᵀ {{t = S.Id t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {{t = S.unId t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {{t = S.Var τ∈π}} v π₁⊆π₂ = T.tt
valid-wkenᵀ {{t = S.Abs t}} v π₁⊆π₂ = valid-wkenᵀ v (L₁.cons π₁⊆π₂)
valid-wkenᵀ {{t = S.App t t₁}} (proj₁ , proj₂) π₁⊆π₂ = valid-wkenᵀ proj₁ π₁⊆π₂ , valid-wkenᵀ proj₂ π₁⊆π₂
valid-wkenᵀ {{t = S.If t Then t₁ Else t₂}} (v₁ , v₂ , v₃)  π₁⊆π₂ = valid-wkenᵀ v₁ π₁⊆π₂ , valid-wkenᵀ v₂ π₁⊆π₂ , valid-wkenᵀ v₃ π₁⊆π₂
valid-wkenᵀ {{t = S.Return l t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {{t = t S.>>= t₁}} (v₁ , v₂) π₁⊆π₂ = valid-wkenᵀ v₁ π₁⊆π₂ , valid-wkenᵀ v₂ π₁⊆π₂
valid-wkenᵀ {{t = S.Mac l t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {T.Res l T.（）} {{t = S.Res .l t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {T.Res l T.Bool} {{t = S.Res .l t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {T.Res l (τ T.=> τ₁)} {{t = S.Res .l t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {T.Res l₁ (T.Mac l τ)} {{t = S.Res .l₁ t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {T.Res l₁ (T.Res l τ)} {{t = S.Res .l₁ t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {T.Res l (T.Id τ)} {{t = S.Res .l t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {T.Res l (T.Addr τ)} {{t = S.Res .l .(S.#[ proj₂ ])}} (proj₁ , proj₂ , is#[ .proj₂ ] , v) π₁⊆π₂
  = proj₁ , (proj₂ , (is#[ proj₂ ]  , v))
valid-wkenᵀ {T.Res l (T.Addr τ)} {{t = S.Res .l .(S.#[ proj₂ ]ᴰ)}} (proj₁ , proj₂ , is#[ .proj₂ ]ᴰ , v) π₁⊆π₂
  = proj₁ , (proj₂ , (is#[ proj₂ ]ᴰ , v))
valid-wkenᵀ {{t = S.label l⊑h t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {{t = S.label∙ l⊑h t}} () π₁⊆π₂
valid-wkenᵀ {{t = S.unlabel l⊑h t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {{t = S.read x t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {{t = S.write x t t₁}} (v₁ , v₂) π₁⊆π₂ = valid-wkenᵀ v₁ π₁⊆π₂ , valid-wkenᵀ v₂ π₁⊆π₂
valid-wkenᵀ {{t = S.write∙ x t t₁}} () π₁⊆π₂
valid-wkenᵀ {{t = S.new x t}} (l∈ls , v) π₁⊆π₂ = l∈ls , valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {{t = S.new∙ x t}} () π₁⊆π₂
valid-wkenᵀ {{t = S.#[ x ]}} v π₁⊆π₂ = T.tt
valid-wkenᵀ {{t = S.#[ x ]ᴰ}} v π₁⊆π₂ = T.tt
valid-wkenᵀ {{t = S.fork l⊑h t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {{t = S.fork∙ l⊑h t}} () π₁⊆π₂
valid-wkenᵀ {{t = S.deepDup t}} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᵀ {{t = S.∙}} () π₁⊆π₂

valid-wkenᶜ : ∀ {τ₁ τ₂ l π₁ π₂ ls} {Ms : Memories ls} {C : Cont l π₁ τ₁ τ₂} -> validᶜ Ms C -> (π₁⊆π₂ : π₁ ⊆ π₂) -> validᶜ Ms (wkenᶜ C π₁⊆π₂)
valid-wkenᶜ {C = S.Var τ∈π} v π₁⊆π₂ = T.tt
valid-wkenᶜ {C = S.# τ∈π} v π₁⊆π₂ = T.tt
valid-wkenᶜ {C = S.Then t Else t₁} (v₁ , v₂) π₁⊆π₂ = valid-wkenᵀ {{t = t}} v₁ π₁⊆π₂ , valid-wkenᵀ {{t = t₁}} v₂ π₁⊆π₂
valid-wkenᶜ {C = S.Bind t} v π₁⊆π₂ = valid-wkenᵀ v π₁⊆π₂
valid-wkenᶜ {C = S.unlabel p} v π₁⊆π₂ = T.tt
valid-wkenᶜ {C = S.unId} v π₁⊆π₂ = T.tt
valid-wkenᶜ {C = S.write x τ∈π} v π₁⊆π₂ = T.tt
valid-wkenᶜ {C = S.write∙ x τ∈π} () π₁⊆π₂
valid-wkenᶜ {C = S.read x} v π₁⊆π₂ = T.tt

valid-wkenˢ : ∀ {τ₁ τ₂ l π₁ π₂ ls} {Ms : Memories ls} {S : Stack l π₁ τ₁ τ₂} -> validˢ Ms S -> (π₁⊆π₂ : π₁ ⊆ π₂) -> validˢ Ms (S.wkenˢ 𝓛 S π₁⊆π₂)
valid-wkenˢ {S = S.[]} v π₁⊆π₂ = T.tt
valid-wkenˢ {S = C S.∷ S} (proj₁ , proj₂) π₁⊆π₂ = (valid-wkenᶜ {C = C} proj₁ π₁⊆π₂) , (valid-wkenˢ proj₂ π₁⊆π₂)
valid-wkenˢ {S = S.∙} v π₁⊆π₂ = v

valid-deepDupᵀ : ∀ {π τ ls} {t : Term π τ} {Ms : Memories ls} -> validᵀ Ms t -> validᵀ Ms (deepDupᵀ t)
valid-deepDupᵀ = {!!}

memberᴴ : ∀ {l ls τ π₁ π₂} {Ms : Memories ls} {Δ : Heap l π₂} {t : Term π₁ τ}
  -> (τ∈π : τ ∈⟨ l ⟩ᴿ π₂) -> validᴴ Ms Δ -> τ∈π ↦ t ∈ᴴ Δ -> validᵀ Ms t
memberᴴ ⟪ τ∈π ⟫ v t∈Δ = aux ⟪ ∈-∈ᴿ τ∈π ⟫ v t∈Δ
  where aux : ∀ {l ls τ π₁ π₂} {Ms : Memories ls} {Δ : Heap l π₂} {t : Term π₁ τ}
            -> (τ∈π : τ ∈⟨ l ⟩ π₂) -> validᴴ Ms Δ -> Memberᴴ (just t) τ∈π Δ -> validᵀ Ms t
        aux .(T.⟪ L₁.here ⟫) y S.here = proj₁ y
        aux ._ y (S.there z) = aux T.⟪ _ ⟫ (proj₂ y) z

updateᴴ : ∀ {l ls τ π π'} {Ms : Memories ls} {Δ₁ Δ₂ : Heap l π} {mt : Maybe (Term π' τ)} ->
            {τ∈π : τ ∈⟨ l ⟩ π} -> validᴴ Ms Δ₁ -> validᴹᵀ Ms mt -> Updateᴴ mt τ∈π Δ₁ Δ₂ -> validᴴ Ms Δ₂
updateᴴ x y S.here = y , proj₂ x
updateᴴ (proj₁ , proj₂) y (S.there z) = proj₁ , updateᴴ proj₂ y z

valid⇝ : ∀ {l ls τ} {s₁ s₂ : State l τ} {Ms : Memories ls} -> valid-state Ms s₁ -> s₁ ⇝ s₂ -> valid-state Ms s₂
valid⇝ (Δⱽ , (proj₁ , proj₂) , Sᵛ) (SS.App₁ {t₁ = t₁}) = (proj₂ , Δⱽ) , (valid-wkenᵀ {{t = t₁}} proj₁ _ , (T.tt , valid-wkenˢ Sᵛ _))
valid⇝ (Δⱽ , tⱽ , proj₁ , proj₂) (SS.App₂ {t = t} α∈π) = Δⱽ , (valid-subst {t₂ = t} proj₁ tⱽ , proj₂)
valid⇝ (Δⱽ , tⱽ , Sᵛ) (SS.Var₁ τ∈π t∈Δ ¬val rᴴ) = updateᴴ Δⱽ tt rᴴ , (memberᴴ τ∈π Δⱽ t∈Δ , (T.tt , Sᵛ))
valid⇝ (Δⱽ , tⱽ , Sᵛ)  (SS.Var₁' τ∈π v∈Δ val) = Δⱽ , memberᴴ τ∈π Δⱽ v∈Δ , Sᵛ
valid⇝ (Δⱽ , tⱽ , Sᵛ)  (SS.Var₂ τ∈π val uᴴ) = updateᴴ Δⱽ tⱽ uᴴ , (tⱽ , (proj₂ Sᵛ))
valid⇝ (Δⱽ , (proj₁ , proj₂ , proj₃) , Sᵛ) SS.If = Δⱽ , proj₁ , (proj₂ , proj₃) , Sᵛ
valid⇝ (Δⱽ , tⱽ , (proj₁ , proj₃) , proj₂) SS.IfTrue = Δⱽ , proj₁ , proj₂
valid⇝ (Δⱽ , tⱽ , (proj₁ , proj₃) , proj₂) SS.IfFalse = Δⱽ , proj₁ , proj₂
valid⇝ (Δⱽ , tⱽ , Sᵛ) SS.Return = Δⱽ , tⱽ , Sᵛ
valid⇝ (Δⱽ , (proj₁ , proj₂) , Sᵛ) SS.Bind₁ = Δⱽ , proj₁ , proj₂ , Sᵛ
valid⇝ (Δⱽ , tⱽ , proj₁ , proj₂) SS.Bind₂ = Δⱽ , (proj₁ , tⱽ) , proj₂
valid⇝ (Δⱽ , tⱽ , Sᵛ) (SS.Label' p) = Δⱽ , tⱽ , Sᵛ
valid⇝ (Δⱽ , () , Sᵛ) (SS.Label'∙ p)
valid⇝ (Δⱽ , tⱽ , Sᵛ) (SS.Unlabel₁ p) = Δⱽ , tⱽ , T.tt , Sᵛ
valid⇝ (Δⱽ , tⱽ , Sᵛ) (SS.Unlabel₂ p) = Δⱽ , tⱽ , proj₂ Sᵛ
valid⇝ (Δⱽ , tⱽ , Sᵛ) SS.UnId₁ = Δⱽ , tⱽ , T.tt , Sᵛ
valid⇝ (Δⱽ , tⱽ , Sᵛ) SS.UnId₂ = Δⱽ , tⱽ , proj₂ Sᵛ
valid⇝ () SS.Hole₁
valid⇝ (Δⱽ , () , Sᵛ) SS.Hole₂
valid⇝ (Δⱽ , (l∈ls , tⱽ) , Sᵛ) (SS.New₁ ¬var) = (tⱽ , Δⱽ) , ((l∈ls , T.tt) , valid-wkenˢ Sᵛ _)
valid⇝ (Δⱽ , () , Sᵛ) (SS.New∙₁ ¬var)
valid⇝ (Δⱽ , (tⱽ₁ , tⱽ₂) , Sᵛ) SS.Write₁ = (tⱽ₂ , Δⱽ) , (valid-wkenᵀ tⱽ₁ _) , (T.tt , (valid-wkenˢ Sᵛ _))
valid⇝ (Δⱽ , () , Sᵛ) SS.Write∙₁
valid⇝ (Δⱽ , tⱽ , Sᵛ) SS.Read₁ = Δⱽ , tⱽ , T.tt , Sᵛ

memberᴱ : ∀ {ls ls' l} {Ms : Memories ls'} {Γ : Heaps ls} {H : Heap∙ l} -> map-validᴴ Ms Γ -> l ↦ H ∈ᴱ Γ -> validᴴ∙ Ms H
memberᴱ (proj₁ , proj₂) S.here = proj₁
memberᴱ (proj₁ , proj₂) (S.there u₁) = memberᴱ proj₂ u₁

updateᴱ : ∀ {ls ls' l} {Ms : Memories ls'} {Γ Γ' : Heaps ls} {H : Heap∙ l} ->
                map-validᴴ Ms Γ ->  validᴴ∙ Ms H -> Γ' ≔ Γ [ l ↦ H ]ᴱ ->  map-validᴴ Ms Γ'
updateᴱ (proj₁ , proj₂) Hⱽ S.here = Hⱽ , proj₂
updateᴱ (proj₁ , proj₂) Hⱽ (S.there u₁) = proj₁ , updateᴱ proj₂ Hⱽ u₁

memberˢ : ∀ {l ls} {Ms : Memories ls} {M : Memory l} -> map-validᴹ Ms -> l ↦ M ∈ˢ Ms -> validᴹ M
memberˢ = {!!}

updateˢ : ∀ {l ls} {Ms₁ Ms₂ : Memories ls} {M : Memory l} -> validᴹ M -> map-validᴹ Ms₁ -> Ms₂ ≔ Ms₁ [ l ↦ M ]ˢ -> map-validᴹ Ms₂
updateˢ = {!!}

valid-newᴹ : ∀ {l τ} {M : Memory l} (c : Cell l τ) -> validᴹ M -> validᴹ (newᴹ c M)
valid-newᴹ = {!!}

valid-writeᴹ : ∀ {n l τ} {c : Cell l τ} {M₁ M₂ : Memory l} -> validᴹ M₁ -> M₂ ≔ M₁ [ n ↦ c ]ᴹ -> validᴹ M₂
valid-writeᴹ = {!!}

newᴹ-⊆ᴹ : ∀ {l τ} {M : Memory l} {c : Cell l τ} -> M ⊆ᴹ newᴹ c M
newᴹ-⊆ᴹ = {!!}

newᴹ-⊆ˢ : ∀ {ls l τ} {M : Memory l} {c : Cell l τ} {Ms₁ Ms₂ : Memories ls} -> l ↦ M ∈ˢ Ms₁ -> Ms₂ ≔ Ms₁ [ l ↦ newᴹ c M ]ˢ -> Ms₁ ⊆ˢ Ms₂
newᴹ-⊆ˢ = {!!}

writeᴹ-⊆ᴹ : ∀ {l τ n} {M₁ M₂ : Memory l} {c : Cell l τ} -> M₂ ≔ M₁ [ n ↦ c ]ᴹ -> M₁ ⊆ᴹ M₂
writeᴹ-⊆ᴹ = {!!}

writeᴹ-⊆ˢ : ∀ {ls l} {M₁ M₂ : Memory l} {Ms₁ Ms₂ : Memories ls} ->
            l ↦ M₁ ∈ˢ Ms₁ -> Ms₂ ≔ Ms₁ [ l ↦ M₂ ]ˢ -> M₁ ⊆ᴹ M₂ -> Ms₁ ⊆ˢ Ms₂
writeᴹ-⊆ˢ = {!!}


-- newᴹ-validAddr : ∀ {ls l τ} {M : Memory l} {Ms₁ Ms₂ : Memories ls} {c : Cell l τ} ->
--                    (l∈ls : l ∈ ls) -> l ↦ M ∈ˢ Ms₁ -> Ms₂ ≔ Ms₁ [ l ↦ newᴹ c M ]ˢ -> ValidAddr (lookupˢ l∈ls Ms₂) (lengthᴹ M) τ
-- newᴹ-validAddr L₁.here S.here S.here = {!!}
-- newᴹ-validAddr L₁.here (S.there l∈Ms) (S.here {u = u}) = ⊥-elim (∈-not-unique (memberˢ-∈ l∈Ms) u)
-- newᴹ-validAddr (L₁.there l∈ls) l∈Ms (S.here {u = u}) = ⊥-elim (∈-not-unique l∈ls u)
-- newᴹ-validAddr l∈ls l∈Ms (S.there u₁) = {!!}

newᴹ-validAddr : ∀ {l τ} {M : Memory l} (c : Cell l τ) -> validᴹ M -> ValidAddr (newᴹ c M) (lengthᴹ M) τ
newᴹ-validAddr {M = S.[]} c v = here
newᴹ-validAddr {M = cᴸ S.∷ M} c v = there (newᴹ-validAddr c v)
newᴹ-validAddr {M = S.∙} c ()

valid⟼ : ∀ {ls τ l} {p₁ p₂ : Program l ls τ} -> validᴾ p₁ -> p₁ ⟼ p₂ -> validᴾ p₂
valid⟼ (proj₁ , proj₂ , proj₃ , proj₄) (SS.Pure l∈Γ step uᴹ) with valid⇝ ((memberᴱ proj₂ l∈Γ) , (proj₃ , proj₄)) step
... | Δ₂ⱽ  , t₂ⱽ , S₂ⱽ = proj₁ , (updateᴱ proj₂ Δ₂ⱽ uᴹ , (t₂ⱽ , S₂ⱽ))
valid⟼ (Msⱽ , Γⱽ , (H∈ls , tⱽ) , Sⱽ) (SS.New {Γ = Γ} {M = M₁} {τ∈π = τ∈π} {l⊑H = l⊑H} H∈Ms uˢ) with newᴹ-⊆ˢ H∈Ms uˢ | memberˢ Msⱽ H∈Ms
... | Ms₁⊆Ms₂ | M₁ⱽ with valid-newᴹ {M = M₁} S.∥ l⊑H , τ∈π  ∥ M₁ⱽ
... | M₂ⱽ with newᴹ-validAddr {M = M₁} S.∥ l⊑H , τ∈π  ∥ M₁ⱽ
... | r rewrite lookupˢ-updateˢ-≡ H∈ls uˢ
  =  updateˢ M₂ⱽ Msⱽ uˢ , (map-wkenᴴ {Γ = Γ} Ms₁⊆Ms₂ Γⱽ , ((H∈ls , (lengthᴹ M₁) , (is#[ _ ] , r)) , wkenˢ Ms₁⊆Ms₂ Sⱽ))
valid⟼ (Msⱽ , Γⱽ , () , Sⱽ) SS.New∙
valid⟼ (Msⱽ , Γⱽ , tⱽ , Sⱽ) (SS.Write₂ {Γ = Γ} H∈Ms uᴹ uˢ) with writeᴹ-⊆ˢ H∈Ms uˢ (writeᴹ-⊆ᴹ uᴹ)
... | Ms₁⊆Ms₂ = (updateˢ (valid-writeᴹ (memberˢ Msⱽ H∈Ms) uᴹ) Msⱽ uˢ) , ((map-wkenᴴ {Γ = Γ} Ms₁⊆Ms₂ Γⱽ) , (tt , wkenˢ Ms₁⊆Ms₂ (proj₂ Sⱽ)))
valid⟼ (Msⱽ , Γⱽ , tⱽ , Sⱽ) (SS.Writeᴰ₂ {Γ = Γ} H∈Ms uᴹ uˢ) with writeᴹ-⊆ˢ H∈Ms uˢ (writeᴹ-⊆ᴹ uᴹ)
... | Ms₁⊆Ms₂ = (updateˢ (valid-writeᴹ (memberˢ Msⱽ H∈Ms) uᴹ) Msⱽ uˢ) , ((map-wkenᴴ {Γ = Γ} Ms₁⊆Ms₂ Γⱽ) , (tt , wkenˢ Ms₁⊆Ms₂ (proj₂ Sⱽ)))
valid⟼ (Msⱽ , Γⱽ , tⱽ , () , proj₂) SS.Write∙₂
valid⟼ (Msⱽ , Γⱽ , tⱽ , Sⱽ) (SS.Read₂ l∈Γ n∈M) = Msⱽ , Γⱽ , tt , proj₂ Sⱽ
valid⟼ (Msⱽ , Γⱽ , tⱽ , Sⱽ) (SS.Readᴰ₂ L∈Ms n∈M) = Msⱽ , Γⱽ , tt , proj₂ Sⱽ
valid⟼ (Msⱽ , Γⱽ , tⱽ , Sⱽ) (SS.DeepDup₁ ¬var l∈Γ uᴱ) = Msⱽ , updateᴱ Γⱽ (tⱽ , (memberᴱ Γⱽ l∈Γ)) uᴱ , tt , valid-wkenˢ Sⱽ _
valid⟼ (Msⱽ , Γⱽ , tt , Sⱽ) (SS.DeepDup₂ {t = t} τ∈π L∈Γ t∈Δ l∈Γ uᴱ) with memberᴱ Γⱽ l∈Γ | memberᴱ Γⱽ L∈Γ
... | Δˡⱽ | Δᴸⱽ  with memberᴴ τ∈π Δᴸⱽ t∈Δ
... | tⱽ = Msⱽ , updateᴱ Γⱽ (valid-deepDupᵀ {t = t} tⱽ , Δˡⱽ) uᴱ , tt , valid-wkenˢ Sⱽ _
valid⟼ (Msⱽ , Γⱽ , ()) SS.Hole
