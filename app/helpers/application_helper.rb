module ApplicationHelper
  DEFAULT_META_TITLE = "보듬 - 기초생활수급자 복지 혜택, 현금흐름, 수급 안전선 관리"
  DEFAULT_META_DESCRIPTION = "기초생활수급자와 차상위계층을 위한 복지 혜택 검색, 생계급여 입금일, 현금흐름 관리, 수급 탈락 방지 안전선 계산 서비스"

  def meta_title
    content_for?(:title) ? content_for(:title).to_s : DEFAULT_META_TITLE
  end

  def meta_description
    content_for?(:description) ? content_for(:description).to_s : DEFAULT_META_DESCRIPTION
  end

  def canonical_url
    content_for?(:canonical_url) ? content_for(:canonical_url).to_s : "#{request.base_url}#{request.path}"
  end

  def meta_robots
    content_for?(:robots) ? content_for(:robots).to_s : "index,follow,max-image-preview:large"
  end

  def meta_image_url
    "#{request.base_url}/icon.png"
  end

  def analytics_measurement_id
    ENV["GA_MEASUREMENT_ID"].presence || ENV["GOOGLE_ANALYTICS_ID"].presence
  end

  def site_json_ld
    {
      "@context": "https://schema.org",
      "@type": "WebApplication",
      name: "보듬",
      alternateName: "Bodeum",
      applicationCategory: "FinanceApplication",
      operatingSystem: "Web, Android",
      url: root_url,
      inLanguage: "ko-KR",
      description: DEFAULT_META_DESCRIPTION,
      offers: {
        "@type": "Offer",
        price: "0",
        priceCurrency: "KRW"
      }
    }
  end
end
