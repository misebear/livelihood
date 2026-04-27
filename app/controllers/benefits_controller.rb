# frozen_string_literal: true

# 혜택 목록/상세 — 로그인 없이도 전체 조회 가능
class BenefitsController < ApplicationController
  # 로그인 필수 제거 — 누구나 혜택 목록 조회 가능
  PAGE_SIZE = 40
  CATEGORY_PREVIEW_LIMIT = 8

  def index
    @current_category = params[:category]
    @search_query = params[:q]
    @categories = Benefit::CATEGORIES
    @safe_savings = Benefit.safe_savings_products
    @page = [ params[:page].to_i, 1 ].max

    base = Benefit.prioritized.search(@search_query)
    scoped = @current_category.present? ? base.by_category(@current_category) : base

    if @search_query.present? || @current_category.present?
      @paged = true
      @total_count = scoped.count
      @total_pages = [ (@total_count.to_f / PAGE_SIZE).ceil, 1 ].max
      @page = @total_pages if @page > @total_pages
      @benefits = scoped.offset((@page - 1) * PAGE_SIZE).limit(PAGE_SIZE).to_a
      @grouped_benefits = ordered_groups(@benefits)
    else
      @paged = false
      @total_count = Benefit.count
      @category_counts = Benefit.group(:category).count
      @uncategorized_count = base.where("category IS NULL OR category NOT IN (?)", Benefit::CATEGORIES.keys).count
      @grouped_benefits = category_preview_groups(base)
    end
  end

  def show
    @benefit = Benefit.find(params[:id])
    # 로그인한 사용자만 관심 혜택 상태 표시
    @user_benefit = current_user&.user_benefits&.find_by(benefit: @benefit)
  end

  private

  def ordered_groups(benefits)
    raw_groups = benefits.group_by(&:category)
    category_order = Benefit::CATEGORIES.keys
    ordered = category_order
      .select { |cat| raw_groups.key?(cat) }
      .map { |cat| [ cat, raw_groups[cat] ] }
      .to_h
    raw_groups.each { |cat, items| ordered[cat] ||= items }
    ordered
  end

  def category_preview_groups(base)
    groups = {}
    Benefit::CATEGORIES.each_key do |category|
      items = base.by_category(category).limit(CATEGORY_PREVIEW_LIMIT).to_a
      groups[category] = items if items.any?
    end
    uncategorized = base.where("category IS NULL OR category NOT IN (?)", Benefit::CATEGORIES.keys).limit(CATEGORY_PREVIEW_LIMIT).to_a
    groups["기타"] = uncategorized if uncategorized.any?
    groups
  end
end
