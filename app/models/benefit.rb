# frozen_string_literal: true

class Benefit < ApplicationRecord
  # ── Associations ────────────────────────────────────────────
  has_many :user_benefits, dependent: :destroy
  has_many :users, through: :user_benefits

  # ── Validations ─────────────────────────────────────────────
  validates :external_id, presence: true, uniqueness: true
  validates :title, presence: true

  # ── Scopes ──────────────────────────────────────────────────
  scope :safe_savings_products, -> { where(is_safe_savings: true) }
  scope :general, -> { where(is_safe_savings: false) }
end
