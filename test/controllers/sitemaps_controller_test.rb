# frozen_string_literal: true

require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "sitemap includes benefit category landing pages" do
    get sitemap_path(format: :xml)

    assert_response :success
    assert_includes response.body, benefits_url(category: "기초급여").gsub("&", "&amp;")
    assert_includes response.body, benefit_url(benefits(:housing_benefit))
    assert_includes response.body, guide_url(SeoGuide.find!("livelihood-benefit-payment-date"))
    assert_includes response.body, editorial_policy_url
    assert_includes response.body, haruscene_privacy_url
    assert_includes response.body, haruscene_support_url
    assert_includes response.body, batang_issue_privacy_url
    assert_includes response.body, batang_issue_support_url
    assert_includes response.body, rush_pass_privacy_url
    assert_includes response.body, rush_pass_support_url
    assert_includes response.body, secret_signal_privacy_url
    assert_includes response.body, secret_signal_support_url
    assert_includes response.body, tap_arena_privacy_url
    assert_includes response.body, tap_arena_support_url
    assert_includes response.body, whymetric_privacy_url
    assert_includes response.body, whymetric_support_url
    PlayAppCatalog.active.each do |app|
      assert_includes response.body, play_app_url(app[:slug])
    end
    assert_not_includes response.body, play_app_url("secret-signal")
  end
end
