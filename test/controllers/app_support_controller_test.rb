# frozen_string_literal: true

require "test_helper"

class AppSupportControllerTest < ActionDispatch::IntegrationTest
  test "support center separates all Play apps by public status" do
    get app_support_path

    assert_response :success
    assert_select "#apps .support-card", 37
    assert_select "#held-apps .support-card", 10
    assert_select "a[href=?]", play_app_path("mulmi"), text: "기능·지원"
    assert_select "a[href*='id=com.mulmi.ridecue'][href*='referrer=']", text: "Play 설치"
  end

  test "production app page renders schema support and attributed Play CTA" do
    get play_app_path("mulmi")

    assert_response :success
    assert_select "title", /Mulmi: Car Sickness Aid/
    assert_select "h1", "Mulmi: Car Sickness Aid"
    assert_select "h1", count: 1
    assert_select "link[rel='canonical'][href=?]", play_app_url("mulmi")
    assert_select "script[type='application/ld+json']", text: /SoftwareApplication/
    assert_select "a[href*='id=com.mulmi.ridecue'][href*='referrer=']", text: "Google Play에서 설치"
  end

  test "every production app has one canonical indexable page" do
    PlayAppCatalog.active.each do |app|
      get play_app_path(app[:slug])

      assert_response :success, app[:slug]
      assert_select "h1", text: app[:name], count: 1
      assert_select "link[rel='canonical'][href=?]", play_app_url(app[:slug])
      assert_select "script[type='application/ld+json']", text: /#{Regexp.escape(app[:package_name])}/
      assert_select "a[href*='id=#{app[:package_name]}'][href*='referrer=']", text: "Google Play에서 설치"
    end
  end

  test "held app does not get an indexable installation page" do
    get play_app_path("secret-signal")

    assert_response :not_found
  end

  test "app feed contains every production app" do
    get play_apps_feed_path(format: :rss)

    assert_response :success
    assert_equal "application/rss+xml", response.media_type
    assert_equal 37, response.body.scan("<item>").length
    assert_includes response.body, "com.mulmi.ridecue"
    assert_not_includes response.body, "com.bodeum.party.secretsignal"
  end

  test "support center lists HaruScene links" do
    get app_support_path

    assert_response :success
    assert_select "#haruscene h4", "Daily Scene - AI Story Chat"
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
    assert_select "#whymetric .support-chip", "com.bodeum.whymetric"
    assert_select "a[href=?]", whymetric_support_path, text: "지원 페이지"
    assert_select "a[href=?]", whymetric_privacy_path, text: "개인정보처리방침"
  end

  test "WHYMETRIC privacy and support pages render diagnostic and AdMob disclosures" do
    get whymetric_privacy_path
    assert_response :success
    assert_select "title", "WHYMETRIC 개인정보처리방침"
    assert_select "link[rel='canonical'][href=?]", whymetric_privacy_url
    assert_select "code", "com.bodeum.whymetric"
    assert_select "li", text: /Google Mobile Ads SDK/
    assert_select "li", text: /진단 측정값과 광고 식별자를 결합하지 않습니다/

    get whymetric_support_path
    assert_response :success
    assert_select "title", "WHYMETRIC 지원"
    assert_select "link[rel='canonical'][href=?]", whymetric_support_url
    assert_select "h1", "WHYMETRIC 지원"
    assert_select "li", text: /온도 여유도/
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
    assert_select "p", text: /“익명 분석 허용”을 별도로 선택한 경우에만 Firebase Analytics/

    get secret_signal_privacy_path
    assert_response :success
    assert_select "title", "Secret Signal Party 개인정보처리방침"
    assert_select "code", "com.bodeum.party.secretsignal"
    assert_select "li", text: /커스텀 카드 팩/
    assert_select "p", text: /비밀 역할, 단서와 투표 내용은 보내지 않습니다/

    get tap_arena_privacy_path
    assert_response :success
    assert_select "title", "Tap Arena 4 개인정보처리방침"
    assert_select "code", "com.bodeum.party.taparena4"
    assert_select "li", text: /best-of-5/
    assert_select "p", text: /멀티터치 원시 입력과 상세 점수는 보내지 않습니다/
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
