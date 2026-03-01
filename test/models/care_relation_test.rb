# frozen_string_literal: true

require "test_helper"

class CareRelationTest < ActiveSupport::TestCase
  # ── 기본 동작 테스트 ──
  test "보호자와 수급자의 accepted 관계가 존재한다" do
    rel = care_relations(:active_relation)
    assert rel.accepted?
    assert_equal users(:caregiver), rel.caregiver
    assert_equal users(:recipient), rel.recipient
  end

  # ── Validation: 자기 자신 보호 불가 ──
  test "보호자와 수급자가 같으면 유효하지 않다" do
    rel = CareRelation.new(
      caregiver: users(:recipient),
      recipient: users(:recipient)
    )
    assert_not rel.valid?
    assert rel.errors[:recipient_id].any?
  end

  # ── Validation: 중복 관계 불가 ──
  test "이미 존재하는 보호 관계는 생성할 수 없다" do
    dup = CareRelation.new(
      caregiver: users(:caregiver),
      recipient: users(:recipient)
    )
    assert_not dup.valid?
    assert dup.errors[:caregiver_id].any?
  end

  # ── Scope ──
  test "active scope는 accepted 관계만 반환한다" do
    assert CareRelation.active.all?(&:accepted?)
  end

  # ── Enum 테스트 ──
  test "상태 enum이 올바르다" do
    assert_equal({ "pending" => 0, "accepted" => 1 }, CareRelation.statuses)
  end
end
