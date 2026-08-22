# frozen_string_literal: true

require "test_helper"

class AppSupportControllerTest < ActionDispatch::IntegrationTest
  test "support center lists HaruScene links" do
    get app_support_path

    assert_response :success
    assert_select "#haruscene h4", "하루장면"
    assert_select "a[href=?]", haruscene_support_path, text: "지원 페이지"
    assert_select "a[href=?]", haruscene_privacy_path, text: "개인정보처리방침"
    assert_select "#batang-issue h4", "바탕 이슈"
    assert_select "#batang-issue .support-chip", "com.issueon.app"
    assert_select "a[href=?]", batang_issue_support_path, text: "지원 페이지"
    assert_select "a[href=?]", batang_issue_privacy_path, text: "개인정보처리방침"
    assert_select "#rush-pass .support-chip", "com.bodeum.party.rushpass"
    assert_select "a[href=?]", rush_pass_privacy_path, text: "개인정보처리방침"
    assert_select "#secret-signal .support-chip", "com.bodeum.party.secretsignal"
    assert_select "a[href=?]", secret_signal_privacy_path, text: "개인정보처리방침"
    assert_select "#tap-arena-4 .support-chip", "com.bodeum.party.taparena4"
    assert_select "a[href=?]", tap_arena_privacy_path, text: "개인정보처리방침"
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

  test "Batang Issue privacy page renders Play policy content" do
    get batang_issue_privacy_path

    assert_response :success
    assert_select "title", "바탕 이슈 개인정보처리방침"
    assert_select "link[rel='canonical'][href=?]", batang_issue_privacy_url
    assert_select "h1", "바탕 이슈 개인정보처리방침"
    assert_select "li", text: /Google AdMob SDK/
    assert_select "p", text: /위치 권한은 선택 사항/
  end

  test "Batang Issue support page renders widget support content" do
    get batang_issue_support_path

    assert_response :success
    assert_select "title", "바탕 이슈 지원"
    assert_select "link[rel='canonical'][href=?]", batang_issue_support_url
    assert_select "h1", "바탕 이슈 지원"
    assert_select "li", text: /홈 화면 위젯/
  end


  test "party app privacy pages render package specific policies" do
    get rush_pass_privacy_path
    assert_response :success
    assert_select "title", "Rush Pass Party 개인정보처리방침"
    assert_select "code", "com.bodeum.party.rushpass"
    assert_select "p", text: /Firebase Analytics가 활성화되어 있지 않습니다/

    get secret_signal_privacy_path
    assert_response :success
    assert_select "title", "Secret Signal Party 개인정보처리방침"
    assert_select "code", "com.bodeum.party.secretsignal"
    assert_select "li", text: /커스텀 카드 팩/

    get tap_arena_privacy_path
    assert_response :success
    assert_select "title", "Tap Arena 4 개인정보처리방침"
    assert_select "code", "com.bodeum.party.taparena4"
    assert_select "li", text: /best-of-5/
  end

  test "party app support pages render troubleshooting and privacy links" do
    get rush_pass_support_path
    assert_response :success
    assert_select "li", text: /첫 4라운드/
    assert_select "a[href=?]", rush_pass_privacy_path

    get secret_signal_support_path
    assert_response :success
    assert_select "h2", "비밀 화면"
    assert_select "a[href=?]", secret_signal_privacy_path

    get tap_arena_support_path
    assert_response :success
    assert_select "h2", "멀티터치 점검"
    assert_select "a[href=?]", tap_arena_privacy_path
  end
end
