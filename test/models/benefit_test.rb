# frozen_string_literal: true

require "test_helper"

class BenefitTest < ActiveSupport::TestCase
  # ── Scope 테스트 ──
  test "safe_savings_products는 정부매칭 저축 상품만 반환한다" do
    products = Benefit.safe_savings_products
    assert products.all?(&:is_safe_savings)
    assert_includes products, benefits(:savings_account)
    assert_not_includes products, benefits(:housing_benefit)
  end

  test "general은 일반 혜택만 반환한다" do
    general = Benefit.general
    assert general.none?(&:is_safe_savings)
    assert_includes general, benefits(:housing_benefit)
    assert_not_includes general, benefits(:savings_account)
  end

  # ── Validation 테스트 ──
  test "external_id는 필수다" do
    benefit = Benefit.new(title: "테스트 혜택")
    assert_not benefit.valid?
    assert benefit.errors[:external_id].any?
  end

  test "title은 필수다" do
    benefit = Benefit.new(external_id: "TEST001")
    assert_not benefit.valid?
    assert benefit.errors[:title].any?
  end

  test "external_id는 고유해야 한다" do
    dup = Benefit.new(external_id: "SS001", title: "중복 테스트")
    assert_not dup.valid?
    assert dup.errors[:external_id].any?
  end
end
