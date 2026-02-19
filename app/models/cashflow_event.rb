# frozen_string_literal: true

class CashflowEvent < ApplicationRecord
  # ── Associations ────────────────────────────────────────────
  belongs_to :user

  # ── Enums ───────────────────────────────────────────────────
  enum :event_type, { payment: 0, deduction: 1 }

  # ── Validations ─────────────────────────────────────────────
  validates :event_date, presence: true
  validates :title, presence: true
  validates :expected_amount, numericality: { greater_than_or_equal_to: 0 }

  # ── Scopes ──────────────────────────────────────────────────
  scope :upcoming,    -> { where("event_date >= ?", Date.current).order(:event_date) }
  scope :this_month,  -> { where(event_date: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :payments,    -> { where(event_type: :payment) }
  scope :deductions,  -> { where(event_type: :deduction) }

  # ── Instance Methods ────────────────────────────────────────
  # D-Day 계산 (오늘 기준 남은 일수)
  def days_until
    (event_date - Date.current).to_i
  end

  # D-Day 포맷된 문자열 ("D-3", "D-Day", "D+2")
  def d_day_label
    diff = days_until
    case diff
    when 0 then "D-Day"
    when 1.. then "D-#{diff}"
    else "D+#{diff.abs}"
    end
  end
end
