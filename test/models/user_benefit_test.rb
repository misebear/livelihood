# frozen_string_literal: true

require "test_helper"

class UserBenefitTest < ActiveSupport::TestCase
  # ── Enum 테스트 ──
  test "상태 enum이 올바르다" do
    assert_equal({ "interested" => 0, "preparing_documents" => 1, "applied" => 2 }, UserBenefit.statuses)
  end

  test "관심 혜택은 interested 상태다" do
    assert user_benefits(:interested_benefit).interested?
  end

  test "신청 완료 혜택은 applied 상태다" do
    assert user_benefits(:applied_benefit).applied?
  end

  # ── Scope 테스트 ──
  test "in_progress는 interested + preparing_documents만 반환한다" do
    in_progress = users(:recipient).user_benefits.in_progress
    assert_includes in_progress, user_benefits(:interested_benefit)
    assert_not_includes in_progress, user_benefits(:applied_benefit)
  end

  test "completed는 applied만 반환한다" do
    completed = users(:recipient).user_benefits.completed
    assert_includes completed, user_benefits(:applied_benefit)
    assert_not_includes completed, user_benefits(:interested_benefit)
  end

  # ── Validation 테스트 ──
  test "같은 사용자가 같은 혜택을 중복 등록할 수 없다" do
    dup = UserBenefit.new(
      user: users(:recipient),
      benefit: benefits(:savings_account),
      status: :interested
    )
    assert_not dup.valid?
  end
end
