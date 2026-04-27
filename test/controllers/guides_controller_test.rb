# frozen_string_literal: true

require "test_helper"

class GuidesControllerTest < ActionDispatch::IntegrationTest
  test "index renders public guide cards and SEO metadata" do
    get guides_path

    assert_response :success
    assert_select "title", "기초생활수급자 복지 가이드 — 보듬"
    assert_select "link[rel='canonical'][href=?]", guides_url
    assert_select "a.guide-card", minimum: 6
  end

  test "show renders guide content with structured data and official sources" do
    guide = SeoGuide.find!("livelihood-benefit-payment-date")

    get guide_path(guide)

    assert_response :success
    assert_select "title", "#{guide.title} — 보듬"
    assert_select "link[rel='canonical'][href=?]", guide_url(guide)
    assert_select "script[type='application/ld+json']", minimum: 4
    assert_select ".guide-threshold-table", text: /820,556원/
    assert_select ".guide-source-list a", text: /국가법령정보센터/
  end

  test "unknown guide returns not found" do
    get guide_path("unknown-guide")

    assert_response :not_found
  end
end
