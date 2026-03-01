# frozen_string_literal: true

class User < ApplicationRecord
  # ── Devise ──────────────────────────────────────────────────
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

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

  # ── Callbacks ───────────────────────────────────────────────
  # 회원가입 시 role 미입력이면 기본값 recipient(수급자)으로 설정
  before_validation :set_default_role, on: :create

  # ── Validations ─────────────────────────────────────────────
  validates :role, presence: true

  # ── OmniAuth ────────────────────────────────────────────────
  # Google OAuth2 콜백에서 사용자 찾기/생성
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.role = :recipient
    end
  end

  # Google 로그인 사용자는 비밀번호 없이 가입 가능
  def password_required?
    super && provider.blank?
  end

  private

  def set_default_role
    self.role ||= :recipient
  end
end
