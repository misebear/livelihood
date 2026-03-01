# frozen_string_literal: true

# ActiveRecord Encryption 설정 (개발 전용)
# 프로덕션에서는 Rails credentials에 저장하세요.
if Rails.env.development? || Rails.env.test?
  Rails.application.configure do
    config.active_record.encryption.primary_key = "development_primary_key_32bytes_"
    config.active_record.encryption.deterministic_key = "development_det_key_32byteslong_"
    config.active_record.encryption.key_derivation_salt = "development_salt_for_key_deriving"
  end
end
