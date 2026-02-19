Rails.application.routes.draw do
  devise_for :users

  # ── Dashboard (홈) ──────────────────────────────────────────
  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end

  root "dashboard#index"

  # ── 프로필 ─────────────────────────────────────────────────
  resource :user_profile, only: [:show, :edit, :update]

  # ── 혜택 ───────────────────────────────────────────────────
  resources :benefits, only: [:index, :show]
  resources :user_benefits, only: [:create, :update, :destroy]

  # ── 보호자 관계 ────────────────────────────────────────────
  resources :care_relations, only: [:index, :create, :destroy] do
    member do
      patch :accept
    end
  end

  # Reveal health status on /up
  get "up" => "rails/health#show", as: :rails_health_check
end
