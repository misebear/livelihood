# frozen_string_literal: true

# 복지로 공공데이터포털 API에서 복지 서비스 데이터를 가져와 DB에 동기화
class BenefitSyncService
  BASE_URL = "https://apis.data.go.kr/B554287/NationalWelfareInformationsV001/NationalWelfarelistV001"
  PER_PAGE = 100

  # 관심 테마 → 보듬 카테고리 매핑
  THEME_TO_CATEGORY = {
    "생활지원"     => "기초급여",
    "주거"         => "주거",
    "보육"         => "출산·가족",
    "보호·돌봄"    => "출산·가족",
    "임신·출산"    => "출산·가족",
    "교육"         => "교육·문화",
    "문화·여가"    => "교육·문화",
    "취업"         => "교육·문화",
    "일자리"       => "교육·문화",
    "신체건강"     => "건강·의료",
    "정신건강"     => "건강·의료",
    "서민금융"     => "금융서비스",
    "안전·위기"    => "긴급지원",
    "법률·권익보호" => "감면·할인"
  }.freeze

  # 대상자 키워드 → 카테고리 보조 매핑
  TARGET_HINTS = {
    "장애인"     => "감면·할인",
    "저소득"     => "기초급여",
    "한부모"     => "출산·가족",
    "다문화"     => "출산·가족",
    "임산부"     => "출산·가족",
    "노인"       => "건강·의료",
    "청년"       => "자산형성"
  }.freeze

  def initialize(api_key = nil)
    @api_key = api_key || ENV["BOKJIRO_API_KEY"]
    raise "BOKJIRO_API_KEY 환경변수가 설정되지 않았습니다" if @api_key.blank?
  end

  # 전체 동기화 실행
  def sync_all
    Rails.logger.info "[BenefitSync] 복지로 API 동기화 시작..."
    page = 1
    total_synced = 0
    total_created = 0
    total_updated = 0

    loop do
      items = fetch_page(page)
      break if items.empty?

      items.each do |item|
        result = upsert_benefit(item)
        total_synced += 1
        total_created += 1 if result == :created
        total_updated += 1 if result == :updated
      end

      Rails.logger.info "[BenefitSync] 페이지 #{page} 처리 완료 (#{items.size}건)"
      break if items.size < PER_PAGE

      page += 1
      sleep(0.3) # API 과부하 방지
    end

    Rails.logger.info "[BenefitSync] 동기화 완료: 총 #{total_synced}건 (신규 #{total_created}, 갱신 #{total_updated})"
    { synced: total_synced, created: total_created, updated: total_updated }
  end

  private

  # API 페이지 호출
  def fetch_page(page_no)
    response = HTTParty.get(BASE_URL, query: {
      serviceKey: @api_key,
      callTp: "L",
      pageNo: page_no,
      numOfRows: PER_PAGE,
      srchKeyCode: "003"
    }, timeout: 30)

    return [] unless response.success?

    body = response.parsed_response
    list = body.dig("wantedList", "servList")
    return [] if list.nil?

    # 단일 항목이면 배열로 감싸기
    list.is_a?(Array) ? list : [list]
  rescue StandardError => e
    Rails.logger.error "[BenefitSync] API 호출 실패 (페이지 #{page_no}): #{e.message}"
    []
  end

  # DB에 upsert
  def upsert_benefit(item)
    ext_id = item["servId"]
    return nil if ext_id.blank?

    benefit = Benefit.find_or_initialize_by(external_id: ext_id)
    is_new = benefit.new_record?

    benefit.assign_attributes(
      title: item["servNm"].to_s.strip,
      summary: item["servDgst"].to_s.strip,
      target_group: item["trgterIndvdlArray"].to_s.strip.presence,
      provider: item["jurMnofNm"].to_s.strip.presence,
      apply_url: clean_url(item["servDtlLink"]),
      category: detect_category(item),
      support_amount: detect_support_type(item),
      source: "bokjiro_api",
      last_synced_at: Time.current
    )

    benefit.save!
    is_new ? :created : :updated
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn "[BenefitSync] 저장 실패 (#{ext_id}): #{e.message}"
    nil
  end

  # 테마 배열에서 카테고리 추론
  def detect_category(item)
    themes = item["intrsThemaArray"].to_s.split(",").map(&:strip)

    # 1차: 테마 기반 매핑
    themes.each do |theme|
      return THEME_TO_CATEGORY[theme] if THEME_TO_CATEGORY.key?(theme)
    end

    # 2차: 대상자 힌트
    targets = item["trgterIndvdlArray"].to_s
    TARGET_HINTS.each do |keyword, cat|
      return cat if targets.include?(keyword)
    end

    # 3차: 지원 형태 기반
    pvsn = item["srvPvsnNm"].to_s
    return "감면·할인" if pvsn.include?("감면") || pvsn.include?("할인")
    return "금융서비스" if pvsn.include?("융자") || pvsn.include?("대여")

    # 기본값
    "기초급여"
  end

  # 지원 형태 텍스트
  def detect_support_type(item)
    pvsn = item["srvPvsnNm"].to_s.strip
    cycle = item["sprtCycNm"].to_s.strip
    return nil if pvsn.blank?

    parts = [pvsn]
    parts << "(#{cycle})" if cycle.present? && cycle != "수시"
    parts.join(" ")
  end

  # URL 정리 (&amp; → &)
  def clean_url(url)
    url.to_s.gsub("&amp;", "&").strip.presence
  end
end
