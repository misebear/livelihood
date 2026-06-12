# frozen_string_literal: true

require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "editorial policy renders trust and correction standards" do
    get editorial_policy_path

    assert_response :success
    assert_select "title", "보듬 편집 기준"
    assert_select "link[rel='canonical'][href=?]", editorial_policy_url
    assert_select "h1", "편집 기준"
    assert_select "li", text: /공식 기관 확인/
  end
end
