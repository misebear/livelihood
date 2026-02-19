# frozen_string_literal: true

class UserBenefit < ApplicationRecord
  # ── Associations ────────────────────────────────────────────
  belongs_to :user
  belongs_to :benefit

  # ── Enums ───────────────────────────────────────────────────
  enum :status, { interested: 0, preparing_documents: 1, applied: 2 }

  # ── Validations ─────────────────────────────────────────────
  validates :user_id, uniqueness: { scope: :benefit_id, message: "이미 등록된 혜택입니다." }

  # ── Scopes ──────────────────────────────────────────────────
  scope :in_progress, -> { where(status: [ :interested, :preparing_documents ]) }
  scope :completed,   -> { where(status: :applied) }
end
