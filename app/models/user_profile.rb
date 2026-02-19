# frozen_string_literal: true

class UserProfile < ApplicationRecord
  # ── Associations ────────────────────────────────────────────
  belongs_to :user

  # ── Encrypted Attributes (Rails 7+ encrypts) ───────────────
  # 민감한 소득/재산 정보는 DB에 암호화하여 저장
  encrypts :declared_monthly_income
  encrypts :declared_assets
  encrypts :vehicle_value

  # ── Enums ───────────────────────────────────────────────────
  # region_type, housing_type은 자유 텍스트가 아닌 enum으로 관리
  enum :region_type, {
    metropolitan: "metropolitan",     # 대도시 (서울, 부산 등)
    city: "city",                     # 중소도시
    rural: "rural"                    # 농어촌
  }, prefix: true

  enum :housing_type, {
    owned: "owned",                   # 자가
    jeonse: "jeonse",                 # 전세
    monthly_rent: "monthly_rent",     # 월세
    public_rental: "public_rental"    # 공공임대
  }, prefix: true

  # ── Validations ─────────────────────────────────────────────
  validates :household_size, numericality: { greater_than: 0, only_integer: true }, allow_nil: true

  # ── Helper Methods ──────────────────────────────────────────
  # 소득/재산 값을 숫자로 반환 (계산용)
  def monthly_income_amount
    declared_monthly_income.to_i
  end

  def assets_amount
    declared_assets.to_i
  end

  def vehicle_amount
    vehicle_value.to_i
  end
end
