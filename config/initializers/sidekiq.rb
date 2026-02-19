# frozen_string_literal: true

# Sidekiq Configuration
# Rails 서버(Puma)와 Sidekiq 프로세스 모두에서 안전하게 로드되도록
# defined? 체크 후 설정합니다.
if defined?(Sidekiq)
  Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }

    # sidekiq-cron 스케줄 등록
    if defined?(Sidekiq::Cron)
      schedule_file = Rails.root.join("config", "sidekiq_schedule.yml")
      if File.exist?(schedule_file)
        schedule = YAML.load_file(schedule_file)
        Sidekiq::Cron::Job.load_from_hash(schedule) if schedule
      end
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
  end
end
