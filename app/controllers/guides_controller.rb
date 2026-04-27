# frozen_string_literal: true

class GuidesController < ApplicationController
  def index
    @guides = SeoGuide.all
    @popular_benefits = Benefit.prioritized.limit(5)
  end

  def show
    @guide = SeoGuide.find!(params[:slug])
    @related_guides = SeoGuide.related_to(@guide).first(3)
    @related_benefits = related_benefits_for(@guide)
  end

  private

  def related_benefits_for(guide)
    scope = Benefit.prioritized
    scope = scope.by_category(guide.benefit_category) if guide.benefit_category.present?

    benefits = scope.limit(5).to_a
    return benefits if benefits.any?

    Benefit.prioritized.search(guide.benefit_query).limit(5).to_a
  end
end
