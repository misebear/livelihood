# frozen_string_literal: true

require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "sitemap includes benefit category landing pages" do
    get sitemap_path(format: :xml)

    assert_response :success
    assert_includes response.body, benefits_url(category: "기초급여").gsub("&", "&amp;")
    assert_includes response.body, benefit_url(benefits(:housing_benefit))
    assert_includes response.body, guide_url(SeoGuide.find!("livelihood-benefit-payment-date"))
  end
end
