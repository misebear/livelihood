# frozen_string_literal: true

require "test_helper"

class CareRelationsControllerTest < ActionDispatch::IntegrationTest
  test "guest sees login gate instead of empty private lists" do
    get care_relations_path

    assert_response :success
    assert_select ".auth-gate-card"
    assert_no_match "돌보는 분이 없습니다", response.body
    assert_select "a", text: "로그인하고 보호자 관리하기"
  end
end
