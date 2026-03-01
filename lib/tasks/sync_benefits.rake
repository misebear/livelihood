# frozen_string_literal: true

# 복지 혜택 데이터 동기화 Rake 태스크
# 사용법:
#   rails sync:benefits          — 전체 동기화 (API + 크롤링 + 중복제거)
#   rails sync:api               — 공공데이터포털 4개 API 동기화
#   rails sync:scrape            — 포털 크롤링만
#   rails sync:seed_only         — 시드 데이터만 재실행
#   rails sync:dedup             — 중복 제거만
#   rails sync:status            — 현재 데이터 현황 확인
#
# 매일 자동 실행: Windows 작업 스케줄러 "LiveliBenefitSync" (매일 04:00)

namespace :sync do
  desc "전체 동기화: 4개 API + 6개 포털 크롤링 + 중복제거"
  task benefits: :environment do
    puts "🔄 복지 혜택 전체 동기화 시작..."
    puts ""

    # 1. 공공데이터포털 4개 API
    puts "📡 [1/3] 공공데이터포털 멀티 API 동기화 (4개 API)..."
    api_result = PublicDataSyncService.call
    if api_result[:apis]
      api_result[:apis].each do |name, result|
        status_icon = result[:status] == :success ? "✅" : "⚠️"
        puts "  #{status_icon} #{name}: #{result[:synced] || 0}건"
      end
    else
      puts "  ⏭️ #{api_result[:reason]}"
    end

    # 2. 복지 포털 크롤링 (6개 포털)
    puts ""
    puts "🌐 [2/3] 복지 포털 크롤링 (6개 포털)..."
    scrape_result = WelfarePortalScraperService.call
    scrape_result.each do |name, result|
      status_icon = result[:status] == :success ? "✅" : "⚠️"
      puts "  #{status_icon} #{name}: #{result[:synced] || result[:message]}"
    end

    # 3. 중복 제거
    puts ""
    puts "🧹 [3/3] 중복 제거 & 데이터 정제..."
    dedup_result = BenefitDeduplicationService.call
    puts "  → 삭제: #{dedup_result[:removed]}, 병합: #{dedup_result[:merged]}, 정리: #{dedup_result[:cleaned]}"

    # 최종 통계
    puts ""
    puts "━" * 50
    puts "✅ 동기화 완료!"
    puts "  총 혜택: #{Benefit.count}건"
    puts "  카테고리별:"
    Benefit.group(:category).count.sort_by { |_, v| -v }.each do |cat, count|
      icon = Benefit::CATEGORIES.dig(cat, :icon) || "📋"
      puts "    #{icon} #{cat || '미분류'}: #{count}건"
    end
    puts ""
    puts "  소스별:"
    Benefit.group(:source).count.sort_by { |_, v| -v }.each do |src, count|
      puts "    📦 #{src || 'unknown'}: #{count}건"
    end
  end

  desc "공공데이터포털 4개 API 동기화"
  task api: :environment do
    puts "📡 공공데이터포털 4개 API 동기화..."
    result = PublicDataSyncService.call
    if result[:apis]
      result[:apis].each { |name, r| puts "  #{name}: #{r}" }
    end
    puts "총: #{result[:total_synced] || 0}건"
  end

  desc "복지 포털 크롤링 (6개 포털)"
  task scrape: :environment do
    result = WelfarePortalScraperService.call
    result.each { |name, r| puts "#{name}: #{r}" }
  end

  desc "시드 데이터 재실행"
  task seed_only: :environment do
    Rake::Task["db:seed"].invoke
  end

  desc "중복 제거"
  task dedup: :environment do
    result = BenefitDeduplicationService.call
    puts "중복 제거: #{result}"
  end

  desc "현재 데이터 현황"
  task status: :environment do
    puts "📊 복지 혜택 데이터 현황"
    puts "  총: #{Benefit.count}건"
    puts ""
    puts "  카테고리별:"
    Benefit.group(:category).count.sort_by { |_, v| -v }.each do |cat, count|
      icon = Benefit::CATEGORIES.dig(cat, :icon) || "📋"
      puts "    #{icon} #{cat || '미분류'}: #{count}건"
    end
    puts ""
    puts "  소스별:"
    Benefit.group(:source).count.sort_by { |_, v| -v }.each do |src, count|
      puts "    📦 #{src || 'unknown'}: #{count}건"
    end
  end
end
