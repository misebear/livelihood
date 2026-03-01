# frozen_string_literal: true

class BenefitsController < ApplicationController
  before_action :authenticate_user!

  def index
    @current_category = params[:category]
    @categories = Benefit::CATEGORIES
    @safe_savings = Benefit.safe_savings_products

    base = Benefit.prioritized
    if @current_category.present?
      @benefits = base.by_category(@current_category)
    else
      @benefits = base
    end

    # 카테고리를 CATEGORIES 상수 순서(중요도)로 고정 정렬
    raw_groups = @benefits.group_by(&:category)
    category_order = Benefit::CATEGORIES.keys
    @grouped_benefits = category_order
      .select { |cat| raw_groups.key?(cat) }
      .map { |cat| [cat, raw_groups[cat]] }
      .to_h
    # CATEGORIES에 없는 카테고리 마지막에 추가
    raw_groups.each { |cat, items| @grouped_benefits[cat] ||= items }

    @total_count = Benefit.count
  end

  def show
    @benefit = Benefit.find(params[:id])
    @user_benefit = current_user.user_benefits.find_by(benefit: @benefit)
  end
end
