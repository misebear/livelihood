# frozen_string_literal: true

require "test_helper"

class UserProfileTest < ActiveSupport::TestCase
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

  # ── 금액 헬퍼 메서드 테스트 ──
  test "monthly_income_amount는 정수를 반환한다" do
    assert_equal 800_000, @profile.monthly_income_amount
  end

  test "assets_amount는 정수를 반환한다" do
    assert_equal 30_000_000, @profile.assets_amount
  end

  test "vehicle_amount는 정수를 반환한다" do
    assert_equal 0, @profile.vehicle_amount
  end

  test "빈 값일 때 금액 헬퍼는 0을 반환한다" do
    empty_profile = UserProfile.new(user: users(:admin))
    assert_equal 0, empty_profile.monthly_income_amount
    assert_equal 0, empty_profile.assets_amount
    assert_equal 0, empty_profile.vehicle_amount
  end

  # ── Enum 테스트 ──
  test "region_type enum이 올바르다" do
    assert @profile.region_type_metropolitan?
    assert_equal %w[metropolitan city rural], UserProfile.region_types.keys
  end

  test "housing_type enum이 올바르다" do
    assert @profile.housing_type_monthly_rent?
    assert_equal %w[owned jeonse monthly_rent public_rental], UserProfile.housing_types.keys
  end

  # ── Validation 테스트 ──
  test "가구원 수는 양의 정수여야 한다" do
    @profile.household_size = -1
    assert_not @profile.valid?

    @profile.household_size = 0
    assert_not @profile.valid?

    @profile.household_size = 3
    assert @profile.valid?
  end

  test "가구원 수가 nil이면 유효하다 (선택 입력)" do
    @profile.household_size = nil
    assert @profile.valid?
  end
end
