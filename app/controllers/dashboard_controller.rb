# frozen_string_literal: true

# 대시보드 컨트롤러 — 로그인 없이도 접근 가능
class DashboardController < ApplicationController
  # 로그인 필수 제거 — 게스트도 대시보드 조회 가능
  before_action :authenticate_user!, only: [ :care_view ]

  def index
    @user = current_user
    load_dashboard_data
  end

  # 보호자가 수급자의 대시보드를 대리 조회 (로그인 필수)
  def care_view
    relation = current_user.caregiving_relations.active.find_by(recipient_id: params[:id])

    unless relation
      redirect_to care_relations_path, alert: "조회 권한이 없습니다."
      return
    end

    @user = relation.recipient
    @viewing_as_caregiver = true
    load_dashboard_data
    render :index
  end

  private

  # 대시보드 공통 데이터 로딩
  def load_dashboard_data
    # D-Day 카운트다운 정보 (로그인 없이도 표시)
    @next_payment = PaymentDateCalculatorService.next_payment_date

    if @user
      # 로그인 사용자: 개인 데이터 로딩
      @profile = @user.user_profile || @user.build_user_profile
      @cashflow_events = @user.cashflow_events.this_month.order(:event_date)
      @upcoming_events = @user.cashflow_events.upcoming.limit(5)
      @monthly_income  = @cashflow_events.payments.sum(:expected_amount)
      @monthly_expense = @cashflow_events.deductions.sum(:expected_amount)

      @safe_asset_result = if @profile.persisted? && @profile.declared_assets.present?
                               SafeAssetCalculatorService.call(@profile)
      end

      @user_benefits = @user.user_benefits
                           .includes(:benefit)
                           .in_progress
                           .limit(3)

      # ── 현금흐름 강화: 잔액 + 일일 예산 ──
      @monthly_balance = @monthly_income - @monthly_expense
      remaining = (Date.current.end_of_month - Date.current).to_i
      @remaining_days = [ remaining, 1 ].max
      @daily_budget = (@monthly_balance / @remaining_days).round(0)

      # ── 다가오는 중요 일정 (5건) ──
      @critical_events = @user.cashflow_events.upcoming.limit(5)
    else
      # 게스트 사용자: 기본 데모 데이터
      @profile = nil
      @cashflow_events = CashflowEvent.none
      @upcoming_events = CashflowEvent.none
      @monthly_income  = 0
      @monthly_expense = 0
      @monthly_balance = 0
      @remaining_days = 1
      @daily_budget = 0
      @critical_events = CashflowEvent.none
      @safe_asset_result = nil
      @user_benefits = UserBenefit.none
    end

    # 정부매칭 저축 상품 (로그인 없이도 표시)
    @safe_savings = Benefit.safe_savings_products.limit(3)
    @featured_guides = SeoGuide.featured
  end
end
