# frozen_string_literal: true

require "test_helper"

class BenefitsControllerTest < ActionDispatch::IntegrationTest
  test "index renders canonical SEO metadata" do
    get benefits_path

    assert_response :success
    assert_select "title", "기초생활수급자 복지 혜택 검색 — 보듬"
    assert_select "link[rel='canonical'][href=?]", benefits_url
    assert_select "meta[property='og:title'][content=?]", "기초생활수급자 복지 혜택 검색 — 보듬"
  end

  test "category pages are paginated" do
    42.times do |i|
      Benefit.create!(
        external_id: "PAGE-#{i}",
        title: "테스트 혜택 #{i}",
        category: "기초급여",
        summary: "페이지네이션 검증용 혜택"
      )
    end

    get benefits_path(category: "기초급여")

    assert_response :success
    assert_select "a.benefit-card", count: 40
    assert_select ".pagination-status", "1 / 2"

    get benefits_path(category: "기초급여", page: 2)

    assert_response :success
    assert_select "a.benefit-card", count: 2
    assert_select ".pagination-status", "2 / 2"
  end

  test "empty search is noindexed and shows a clear empty state" do
    get benefits_path(q: "검색결과없음")

    assert_response :success
    assert_select "meta[name='robots'][content='noindex,follow']"
    assert_select ".empty-state", text: /검색 결과가 없습니다/
  end

  test "guest sees login cta instead of interest post form" do
    benefit = benefits(:housing_benefit)

    get benefit_path(benefit)

    assert_response :success
    assert_select "a", text: "로그인하고 관심 등록하기"
    assert_select "form[action^='#{user_benefits_path}']", false
  end
end
