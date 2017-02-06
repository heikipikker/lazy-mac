import Lattice as L
import Scheduler as S

module Concurrent.Calculus (𝓛 : L.Lattice) (𝓢 : S.Scheduler 𝓛) where

open import Types 𝓛
open import Sequential.Calculus 𝓛
open S.Scheduler 𝓛 𝓢 renaming (State to Stateˢ)

--------------------------------------------------------------------------------

data Thread (l : Label) : Set where
  ⟨_,_⟩ :  ∀ {τ π} -> Term π τ -> Stack l τ (Mac l （）) -> Thread l
  ∙ : Thread l  -- We use this instead ⟨ ∙ , ∙ ⟩ to make the semantics deterministic easily

-- Pool of threads at a certain label
data Pool (l : Label) : Set where
  [] : Pool l
  _◅_ :  Thread l -> Pool l -> Pool l
  ∙ : Pool l

infixr 3 _◅_

lenghtᴾ : ∀ {l} -> Pool l -> ℕ
lenghtᴾ [] = 0
lenghtᴾ (x ◅ P) = suc (lenghtᴾ P)
lenghtᴾ ∙ = 0

-- Enqueue
_▻_ : ∀ {l} -> Pool l -> Thread l -> Pool l
[] ▻ t = t ◅ []
(x ◅ ts) ▻ t = x ◅ (ts ▻ t)
∙ ▻ t = ∙

--------------------------------------------------------------------------------

-- A list of pools
data Pools : List Label -> Set where
  [] : Pools []
  _◅_ : ∀ {l ls} {{u : Unique l ls}} -> Pool l -> Pools ls -> Pools (l ∷ ls)

open import Relation.Binary.PropositionalEquality

pools-unique : ∀ {l ls} -> (x y : l ∈ ls) -> Pools ls -> x ≡ y
pools-unique here here (x ◅ p) = refl
pools-unique here (there y) (_◅_ {{u}} t p) = ⊥-elim (∈-not-unique y u)
pools-unique (there x) here (_◅_ {{u}} t p) = ⊥-elim (∈-not-unique x u)
pools-unique (there x) (there y) (x₁ ◅ p) rewrite pools-unique x y p = refl

infixl 3 _▻_

--------------------------------------------------------------------------------

-- The global configuration is a thread pool paired with some shared split memory Σ
record Global (ls : List Label) : Set where
  constructor ⟨_,_,_⟩
  field Σ : Stateˢ
        Γ : Heap ls
        P : Pools ls

open Global public
open import Relation.Binary.PropositionalEquality

-- TODO do we need this?
-- state-≡ : ∀ {ls} {g₁ g₂ : Global ls} -> g₁ ≡ g₂ -> state g₁ ≡ state g₂
-- state-≡ refl = refl

-- storeᵍ-≡ : ∀ {ls} {g₁ g₂ : Global ls} -> g₁ ≡ g₂ -> storeᵍ g₁ ≡ storeᵍ g₂
-- storeᵍ-≡ refl = refl

-- pools-≡ : ∀ {ls} {g₁ g₂ : Global ls} -> g₁ ≡ g₂ -> pools g₁ ≡ pools g₂
-- pools-≡ refl = refl

--------------------------------------------------------------------------------
-- Thread Pool operation

data Memberᵀ {l : Label}  : (t : Thread l) -> ℕ -> Pool l -> Set where
--  ∙ : ∀ {n} -> Memberᵀ ∙ n ∙ -- Not clear that we need this
  here : ∀ {t} {ts : Pool l} -> Memberᵀ t zero (t ◅ ts)
  there : ∀ {n t} {ts : Pool l} {t' : Thread l} -> Memberᵀ t n ts -> Memberᵀ t (suc n) (t' ◅ ts)

_↦_∈ᵀ_ : ∀ {l} -> ℕ -> Thread l -> Pool l -> Set
n ↦ t ∈ᵀ ts = Memberᵀ t n ts

data Updateᵀ {l : Label} (t : Thread l) : ℕ -> Pool l -> Pool l -> Set where
  -- ∙ : Updateᵀ t n ∙ ∙  -- Not clear that we need this
  here : ∀ {ts : Pool l} {t' : Thread l} -> Updateᵀ t zero (t' ◅ ts) (t ◅ ts)
  there : ∀ {n} {ts₁ ts₂ : Pool l} {t' : Thread l} -> Updateᵀ t n ts₁ ts₂ -> Updateᵀ t (suc n) (t' ◅ ts₁) (t' ◅ ts₂)

_≔_[_↦_]ᵀ : ∀ {l} -> Pool l -> Pool l -> ℕ -> Thread l -> Set
P' ≔ P [ n ↦ t ]ᵀ = Updateᵀ t n P P'


--------------------------------------------------------------------------------
-- Thread Pools operations

data Memberᴾ {l : Label} (ts : Pool l) : ∀ {ls} -> Pools ls -> Set where
  here : ∀ {ls} {P : Pools ls} {u : Unique l ls} -> Memberᴾ ts (ts ◅ P)
  there : ∀ {l' ls} {P : Pools ls} {u : Unique l' ls} {ts' : Pool l'} -> Memberᴾ ts P -> Memberᴾ ts (ts' ◅ P)

_↦_∈ᴾ_ : ∀ {ls} -> (l : Label) -> Pool l -> Pools ls -> Set
l  ↦ ts ∈ᴾ P = Memberᴾ ts P

data Updateᴾ {l : Label} (ts : Pool l) : ∀ {ls} -> Pools ls -> Pools ls -> Set where
  here : ∀ {ls} {ts' : Pool l} {u : Unique l ls} {P : Pools ls} -> Updateᴾ ts (ts' ◅  P) (ts ◅ P)
  there : ∀ {ls l'} {ts' : Pool l'} {u : Unique l' ls} {P P' : Pools ls} -> Updateᴾ ts P P' -> Updateᴾ ts (ts' ◅ P) (ts' ◅ P')

_≔_[_↦_]ᴾ : ∀ {ls} -> Pools ls -> Pools ls -> (l : Label) -> Pool l -> Set
P' ≔ P [ l ↦ ts ]ᴾ = Updateᴾ ts P P'

--------------------------------------------------------------------------------
