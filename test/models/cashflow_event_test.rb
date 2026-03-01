# frozen_string_literal: true

require "test_helper"

class CashflowEventTest < ActiveSupport::TestCase
  # ── D-Day 계산 테스트 ──
  test "미래 이벤트의 d_day_label은 D-N 형식이다" do
    event = cashflow_events(:welfare_payment)
    if event.event_date > Date.current
      assert_match(/D-\d+/, event.d_day_label)
    end
  end

  test "오늘 이벤트의 d_day_label은 D-Day다" do
    event = CashflowEvent.new(
      user: users(:recipient),
      title: "오늘 이벤트",
      event_type: :payment,
      expected_amount: 100_000,
      event_date: Date.current
    )
    assert_equal "D-Day", event.d_day_label
  end

  test "과거 이벤트의 d_day_label은 D+N 형식이다" do
    event = cashflow_events(:past_payment)
    if event.event_date < Date.current
      assert_match(/D\+\d+/, event.d_day_label)
    end
  end

  # ── Scope 테스트 ──
  test "upcoming은 오늘 이후 이벤트만 반환한다" do
    upcoming = users(:recipient).cashflow_events.upcoming
    upcoming.each do |event|
      assert event.event_date >= Date.current
    end
  end

  test "payments scope는 수입만 반환한다" do
    payments = CashflowEvent.payments
    assert payments.all?(&:payment?)
  end

  test "deductions scope는 지출만 반환한다" do
    deductions = CashflowEvent.deductions
    assert deductions.all?(&:deduction?)
  end

  # ── Validation 테스트 ──
  test "title은 필수다" do
    event = CashflowEvent.new(user: users(:recipient), event_date: Date.current, expected_amount: 100)
    assert_not event.valid?
    assert event.errors[:title].any?
  end

  test "expected_amount는 0 이상이어야 한다" do
    event = CashflowEvent.new(
      user: users(:recipient),
      title: "테스트",
      event_date: Date.current,
      expected_amount: -100
    )
    assert_not event.valid?
  end
end
