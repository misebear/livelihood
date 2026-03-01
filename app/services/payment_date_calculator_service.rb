# frozen_string_literal: true

# ────────────────────────────────────────────────────────────────
# PaymentDateCalculatorService
# ────────────────────────────────────────────────────────────────
# 생계/주거급여 법정 지급일 계산기
#
# 기본 규칙:
#   - 법정 지급일: 매월 20일
#   - 20일이 토/일/공휴일이면 **직전 영업일**로 당겨 지급
#   - 명절(설날/추석) 조기 지급: 명절 전 주 금요일
#
# 사용법:
#   PaymentDateCalculatorService.call(year: 2026, month: 3)
#   # => #<Date: 2026-03-20>
#
#   PaymentDateCalculatorService.next_payment_date
#   # => { date: Date, d_day: -3, label: "D-3", early_reason: nil }
# ────────────────────────────────────────────────────────────────
class PaymentDateCalculatorService
  STATUTORY_DAY = 20 # 법정 지급일

  # ── 클래스 메서드 ───────────────────────────────────────────
  class << self
    # 특정 연/월의 실제 지급일 계산
    def call(year:, month:)
      new(year: year, month: month).calculate
    end

    # 오늘 기준 다음 지급일 정보 반환
    def next_payment_date(from: Date.current)
      candidates = [
        { year: from.year, month: from.month },
        { year: from.month == 12 ? from.year + 1 : from.year,
          month: from.month == 12 ? 1 : from.month + 1 }
      ]

      candidates.each do |c|
        date = call(year: c[:year], month: c[:month])
        if date >= from
          d_day = (date - from).to_i
          return {
            date: date,
            d_day: d_day,
            label: format_d_day(d_day),
            month_label: "#{c[:month]}월 생계급여",
            early_reason: early_reason(c[:year], c[:month], date)
          }
        end
      end
    end

    private

    def format_d_day(diff)
      case diff
      when 0 then "D-Day"
      when 1.. then "D-#{diff}"
      else "D+#{diff.abs}"
      end
    end

    def early_reason(year, month, actual_date)
      statutory = Date.new(year, month, STATUTORY_DAY)
      return nil if actual_date == statutory

      if holiday_name(statutory)
        "#{holiday_name(statutory)}으로 조기 지급"
      elsif statutory.saturday?
        "토요일 → 직전 영업일 지급"
      elsif statutory.sunday?
        "일요일 → 직전 영업일 지급"
      else
        "공휴일 → 직전 영업일 지급"
      end
    end

    def holiday_name(date)
      holidays = Holidays.on(date, :kr)
      holidays.first&.dig(:name)
    end
  end

  # ── 인스턴스 ────────────────────────────────────────────────
  def initialize(year:, month:)
    @year = year
    @month = month
  end

  def calculate
    date = Date.new(@year, @month, STATUTORY_DAY)
    rollback_to_business_day(date)
  end

  private

  # 주어진 날짜가 비영업일이면 직전 영업일로 이동
  def rollback_to_business_day(date)
    loop do
      break if business_day?(date)
      date -= 1.day
    end
    date
  end

  # 영업일 판단: 토/일/공휴일이 아니면 영업일
  def business_day?(date)
    return false if date.saturday? || date.sunday?
    return false if korean_holiday?(date)
    true
  end

  # holidays gem을 사용한 한국 공휴일 판단
  def korean_holiday?(date)
    Holidays.on(date, :kr).any?
  end
end
