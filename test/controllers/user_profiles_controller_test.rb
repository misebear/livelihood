# frozen_string_literal: true

require "test_helper"

class UserProfilesControllerTest < ActionDispatch::IntegrationTest
  test "guest profile page uses accurate login copy" do
    get user_profile_path

    assert_response :success
    assert_select "a", text: "로그인하고 내 정보 관리하기"
    assert_no_match "Google로 로그인", response.body
  end
end
