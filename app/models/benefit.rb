# frozen_string_literal: true

class Benefit < ApplicationRecord
  # ── Associations ────────────────────────────────────────────
  has_many :user_benefits, dependent: :destroy
  has_many :users, through: :user_benefits

  # ── Validations ─────────────────────────────────────────────
  validates :external_id, presence: true, uniqueness: true
  validates :title, presence: true

  # ── 카테고리 상수 ───────────────────────────────────────────
  CATEGORIES = {
    "기초급여"    => { icon: "🏠", color: "#6366f1" },
    "자산형성"    => { icon: "💰", color: "#059669" },
    "감면·할인"   => { icon: "💳", color: "#0284c7" },
    "바우처"      => { icon: "🎫", color: "#d946ef" },
    "긴급지원"    => { icon: "🚨", color: "#dc2626" },
    "교육·문화"   => { icon: "📚", color: "#ea580c" },
    "출산·가족"   => { icon: "👶", color: "#ec4899" },
    "금융서비스"  => { icon: "🏦", color: "#0891b2" },
    "건강·의료"   => { icon: "🏥", color: "#16a34a" },
    "주거"        => { icon: "🏡", color: "#7c3aed" },
    "지역특화"    => { icon: "📍", color: "#f59e0b" }
  }.freeze

  # ── Scopes ──────────────────────────────────────────────────
  scope :safe_savings_products, -> { where(is_safe_savings: true) }
  scope :general, -> { where(is_safe_savings: false) }
  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :by_eligibility, ->(type) { where(eligibility_type: type) if type.present? }
  scope :deadline_soon, -> { where("deadline IS NOT NULL AND deadline >= ?", Date.current).order(:deadline) }
  scope :prioritized, -> { order(Arel.sql("COALESCE(last_synced_at, updated_at) DESC"), priority: :desc, deadline: :asc) }
  scope :from_source, ->(src) { where(source: src) if src.present? }
  scope :search, ->(query) {
    return all if query.blank?
    q = "%#{query}%"
    where("title LIKE :q OR summary LIKE :q OR target_group LIKE :q OR support_amount LIKE :q", q: q)
  }

  # ── 카테고리 메타 ───────────────────────────────────────────
  def category_icon
    CATEGORIES.dig(category, :icon) || "📋"
  end

  def category_color
    CATEGORIES.dig(category, :color) || "#64748b"
  end

  def deadline_label
    return nil unless deadline
    days = (deadline - Date.current).to_i
    case days
    when ..0 then "마감"
    when 0 then "오늘 마감"
    when 1..7 then "D-#{days}"
    when 8..30 then "D-#{days}"
    else nil
    end
  end
end
