# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # fixtures 경로 설정
    fixtures :all

    # Windows에서는 fork 불가 → 병렬 실행 비활성화
    # parallelize(workers: :number_of_processors)
  end
end
