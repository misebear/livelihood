class SitemapsController < ApplicationController
  def show
    latest_benefit_at = Benefit.maximum(:updated_at)&.to_date || Date.today

    @pages = [
      { url: root_url, lastmod: Date.today, changefreq: "daily", priority: 1.0 },
      { url: benefits_url, lastmod: latest_benefit_at, changefreq: "daily", priority: 0.9 }
    ]

    Benefit::CATEGORIES.each_key do |category|
      @pages << {
        url: benefits_url(category: category),
        lastmod: latest_benefit_at,
        changefreq: "weekly",
        priority: 0.85
      }
    end

    SeoGuide.all.each do |guide|
      @pages << {
        url: guide_url(guide),
        lastmod: guide.updated_on,
        changefreq: "monthly",
        priority: 0.88
      }
    end

    # 각 혜택 상세 페이지를 사이트맵에 동적 추가 (롱테일 SEO)
    Benefit.find_each do |benefit|
      @pages << {
        url: benefit_url(benefit),
        lastmod: benefit.updated_at.to_date,
        changefreq: "weekly",
        priority: 0.8
      }
    end

    respond_to do |format|
      format.xml
    end
  end
end
