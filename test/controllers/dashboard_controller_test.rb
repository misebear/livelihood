# frozen_string_literal: true

require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "public home renders content-rich welfare guidance" do
    get root_path

    assert_response :success
    assert_select ".home-content-block", minimum: 3
    assert_select "section[aria-label='기초생활보장 제도 안내']", text: /2026년 급여별/
    assert_select ".home-check-list li", minimum: 5
    assert_select ".home-source-list a", text: /복지로 모의계산/
  end
end
