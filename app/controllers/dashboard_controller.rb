# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @profile = @user.user_profile || @user.build_user_profile

    # D-Day 카운트다운 정보
    @next_payment = PaymentDateCalculatorService.next_payment_date

    # 이번 달 현금흐름 이벤트
    @cashflow_events = @user.cashflow_events.this_month.order(:event_date)
    @upcoming_events = @user.cashflow_events.upcoming.limit(5)

    # 이번 달 예정 금액 합계
    @monthly_income  = @cashflow_events.payments.sum(:expected_amount)
    @monthly_expense = @cashflow_events.deductions.sum(:expected_amount)

    # 안전 자산 게이지 (프로필이 있을 때만)
    @safe_asset_result = if @profile.persisted? && @profile.declared_assets.present?
                           SafeAssetCalculatorService.call(@profile)
    end

    # 관심 혜택
    @user_benefits = @user.user_benefits
                         .includes(:benefit)
                         .in_progress
                         .limit(3)

    # 정부매칭 저축 상품
    @safe_savings = Benefit.safe_savings_products.limit(3)
  end
end
