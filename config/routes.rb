Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # ── Dashboard (홈) ──────────────────────────────────────────
  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end

  root "dashboard#index"

  # ── 보호자 대리 조회 ─────────────────────────────────────
  get "dashboard/care/:id", to: "dashboard#care_view", as: :care_dashboard

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

  # ── 현금흐름 이벤트 ──────────────────────────────────────────
  resources :cashflow_events, only: [:new, :create, :edit, :update, :destroy]

  # Reveal health status on /up
  get "up" => "rails/health#show", as: :rails_health_check
end
