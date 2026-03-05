# frozen_string_literal: true

# 복지로 API 동기화 Rake 태스크
# 사용법: bundle exec rake benefits:sync
namespace :benefits do
  desc "복지로 공공데이터포털 API에서 복지 서비스 데이터 동기화"
  task sync: :environment do
    puts "🔄 복지로 API 동기화 시작..."
    result = BenefitSyncService.new.sync_all
    puts "✅ 동기화 완료: 총 #{result[:synced]}건 (신규 #{result[:created]}, 갱신 #{result[:updated]})"
  rescue => e
    puts "❌ 동기화 실패: #{e.message}"
    Rails.logger.error "[BenefitSync] #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
    exit 1
  end
end
