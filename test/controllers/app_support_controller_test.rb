# frozen_string_literal: true

require "test_helper"

class AppSupportControllerTest < ActionDispatch::IntegrationTest
  test "support center lists HaruScene links" do
    get app_support_path

    assert_response :success
    assert_select "#haruscene h4", "하루장면"
    assert_select "a[href=?]", haruscene_support_path, text: "지원 페이지"
    assert_select "a[href=?]", haruscene_privacy_path, text: "개인정보처리방침"
  end

  test "HaruScene privacy page renders Play policy content" do
    get haruscene_privacy_path

    assert_response :success
    assert_select "title", "하루장면 개인정보처리방침"
    assert_select "link[rel='canonical'][href=?]", haruscene_privacy_url
    assert_select "h1", "하루장면 개인정보처리방침"
    assert_select "li", text: /Google Mobile Ads SDK/
  end

  test "HaruScene support page renders contact and troubleshooting" do
    get haruscene_support_path

    assert_response :success
    assert_select "title", "하루장면 지원"
    assert_select "link[rel='canonical'][href=?]", haruscene_support_url
    assert_select "h1", "하루장면 지원"
    assert_select "li", text: /광고 보상 미지급/
  end
end
