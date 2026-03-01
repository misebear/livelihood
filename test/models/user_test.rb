# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  # ── 역할(Role) 테스트 ──
  test "사용자에게 올바른 역할이 할당된다" do
    assert users(:recipient).recipient?
    assert users(:caregiver).caregiver?
    assert users(:admin).admin?
  end

  test "기본 역할은 3가지다" do
    assert_equal %w[recipient caregiver admin], User.roles.keys
  end

  # ── 연관관계 테스트 ──
  test "수급자는 보호자 관계를 가진다" do
    recipient = users(:recipient)
    assert_respond_to recipient, :receiving_relations
    assert_respond_to recipient, :caregivers
  end

  test "보호자는 돌봄 관계를 가진다" do
    caregiver = users(:caregiver)
    assert_respond_to caregiver, :caregiving_relations
    assert_respond_to caregiver, :dependents
  end

  test "사용자는 프로필을 가진다" do
    assert_respond_to users(:recipient), :user_profile
  end

  test "사용자는 관심 혜택을 가진다" do
    recipient = users(:recipient)
    assert_respond_to recipient, :user_benefits
    assert_respond_to recipient, :benefits
  end

  test "사용자는 현금흐름 이벤트를 가진다" do
    assert_respond_to users(:recipient), :cashflow_events
  end

  # ── Validation 테스트 ──
  test "역할은 필수다" do
    user = User.new(email: "test@example.com", password: "password123", role: nil)
    assert_not user.valid?
    assert user.errors[:role].any?
  end
end
