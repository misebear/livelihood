# frozen_string_literal: true

# ────────────────────────────────────────────────────────────────
# BenefitApiSyncWorker (Sidekiq)
# ────────────────────────────────────────────────────────────────
# 행정안전부/한국사회보장정보원 OpenAPI를 주 1회 동기화하여
# benefits 테이블을 Upsert한다.
#
# [매우 중요 - 방어 로직]
# 공공 API의 응답 스펙(필드명)이 예고 없이 변경될 수 있으므로:
#   1. JSON 파싱 시 KeyError/NoMethodError를 rescue
#   2. 개별 레코드 실패 시에도 나머지는 계속 처리
#   3. 에러 발생 시 Logger + Slack Webhook으로 Admin 알람
#   4. 전체 API 호출 실패 시에도 Job이 터지지 않음
# ────────────────────────────────────────────────────────────────
class BenefitApiSyncWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 3

  # 공공 API 엔드포인트 (한국사회보장정보원 예시)
  API_BASE_URL = "https://api.odcloud.kr/api".freeze

  # 필수 필드 매핑 (API 스펙 변경 감지용)
  REQUIRED_FIELDS = %w[서비스ID 서비스명 서비스내용요약 신청URL].freeze

  def perform
    Rails.logger.info "[BenefitApiSync] 동기화 시작"

    response = fetch_api_data
    return unless response

    items = parse_response(response)
    return if items.nil?

    sync_stats = { created: 0, updated: 0, skipped: 0, errors: [] }

    items.each_with_index do |item, index|
      process_item(item, index, sync_stats)
    end

    log_results(sync_stats)
    notify_admin_if_errors(sync_stats) if sync_stats[:errors].any?

    Rails.logger.info "[BenefitApiSync] 동기화 완료: " \
      "생성 #{sync_stats[:created]}, 수정 #{sync_stats[:updated]}, " \
      "건너뜀 #{sync_stats[:skipped]}, 에러 #{sync_stats[:errors].size}"
  rescue StandardError => e
    # 전체 Job 레벨 방어: 절대 터지지 않음
    handle_critical_error(e)
  end

  private

  # ── API 호출 ────────────────────────────────────────────────
  def fetch_api_data
    api_key = Rails.application.credentials.dig(:benefit_api, :key) || ENV["BENEFIT_API_KEY"]

    unless api_key
      Rails.logger.warn "[BenefitApiSync] API 키가 설정되지 않았습니다. 시드 데이터로 대체합니다."
      return nil
    end

    response = HTTParty.get(
      "#{API_BASE_URL}/15083323/v1/uddi:7df22cd2-b2da-43f8-9192-0e6e8e2f4ba1",
      query: { page: 1, perPage: 500, serviceKey: api_key },
      headers: { "Accept" => "application/json" },
      timeout: 30
    )

    unless response.success?
      error_msg = "[BenefitApiSync] API 호출 실패: HTTP #{response.code}"
      Rails.logger.error error_msg
      notify_admin(error_msg)
      return nil
    end

    response
  rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED => e
    error_msg = "[BenefitApiSync] API 연결 실패: #{e.class} - #{e.message}"
    Rails.logger.error error_msg
    notify_admin(error_msg)
    nil
  end

  # ── 응답 파싱 (스펙 변경 감지) ──────────────────────────────
  def parse_response(response)
    body = response.parsed_response
    items = body.dig("data") || body.dig("result") || body.dig("items")

    if items.nil? || !items.is_a?(Array)
      error_msg = "[BenefitApiSync] ⚠️ API 응답 구조 변경 감지! " \
        "예상 키(data/result/items)가 없습니다. " \
        "응답 최상위 키: #{body.keys.inspect}"
      Rails.logger.error error_msg
      notify_admin(error_msg)
      return nil
    end

    # 필수 필드 존재 여부 검증 (첫 번째 아이템 기준)
    if items.any?
      first_item = items.first
      missing_fields = REQUIRED_FIELDS.reject { |f| first_item.key?(f) }

      if missing_fields.any?
        error_msg = "[BenefitApiSync] ⚠️ API 스펙 변경 감지! " \
          "누락 필드: #{missing_fields.join(', ')}. " \
          "실제 필드: #{first_item.keys.inspect}"
        Rails.logger.error error_msg
        notify_admin(error_msg)
        # 스펙 변경이어도 가능한 필드로 계속 처리 시도
      end
    end

    items
  rescue JSON::ParserError => e
    error_msg = "[BenefitApiSync] JSON 파싱 실패: #{e.message}"
    Rails.logger.error error_msg
    notify_admin(error_msg)
    nil
  end

  # ── 개별 레코드 처리 (Upsert) ───────────────────────────────
  def process_item(item, index, stats)
    external_id = item["서비스ID"] || item["serviceId"] || item["id"]

    unless external_id.present?
      stats[:skipped] += 1
      Rails.logger.debug "[BenefitApiSync] ##{index} 건너뜀: external_id 없음"
      return
    end

    benefit = Benefit.find_or_initialize_by(external_id: external_id.to_s)

    benefit.assign_attributes(
      title:           extract_field(item, %w[서비스명 serviceName title]),
      summary:         extract_field(item, %w[서비스내용요약 serviceDescription summary]),
      apply_url:        extract_field(item, %w[신청URL applyUrl url]),
      is_safe_savings: detect_safe_savings(item)
    )

    if benefit.new_record?
      benefit.save!
      stats[:created] += 1
    elsif benefit.changed?
      benefit.save!
      stats[:updated] += 1
    else
      stats[:skipped] += 1
    end
  rescue ActiveRecord::RecordInvalid => e
    stats[:errors] << { index: index, external_id: external_id, error: e.message }
    Rails.logger.warn "[BenefitApiSync] ##{index} 저장 실패: #{e.message}"
  rescue StandardError => e
    stats[:errors] << { index: index, error: "#{e.class}: #{e.message}" }
    Rails.logger.warn "[BenefitApiSync] ##{index} 처리 실패: #{e.class} - #{e.message}"
  end

  # ── 유틸리티 ────────────────────────────────────────────────

  # 다양한 필드명 후보 중 존재하는 값 추출 (스펙 변경 대응)
  def extract_field(item, candidates)
    candidates.each do |key|
      return item[key] if item.key?(key) && item[key].present?
    end
    nil
  end

  # 정부매칭 저축통장 여부 감지 (키워드 기반)
  SAFE_SAVINGS_KEYWORDS = %w[
    희망저축 내일키움 청년저축 자산형성 디딤씨앗 꿈나래
    내일채움 자산관리 매칭저축 탈수급
  ].freeze

  def detect_safe_savings(item)
    text = [
      extract_field(item, %w[서비스명 serviceName title]),
      extract_field(item, %w[서비스내용요약 serviceDescription summary])
    ].compact.join(" ")

    SAFE_SAVINGS_KEYWORDS.any? { |kw| text.include?(kw) }
  end

  # ── 결과 로깅 ──────────────────────────────────────────────
  def log_results(stats)
    if stats[:errors].any?
      Rails.logger.warn "[BenefitApiSync] 에러 상세:\n" +
        stats[:errors].map { |e| "  - ##{e[:index]}: #{e[:error]}" }.join("\n")
    end
  end

  # ── Admin 알림 (Slack Webhook 또는 Logger) ──────────────────
  def notify_admin(message)
    # Slack Webhook이 설정된 경우
    slack_url = Rails.application.credentials.dig(:slack, :webhook_url) || ENV["SLACK_WEBHOOK_URL"]

    if slack_url.present?
      send_slack_notification(slack_url, message)
    end

    # 항상 Rails Logger에도 기록
    Rails.logger.error "[BenefitApiSync][ADMIN ALERT] #{message}"
  end

  def notify_admin_if_errors(stats)
    message = "[BenefitApiSync] 동기화 완료 (에러 #{stats[:errors].size}건)\n" \
      "생성: #{stats[:created]}, 수정: #{stats[:updated]}, 건너뜀: #{stats[:skipped]}\n" \
      "에러 목록:\n" +
      stats[:errors].first(10).map { |e| "  • ##{e[:index]}: #{e[:error]}" }.join("\n")

    notify_admin(message)
  end

  def send_slack_notification(webhook_url, message)
    HTTParty.post(
      webhook_url,
      body: { text: "🚨 #{message}" }.to_json,
      headers: { "Content-Type" => "application/json" },
      timeout: 10
    )
  rescue StandardError => e
    Rails.logger.error "[BenefitApiSync] Slack 알림 전송 실패: #{e.message}"
  end

  # ── 치명적 에러 핸들링 ──────────────────────────────────────
  def handle_critical_error(error)
    error_msg = "[BenefitApiSync] 🔴 치명적 에러 발생!\n" \
      "#{error.class}: #{error.message}\n" \
      "#{error.backtrace&.first(5)&.join("\n")}"

    Rails.logger.error error_msg
    notify_admin(error_msg)
    # Job은 터지지 않음 — Sidekiq retry를 위해 re-raise 하지 않음
  end
end
