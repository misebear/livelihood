Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # ── Dashboard (홈) — 로그인 없이도 접근 가능 ────────────────
  root "dashboard#index"

  # ── Public app support page for Play Console and AdMob verification ──
  get "app-support", to: "app_support#index", as: :app_support
  get "apps/rss.xml", to: "app_support#feed", defaults: { format: :rss }, as: :play_apps_feed
  get "apps/:slug", to: "app_support#show", as: :play_app, constraints: { slug: /[a-z0-9-]+/ }
  get "haruscene/privacy", to: "app_support#haruscene_privacy", as: :haruscene_privacy
  get "haruscene/support", to: "app_support#haruscene_support", as: :haruscene_support
  get "batang-issue/privacy", to: "app_support#batang_issue_privacy", as: :batang_issue_privacy
  get "batang-issue/support", to: "app_support#batang_issue_support", as: :batang_issue_support
  get "rush-pass/privacy", to: "app_support#rush_pass_privacy", as: :rush_pass_privacy
  get "rush-pass/support", to: "app_support#rush_pass_support", as: :rush_pass_support
  get "secret-signal/privacy", to: "app_support#secret_signal_privacy", as: :secret_signal_privacy
  get "secret-signal/support", to: "app_support#secret_signal_support", as: :secret_signal_support
  get "tap-arena-4/privacy", to: "app_support#tap_arena_privacy", as: :tap_arena_privacy
  get "tap-arena-4/support", to: "app_support#tap_arena_support", as: :tap_arena_support
  get "about", to: "static_pages#about", as: :about
  get "contact", to: "static_pages#contact", as: :contact
  get "terms", to: "static_pages#terms", as: :terms
  get "editorial-policy", to: "static_pages#editorial_policy", as: :editorial_policy

  # ── 검색 유입용 복지 가이드 ──────────────────────────────
  resources :guides, only: [ :index, :show ], param: :slug

  # ── 보호자 대리 조회 ─────────────────────────────────────
  get "dashboard/care/:id", to: "dashboard#care_view", as: :care_dashboard

  # ── 프로필 ─────────────────────────────────────────────────
  resource :user_profile, only: [ :show, :edit, :update ]

  # ── 혜택 ───────────────────────────────────────────────────
  resources :benefits, only: [ :index, :show ]
  resources :user_benefits, only: [ :create, :update, :destroy ]

  # ── 보호자 관계 ────────────────────────────────────────────
  resources :care_relations, only: [ :index, :create, :destroy ] do
    member do
      patch :accept
    end
  end

  # ── 현금흐름 이벤트 ──────────────────────────────────────────
  resources :cashflow_events, only: [ :new, :create, :edit, :update, :destroy ]

  # ── Sitemap ────────────────────────────────────────────────
  get "/sitemap.xml", to: "sitemaps#show", format: "xml", as: :sitemap

  # Reveal health status on /up
  get "up" => "rails/health#show", as: :rails_health_check
end
