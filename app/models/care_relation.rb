# frozen_string_literal: true

class CareRelation < ApplicationRecord
  # ── Associations ────────────────────────────────────────────
  belongs_to :caregiver, class_name: "User", inverse_of: :caregiving_relations
  belongs_to :recipient, class_name: "User", inverse_of: :receiving_relations

  # ── Enums ───────────────────────────────────────────────────
  enum :status, { pending: 0, accepted: 1 }

  # ── Validations ─────────────────────────────────────────────
  validates :caregiver_id, uniqueness: { scope: :recipient_id, message: "이미 연결된 관계입니다." }
  validate  :caregiver_and_recipient_must_differ

  # ── Scopes ──────────────────────────────────────────────────
  scope :active, -> { where(status: :accepted) }

  private

  def caregiver_and_recipient_must_differ
    if caregiver_id == recipient_id
      errors.add(:recipient_id, "보호자와 수급자가 동일할 수 없습니다.")
    end
  end
end
