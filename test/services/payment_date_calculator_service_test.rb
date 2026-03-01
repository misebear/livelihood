# frozen_string_literal: true

require "test_helper"

class PaymentDateCalculatorServiceTest < ActiveSupport::TestCase
  # ── 기본 계산 테스트 ──
  test "법정 지급일은 20일이다" do
    assert_equal 20, PaymentDateCalculatorService::STATUTORY_DAY
  end

  test "평일 20일은 그대로 반환한다" do
    # 2026년 1월 20일은 화요일
    date = PaymentDateCalculatorService.call(year: 2026, month: 1)
    assert_equal Date.new(2026, 1, 20), date
  end

  test "주말이면 직전 금요일로 롤백한다" do
    # 20일이 토요일/일요일인 달 찾기
    # 2026년 6월 20일은 토요일
    date = PaymentDateCalculatorService.call(year: 2026, month: 6)
    assert date <= Date.new(2026, 6, 20), "지급일은 20일 이전이어야 한다"
    assert_not date.saturday?, "토요일이면 안 된다"
    assert_not date.sunday?, "일요일이면 안 된다"
  end

  # ── D-Day 포맷 테스트 ──
  test "next_payment_date는 hash를 반환한다" do
    result = PaymentDateCalculatorService.next_payment_date
    assert_not_nil result
    assert result.is_a?(Hash)
    assert_includes result.keys, :date
    assert_includes result.keys, :d_day
    assert_includes result.keys, :label
    assert_includes result.keys, :month_label
  end

  test "D-Day 라벨 포맷이 올바르다" do
    result = PaymentDateCalculatorService.next_payment_date
    assert_match(/D-Day|D-\d+|D\+\d+/, result[:label])
  end

  test "month_label은 월 생계급여 형식이다" do
    result = PaymentDateCalculatorService.next_payment_date
    assert_match(/\d+월 생계급여/, result[:month_label])
  end

  # ── 반환값 날짜 검증 ──
  test "반환된 지급일은 오늘 이후다" do
    result = PaymentDateCalculatorService.next_payment_date
    assert result[:date] >= Date.current
  end

  test "계산된 날짜는 항상 영업일이다" do
    12.times do |i|
      month = i + 1
      date = PaymentDateCalculatorService.call(year: 2026, month: month)
      assert_not date.saturday?, "#{month}월: 토요일 불가"
      assert_not date.sunday?, "#{month}월: 일요일 불가"
    end
  end
end
