# frozen_string_literal: true

# 공공데이터포털 (data.go.kr) 복지서비스 멀티 API 동기화 서비스
# 환경변수: DATA_GO_KR_API_KEY가 설정되어야 동작합니다.
# 무료 API — 일일 트래픽 한도 존재 (개발 100건, 운영 확대 가능)
#
# 연동 API 목록:
# 1. 한국사회보장정보원_중앙부처복지서비스 — 핵심 복지 급여
# 2. 한국사회보장정보원_지자체복지서비스 — 지역별 복지 혜택
# 3. 한국사회보장정보원_사회서비스 제공기관 정보 — 신청 기관
# 4. 한국사회보장정보원_장애인편의시설 현황 — 장애인 시설 정보
class PublicDataSyncService
  # ── API 엔드포인트 정의 ─────────────────────────────────────
  APIS = [
    {
      name: "중앙부처복지서비스",
      url: "http://apis.data.go.kr/B554287/LocalGovernmentWelfareInformations/LcgvWelfarelist",
      parser: :parse_welfare_items,
      category_default: "기초급여",
      max_pages: 5
    },
    {
      name: "지자체복지서비스",
      url: "http://apis.data.go.kr/B554287/LocalGovernmentWelfareInformations/LcgvWelfarelist",
      parser: :parse_welfare_items,
      category_default: "지역특화",
      # 지자체 API는 다른 파라미터로 호출
      extra_params: { "lifeArray" => "006", "trgterIndvdlArray" => "0100002" },
      max_pages: 3
    },
    {
      name: "사회서비스 제공기관",
      url: "http://apis.data.go.kr/B554287/SocialServiceProvider/SocialServiceProviderList",
      parser: :parse_provider_items,
      category_default: "건강·의료",
      max_pages: 2
    },
    {
      name: "장애인편의시설",
      url: "http://apis.data.go.kr/B554287/DisabledPersonConvFacInfoService/getDisConvFacList",
      parser: :parse_facility_items,
      category_default: "건강·의료",
      max_pages: 2
    }
  ].freeze

  def self.call
    new.sync_all
  end

  def sync_all
    api_key = ENV["DATA_GO_KR_API_KEY"]
    unless api_key.present?
      Rails.logger.info "[PublicDataSync] DATA_GO_KR_API_KEY 미설정 — API 동기화 건너뜀"
      return { status: :skipped, reason: "API 키 미설정", apis: {} }
    end

    Rails.logger.info "[PublicDataSync] 공공데이터포털 멀티 API 동기화 시작 (#{APIS.size}개 API)..."
    results = {}

    APIS.each do |api_config|
      result = sync_single_api(api_key, api_config)
      results[api_config[:name]] = result
      Rails.logger.info "[PublicDataSync] #{api_config[:name]}: #{result[:status]} (#{result[:synced]}건)"
    rescue StandardError => e
      Rails.logger.error "[PublicDataSync] #{api_config[:name]} 전체 실패: #{e.message}"
      results[api_config[:name]] = { status: :error, message: e.message, synced: 0 }
    end

    total = results.values.sum { |r| r[:synced] || 0 }
    Rails.logger.info "[PublicDataSync] 전체 완료: #{total}건 동기화"
    { status: :success, total_synced: total, apis: results }
  end

  private

  # ── 개별 API 동기화 ──────────────────────────────────────────
  def sync_single_api(api_key, config)
    synced = 0
    page = 1
    max_pages = config[:max_pages] || 3

    loop do
      response = fetch_page(api_key, config, page)
      break unless response

      items = send(config[:parser], response)
      break if items.empty?

      items.each do |item|
        upsert_benefit(item, config)
        synced += 1
      end

      break if page >= max_pages
      page += 1

      # API 부하 방지: 페이지 간 0.5초 대기
      sleep(0.5)
    end

    { status: :success, synced: synced }
  end

  # ── HTTP 요청 ────────────────────────────────────────────────
  def fetch_page(api_key, config, page)
    params = {
      "serviceKey" => api_key,
      "pageNo" => page.to_s,
      "numOfRows" => "100",
      "type" => "json"
    }
    params.merge!(config[:extra_params]) if config[:extra_params]

    url = "#{config[:url]}?#{URI.encode_www_form(params)}"

    response = HTTParty.get(url, timeout: 30, headers: {
      "Accept" => "application/json"
    })

    return nil unless response.code == 200

    # JSON 또는 XML 파싱 시도
    body = response.body
    begin
      JSON.parse(body)
    rescue JSON::ParserError
      # XML 응답인 경우 Nokogiri로 파싱
      parse_xml_response(body)
    end
  rescue StandardError => e
    Rails.logger.error "[PublicDataSync] API 호출 실패 (#{config[:name]}, page #{page}): #{e.message}"
    nil
  end

  # ── XML 응답 파싱 (JSON 실패 시 폴백) ────────────────────────
  def parse_xml_response(xml_body)
    doc = Nokogiri::XML(xml_body)
    items = doc.xpath("//item")
    return nil if items.empty?

    # XML을 Hash 배열로 변환
    parsed_items = items.map do |item|
      hash = {}
      item.children.each do |child|
        hash[child.name] = child.text if child.element?
      end
      hash
    end

    { "response" => { "body" => { "items" => { "item" => parsed_items } } } }
  end

  # ── 파서: 복지서비스 (중앙부처 / 지자체) ──────────────────────
  def parse_welfare_items(response)
    items = response.dig("response", "body", "items", "item")
    return [] unless items.is_a?(Array)

    items.map do |item|
      {
        external_id: item["servId"] || item["wlfareInfoId"],
        title: item["servNm"] || item["wlfareInfoNm"],
        summary: item["servDgst"] || item["wlfareInfoDtlCn"],
        target_group: item["trgterIndvdlArray"] || item["sprtTrgterCn"],
        support_amount: item["sprtCycNm"] || item["slctCritCn"],
        apply_url: item["servDtlLink"] || item["inqplUrl"],
        provider: item["jurMnofNm"] || item["jurOrgNm"],
        apply_period: item["aplyMtdCn"]
      }
    end.select { |i| i[:title].present? }
  rescue StandardError
    []
  end

  # ── 파서: 사회서비스 제공기관 ─────────────────────────────────
  def parse_provider_items(response)
    items = response.dig("response", "body", "items", "item")
    return [] unless items.is_a?(Array)

    items.map do |item|
      {
        external_id: item["provdInsttId"] || item["insttId"],
        title: item["insttNm"].to_s + " (사회서비스)",
        summary: "#{item['svcTpNm']} 서비스 제공기관. #{item['insttAddr']}",
        target_group: item["svcTpNm"],
        provider: item["insttNm"],
        apply_url: "https://www.bokjiro.go.kr"
      }
    end.select { |i| i[:title].present? }
  rescue StandardError
    []
  end

  # ── 파서: 장애인편의시설 ──────────────────────────────────────
  def parse_facility_items(response)
    items = response.dig("response", "body", "items", "item")
    return [] unless items.is_a?(Array)

    items.map do |item|
      {
        external_id: item["wfcltId"] || item["facilityId"],
        title: item["wfcltNm"] || item["fcltNm"],
        summary: "장애인 편의시설. #{item['rdnmadr'] || item['lnmadr']}",
        target_group: "장애인 (편의시설)",
        provider: item["wfcltNm"] || item["fcltNm"]
      }
    end.select { |i| i[:title].present? }
  rescue StandardError
    []
  end

  # ── Benefit 모델 upsert ──────────────────────────────────────
  def upsert_benefit(item, config)
    ext_id = "API_#{config[:name].gsub(/\s/, '_')}_#{item[:external_id] || Digest::MD5.hexdigest(item[:title].to_s)}"
    title = item[:title].to_s.strip
    return if title.blank?

    benefit = Benefit.find_or_initialize_by(external_id: ext_id)

    # 시드 데이터(source: "seed")는 절대 덮어쓰지 않음
    return if benefit.persisted? && benefit.source == "seed"

    benefit.assign_attributes(
      title: title.truncate(200),
      summary: item[:summary].to_s.strip.truncate(500).presence,
      category: categorize_service(item, config[:category_default]),
      target_group: item[:target_group].to_s.strip.truncate(300).presence,
      support_amount: item[:support_amount].to_s.strip.truncate(200).presence,
      apply_url: item[:apply_url].to_s.strip.presence || "https://www.bokjiro.go.kr",
      apply_period: item[:apply_period].to_s.strip.truncate(200).presence,
      provider: item[:provider].to_s.strip.truncate(100).presence || config[:name],
      source: "data.go.kr:#{config[:name]}",
      last_synced_at: Time.current
    )

    benefit.save!
  rescue StandardError => e
    Rails.logger.warn "[PublicDataSync] 항목 저장 실패 (#{title}): #{e.message}"
  end

  # ── 자동 카테고리 분류 ──────────────────────────────────────
  def categorize_service(item, default_category)
    name = item[:title].to_s
    case name
    when /생계급여|기초생활|국민기초/ then "기초급여"
    when /의료급여|건강보험|의료비/ then "건강·의료"
    when /주거급여|임대|전세|주택|주거/ then "주거"
    when /교육급여|장학|학자|교육/ then "교육·문화"
    when /저축|자산|자립|키움|희망/ then "자산형성"
    when /감면|할인|면제|비과세|수수료/ then "감면·할인"
    when /바우처|이용권|카드|누리/ then "바우처"
    when /긴급|위기/ then "긴급지원"
    when /출산|아동|부모|양육|영아|한부모/ then "출산·가족"
    when /대출|금융|햇살|미소/ then "금융서비스"
    when /장애|편의시설/ then "건강·의료"
    else default_category
    end
  end
end
