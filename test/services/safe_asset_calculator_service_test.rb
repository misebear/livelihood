# frozen_string_literal: true

require "test_helper"

class SafeAssetCalculatorServiceTest < ActiveSupport::TestCase
  setup do
    @profile = user_profiles(:recipient_profile)
    # encrypted 컬럼은 fixture에서 직접 설정 불가 → 테스트에서 수동 설정
    @profile.update_columns(
      declared_monthly_income: "800000",
      declared_assets: "30000000",
      vehicle_value: "0"
    )
    @profile.reload
  end

  # ── 기본 계산 테스트 ──
  test "결과는 필수 키를 모두 포함한다" do
    result = SafeAssetCalculatorService.call(@profile)

    assert_includes result.keys, :risk_percentage
    assert_includes result.keys, :risk_level
    assert_includes result.keys, :safe_savings_amount
    assert_includes result.keys, :breakdown
    assert_includes result.keys, :recommend_safe_savings
    assert_includes result.keys, :disclaimer
  end

  test "risk_percentage는 0~100 사이다" do
    result = SafeAssetCalculatorService.call(@profile)
    assert result[:risk_percentage] >= 0
    assert result[:risk_percentage] <= 100
  end

  # ── 위험도 판정 테스트 ──
  test "risk_level은 :safe, :warning, :danger 중 하나다" do
    result = SafeAssetCalculatorService.call(@profile)
    assert_includes [:safe, :warning, :danger], result[:risk_level]
  end

  # ── 소득평가액 계산 (30% 공제) 테스트 ──
  test "소득평가액은 근로소득의 70%다" do
    result = SafeAssetCalculatorService.call(@profile)
    expected_income_eval = (800_000 * 0.70).to_i
    assert_equal expected_income_eval, result[:breakdown][:income_evaluation]
  end

  # ── 저축 가능 한도 테스트 ──
  test "safe_savings_amount는 0 이상이다" do
    result = SafeAssetCalculatorService.call(@profile)
    assert result[:safe_savings_amount] >= 0
  end

  # ── 가구원 수에 따른 중위소득 변동 테스트 ──
  test "가구원 수가 많을수록 기준선이 높아진다" do
    @profile.household_size = 1
    result_1 = SafeAssetCalculatorService.call(@profile)

    @profile.household_size = 4
    result_4 = SafeAssetCalculatorService.call(@profile)

    assert result_4[:breakdown][:cutoff_line] > result_1[:breakdown][:cutoff_line]
  end

  # ── 지역에 따른 기본재산 공제 테스트 ──
  test "대도시의 기본재산 공제가 농어촌보다 크다" do
    @profile.region_type = "metropolitan"
    result_metro = SafeAssetCalculatorService.call(@profile)

    @profile.region_type = "rural"
    result_rural = SafeAssetCalculatorService.call(@profile)

    assert result_metro[:breakdown][:base_asset_deduction] > result_rural[:breakdown][:base_asset_deduction]
  end

  # ── 면책 조항 테스트 ──
  test "면책 조항이 포함되어 있다" do
    result = SafeAssetCalculatorService.call(@profile)
    assert result[:disclaimer].present?
    assert result[:disclaimer].include?("모의 계산")
  end

  # ── 정부매칭 저축통장 추천 테스트 ──
  test "위험이 아닌 경우 저축통장을 추천한다" do
    result = SafeAssetCalculatorService.call(@profile)
    if result[:risk_level] != :danger
      assert result[:recommend_safe_savings]
    end
  end
end
