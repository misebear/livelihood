# frozen_string_literal: true

class User < ApplicationRecord
  # ── Devise ──────────────────────────────────────────────────
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ── Enums ───────────────────────────────────────────────────
  enum :role, { recipient: 0, caregiver: 1, admin: 2 }

  # ── Associations ────────────────────────────────────────────
  has_one :user_profile, dependent: :destroy

  # 보호자(Caregiver)가 맡고 있는 관계
  has_many :caregiving_relations,
           class_name: "CareRelation",
           foreign_key: :caregiver_id,
           dependent: :destroy,
           inverse_of: :caregiver

  # 수급자(Recipient)로서 받는 관계
  has_many :receiving_relations,
           class_name: "CareRelation",
           foreign_key: :recipient_id,
           dependent: :destroy,
           inverse_of: :recipient

  # 간접 관계 - 보호자가 돌보는 수급자들
  has_many :dependents,
           through: :caregiving_relations,
           source: :recipient

  # 간접 관계 - 수급자를 돌보는 보호자들
  has_many :caregivers,
           through: :receiving_relations,
           source: :caregiver

  has_many :user_benefits, dependent: :destroy
  has_many :benefits, through: :user_benefits
  has_many :cashflow_events, dependent: :destroy

  # ── Validations ─────────────────────────────────────────────
  validates :role, presence: true
end
