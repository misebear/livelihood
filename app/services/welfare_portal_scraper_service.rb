# frozen_string_literal: true

# 복지 포털 크롤링 서비스
# 복지로, 에너지바우처, 문화누리 등 주요 포털에서 최신 정보를 수집합니다.
# Nokogiri (Rails 기본 포함)를 사용한 HTML 파싱
class WelfarePortalScraperService
  PORTALS = [
    {
      name: "복지로",
      url: "https://www.bokjiro.go.kr/ssis-tbu/twataa/wlfareInfo/moveTWAT52011M.do",
      source: "scraper:bokjiro"
    },
    {
      name: "에너지바우처",
      url: "https://www.energyv.or.kr",
      source: "scraper:energyv"
    },
    {
      name: "문화누리카드",
      url: "https://www.mnuri.kr",
      source: "scraper:mnuri"
    },
    {
      name: "자산e룸터",
      url: "https://hope.welfareinfo.or.kr",
      source: "scraper:hope"
    },
    {
      name: "마이홈포털",
      url: "https://www.myhome.go.kr",
      source: "scraper:myhome"
    },
    {
      name: "서민금융진흥원",
      url: "https://www.kinfa.or.kr",
      source: "scraper:kinfa"
    }
  ].freeze

  def self.call
    new.scrape_all
  end

  def scrape_all
    Rails.logger.info "[WelfarePortalScraper] 복지 포털 크롤링 시작..."
    results = {}

    PORTALS.each do |portal|
      result = scrape_portal(portal)
      results[portal[:name]] = result
    rescue StandardError => e
      Rails.logger.error "[WelfarePortalScraper] #{portal[:name]} 크롤링 실패: #{e.message}"
      results[portal[:name]] = { status: :error, message: e.message }
    end

    # 마감일 갱신 (기존 데이터 중 마감 임박 여부 체크)
    update_deadlines

    Rails.logger.info "[WelfarePortalScraper] 크롤링 완료: #{results.keys.join(', ')}"
    results
  end

  private

  def scrape_portal(portal)
    response = HTTParty.get(portal[:url], timeout: 15, headers: {
      "User-Agent" => "Mozilla/5.0 (compatible; Livelihood/1.0; Welfare Data Sync)"
    })

    return { status: :http_error, code: response.code } unless response.code == 200

    doc = Nokogiri::HTML(response.body)
    items = extract_items(doc, portal)

    synced = 0
    items.each do |item|
      upsert_scraped_benefit(item, portal[:source])
      synced += 1
    end

    { status: :success, synced: synced }
  rescue StandardError => e
    { status: :error, message: e.message }
  end

  def extract_items(doc, portal)
    # 각 포털마다 HTML 구조가 다르므로 범용 추출
    # 공지사항, 모집 공고, 서비스 목록 등에서 제목+링크 추출
    items = []

    # 공통: 공지사항/모집 게시판에서 제목과 링크 추출
    doc.css("a[href]").each do |link|
      text = link.text.strip
      href = link["href"].to_s

      # 복지 관련 키워드가 포함된 링크만 선별
      next unless welfare_related?(text)
      next if text.length < 5 || text.length > 200

      items << {
        title: text.truncate(100),
        url: normalize_url(href, portal[:url]),
        source_name: portal[:name]
      }
    end

    items.uniq { |i| i[:title] }.first(20) # 포털당 최대 20건
  end

  def welfare_related?(text)
    keywords = %w[급여 수급 복지 지원 바우처 장학 감면 할인 임대 대출 저축 청년 아동 장애 의료 교육]
    keywords.any? { |kw| text.include?(kw) }
  end

  def normalize_url(href, base_url)
    return href if href.start_with?("http")
    uri = URI.parse(base_url)
    "#{uri.scheme}://#{uri.host}#{href}"
  rescue URI::InvalidURIError
    href
  end

  def upsert_scraped_benefit(item, source)
    external_id = "SCR_#{Digest::MD5.hexdigest(item[:title])}"

    benefit = Benefit.find_or_initialize_by(external_id: external_id)
    # 시드 데이터 보호
    return if benefit.persisted? && benefit.source == "seed"

    benefit.assign_attributes(
      title: item[:title],
      summary: "#{item[:source_name]}에서 수집된 공지사항입니다.",
      apply_url: item[:url],
      source: source,
      last_synced_at: Time.current
    )

    benefit.save!
  rescue StandardError => e
    Rails.logger.warn "[WelfarePortalScraper] 항목 저장 실패: #{e.message}"
  end

  def update_deadlines
    # 에너지바우처 마감일 자동 갱신 (2025.7.1 ~ 2026.5.25)
    energy = Benefit.find_by(external_id: "VOU001")
    energy&.update(deadline: Date.new(2026, 5, 25)) if energy && energy.deadline.nil?

    # 문화누리카드 마감일 (연말)
    mnuri = Benefit.find_by(external_id: "VOU002")
    mnuri&.update(deadline: Date.new(Date.current.year, 12, 31)) if mnuri && mnuri.deadline.nil?
  end
end
