import Lattice as L
import Scheduler as S

module Concurrent.Semantics (𝓛 : L.Lattice) (𝓢 : S.Scheduler 𝓛) where

open import Types 𝓛
open S.Scheduler 𝓛 𝓢

open S.Message
open S.Event

open import Sequential.Calculus 𝓛
open import Sequential.Semantics 𝓛
open import Concurrent.Calculus 𝓛 𝓢

-- Concurrent semantics
data Stepᶜ (l : Label) (n : ℕ) {ls} : Global ls -> Global ls -> Set where
  step-∅ : ∀ {π₁ π₂ τ₁ τ₂ S₁ S₂ s₁ s₂} {t₁ : Term π₁ τ₁} {t₂ : Term π₂ τ₂} {Γ₁ Γ₂ : Heap ls} {P₁ P₂ : Pools ls} {T₁ T₂ : Pool l}
           (l∈P : l ↦ T₁ ∈ᴾ P₁)
           (t∈T : n ↦ ⟨ t₁ , S₁ ⟩ ∈ᵀ T₁)
           (¬fork : ¬ (IsFork t₁))
           (step : ⟨ Γ₁ , t₁ , S₁ ⟩ ⟼ ⟨ Γ₂ , t₂ , S₂ ⟩)
           (sch : s₁ ⟶ s₂ ↑ (l , n , Step) )
           (uᵀ : T₂ ≔ T₁ [ n ↦ ⟨ t₂ , S₂ ⟩ ]ᵀ )
           (uᴾ : P₂ ≔ P₁ [ l ↦ T₂ ]ᴾ ) ->
           Stepᶜ l n ⟨ s₁ , Γ₁ , P₁ ⟩ ⟨ s₂ , Γ₂ , P₂ ⟩

  fork :  ∀ {H π₁ π₂ τ₂ S₁ S₂ s₁ s₂} {tᴴ : Term π₁ (Mac H _)} {t₂ : Term π₂ τ₂} {Γ₁ Γ₂ : Heap ls}
            {P₁ P₂ P₃ : Pools ls} {T₁ T₂ : Pool l} {Tᴴ : Pool H} {l⊑H : l ⊑ H}
           (l∈P : l ↦ T₁ ∈ᴾ P₁)
           (t∈T : n ↦ ⟨ fork l⊑H tᴴ , S₁ ⟩ ∈ᵀ T₁)
           (step : ⟨ Γ₁ , fork l⊑H tᴴ , S₁ ⟩ ⟼ ⟨ Γ₂ , t₂ , S₂ ⟩)
           (uᵀ : T₂ ≔ T₁ [ n ↦ ⟨ t₂ , S₂ ⟩ ]ᵀ )
           (u₁ᴾ : P₂ ≔ P₁ [ l ↦ T₂ ]ᴾ )
           (H∈P₂ : H ↦ Tᴴ ∈ᴾ P₂)
           (sch : s₁ ⟶ s₂ ↑ (l , n , Fork H (lenghtᴾ Tᴴ) l⊑H) )
           (u₂ᴾ : P₃ ≔ P₂ [ H ↦ Tᴴ ▻ ⟨ tᴴ , [] ⟩ ]ᴾ ) ->
           Stepᶜ l n ⟨ s₁ , Γ₁ , P₁ ⟩ ⟨ s₂ , Γ₂ , P₂ ⟩

  skip : ∀ {s₁ s₂ τ π S} {t : Term π τ} {Γ : Heap ls} {P : Pools ls} {T : Pool l}
            (l∈P : l ↦ T ∈ᴾ P)
            (t∈T : n ↦ ⟨ t , S ⟩ ∈ᵀ T)
            (stuck : Stuckᴾ ⟨ Γ , t , S ⟩)
            (sch : s₁ ⟶ s₂ ↑ (l , n , Skip) ) ->
            Stepᶜ l n ⟨ s₁ , Γ , P ⟩ ⟨ s₂ , Γ , P ⟩

  done : ∀ {s₁ s₂ τ π S} {t : Term π τ} {Γ : Heap ls} {P : Pools ls} {T : Pool l}
            (l∈P : l ↦ T ∈ᴾ P)
            (t∈T : n ↦ ⟨ t , S ⟩ ∈ᵀ T)
            (done : Doneᴾ ⟨ Γ , t , S ⟩)
            (sch : s₁ ⟶ s₂ ↑ (l , n , Done) ) ->
            Stepᶜ l n ⟨ s₁ , Γ , P ⟩ ⟨ s₂ , Γ , P ⟩

  hole : ∀ {s} {Γ : Heap ls} {P : Pools ls} {T : Pool l}
            (l∈P : l ↦ T ∈ᴾ P)
            (t∈T : n ↦ ∙ ∈ᵀ T)
            (sch : s ⟶ s ↑ (l , n , ∙) ) ->
           Stepᶜ l n ⟨ s , Γ , P ⟩ ⟨ s , Γ , P ⟩


open import Data.Product

_⊢_↪_ : ∀ {ls} -> Label × ℕ -> Global ls -> Global ls -> Set
(l , n) ⊢ g₁ ↪ g₂ = Stepᶜ l n g₁ g₂

-- -- An auxiliary data type that externalizes a global-step event.
-- data _⊢ᴹ_↪_ {ls} : ∀ {l} -> Message l -> Global ls -> Global ls -> Set where
--   withMsg : ∀ {l n g₁ g₂} -> (s : l , n ⊢ g₁ ↪ g₂) -> (l , n , (getEvent s)) ⊢ᴹ g₁ ↪ g₂

-- open import Data.Product

-- -- Transitive closure of the concurrent small step
-- data _↪⋆_ {ls : List Label} : Global ls -> Global ls -> Set where

--   -- Zero steps
--   [] : ∀ {g} -> g ↪⋆ g

--   -- More steps
--   _∷_ : ∀ {l n g₁ g₂ g₃} -> l , n ⊢ g₁ ↪ g₂ -> g₂ ↪⋆ g₃ -> g₁ ↪⋆ g₃


-- -- Concatenates two multiple steps reductions
-- _++ˢ_ : ∀ {ls} {g₁ g₂ g₃ : Global ls} -> g₁ ↪⋆ g₂ -> g₂ ↪⋆ g₃ -> g₁ ↪⋆ g₃
-- [] ++ˢ ss₂ = ss₂
-- (s ∷ ss₁) ++ˢ ss₂ = s ∷ (ss₁ ++ˢ ss₂)
