# frozen_string_literal: true

# ────────────────────────────────────────────────────────────────
# SafeAssetCalculatorService
# ────────────────────────────────────────────────────────────────
# 수급 탈락 방지 '안전선' 관리 계산기 (Killer Feature)
#
# 모의 소득인정액 = 소득평가액 + 재산의 소득환산액
#   소득평가액    = 실제소득 - 가구특성별 지출비용 (간이 모의)
#   재산소득환산액 = (재산 - 기본재산공제) × 소득환산율
#
# 이 서비스는 2024년 기준 중앙생활보장위원회 기준으로
# 모의 계산을 수행합니다. 정확한 판정은 행정복지센터에서만 가능합니다.
#
# 사용법:
#   result = SafeAssetCalculatorService.call(user_profile)
#   result[:risk_percentage]     # => 72.5
#   result[:risk_level]          # => :warning
#   result[:safe_savings_amount] # => 3_500_000
# ────────────────────────────────────────────────────────────────
class SafeAssetCalculatorService
  # ── 2024년 기준 중위소득 (월, 원) ────────────────────────────
  # 출처: 보건복지부 고시
  MEDIAN_INCOME_2024 = {
    1 => 2_228_445,
    2 => 3_682_609,
    3 => 4_714_657,
    4 => 5_729_913,
    5 => 6_695_735,
    6 => 7_618_369,
    7 => 8_514_994
  }.freeze

  # 생계급여 선정기준: 중위소득의 32%
  LIVELIHOOD_RATIO = 0.32

  # 기본재산 공제액 (원)
  BASE_ASSET_DEDUCTION = {
    "metropolitan" => 69_000_000,  # 대도시 (서울)
    "city"         => 42_000_000,  # 중소도시
    "rural"        => 35_000_000   # 농어촌
  }.freeze

  # 재산의 소득환산율 (월)
  ASSET_CONVERSION_RATES = {
    general:  0.0417,  # 일반재산: 월 4.17%
    financial: 0.0626, # 금융재산: 월 6.26%
    vehicle:   1.0     # 자동차: 월 100%
  }.freeze

  # 금융재산 기본공제: 생활준비금
  FINANCIAL_DEDUCTION = 500_000 # 50만 원

  class << self
    def call(user_profile)
      new(user_profile).calculate
    end
  end

  def initialize(user_profile)
    @profile = user_profile
  end

  def calculate
    income_eval = income_evaluation
    asset_eval  = asset_income_conversion
    total_recognized_income = [ income_eval + asset_eval, 0 ].max

    cutoff_line   = livelihood_cutoff
    risk_pct      = calculate_risk_percentage(total_recognized_income, cutoff_line)
    safe_amount   = calculate_safe_savings(cutoff_line, income_eval)
    risk_level    = determine_risk_level(risk_pct)

    {
      # ── 핵심 지표 ──
      risk_percentage: risk_pct.round(1),
      risk_level: risk_level,                    # :safe, :warning, :danger
      safe_savings_amount: [ safe_amount, 0 ].max, # 추가 저축 가능 금액

      # ── 상세 내역 ──
      breakdown: {
        household_size: household_size,
        median_income: median_income,
        cutoff_line: cutoff_line,
        income_evaluation: income_eval,
        asset_income_conversion: asset_eval,
        total_recognized_income: total_recognized_income,
        base_asset_deduction: base_deduction,
        region_type: @profile.region_type || "metropolitan"
      },

      # ── 정부매칭 저축통장 추천 여부 ──
      recommend_safe_savings: risk_level != :danger,

      # ── 면책 조항 ──
      disclaimer: disclaimer_text
    }
  end

  private

  # ── 소득평가액 (간이) ───────────────────────────────────────
  # 실제소득에서 근로소득공제(30%) 적용
  def income_evaluation
    monthly_income = @profile.monthly_income_amount
    earned_income = monthly_income
    # 근로소득공제: 근로소득의 30% 공제
    deduction = (earned_income * 0.30).to_i
    [ earned_income - deduction, 0 ].max
  end

  # ── 재산의 소득환산액 ───────────────────────────────────────
  # (일반재산 + 금융재산 - 기본재산공제 - 부채) × 환산율
  # MVP에서는 declared_assets를 금융재산으로,
  # vehicle_value를 자동차로 분리 계산
  def asset_income_conversion
    total_assets = @profile.assets_amount
    vehicle      = @profile.vehicle_amount

    # 일반+금융 재산 환산
    net_assets = [ total_assets - base_deduction - FINANCIAL_DEDUCTION, 0 ].max
    general_conversion = (net_assets * ASSET_CONVERSION_RATES[:financial]).to_i

    # 자동차 환산 (차량가액 전액 소득 반영)
    # 단, 차량가액 200만원 미만 또는 장애인 사용 차량은 제외 (간이)
    vehicle_conversion = if vehicle < 2_000_000
                           0
    else
                           (vehicle * ASSET_CONVERSION_RATES[:vehicle]).to_i
    end

    general_conversion + vehicle_conversion
  end

  # ── 생계급여 선정 기준선 ────────────────────────────────────
  def livelihood_cutoff
    (median_income * LIVELIHOOD_RATIO).to_i
  end

  # ── 리스크 비율 계산 ────────────────────────────────────────
  def calculate_risk_percentage(recognized_income, cutoff)
    return 100.0 if cutoff <= 0
    [ (recognized_income.to_f / cutoff) * 100, 100.0 ].min
  end

  # ── 추가 저축 가능 한도 역산 ────────────────────────────────
  # 현재 소득인정액에서 기준선까지의 여유분을 금융재산으로 환산
  def calculate_safe_savings(cutoff, current_income_eval)
    remaining_capacity = cutoff - current_income_eval
    return 0 if remaining_capacity <= 0

    # 금융재산 환산율 역산: 가능 금액 = 남은 소득인정액 여유 / 환산율
    (remaining_capacity / ASSET_CONVERSION_RATES[:financial]).to_i
  end

  # ── 위험 수준 판정 ──────────────────────────────────────────
  def determine_risk_level(percentage)
    case percentage
    when 0...60   then :safe      # 초록 (안전)
    when 60...85  then :warning   # 노랑 (주의)
    else               :danger    # 빨강 (위험)
    end
  end

  # ── Helper ──────────────────────────────────────────────────
  def household_size
    size = @profile.household_size || 1
    size.clamp(1, 7)
  end

  def median_income
    MEDIAN_INCOME_2024.fetch(household_size, MEDIAN_INCOME_2024[7])
  end

  def base_deduction
    region = @profile.region_type || "metropolitan"
    BASE_ASSET_DEDUCTION.fetch(region, BASE_ASSET_DEDUCTION["metropolitan"])
  end

  def disclaimer_text
    "본 결과는 모의 계산이며, 정확한 자격 유지 여부는 반드시 관할 " \
    "행정복지센터에 확인하세요. 본 앱은 법적 책임을 지지 않습니다."
  end
end
