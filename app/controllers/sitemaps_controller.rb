class SitemapsController < ApplicationController
  def show
    @pages = [
      { url: root_url, lastmod: Date.today, changefreq: "daily", priority: 1.0 },
      { url: benefits_url, lastmod: Date.today, changefreq: "daily", priority: 0.9 }
    ]

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
