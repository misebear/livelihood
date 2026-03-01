# frozen_string_literal: true

# 대시보드 컨트롤러
class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    load_dashboard_data
  end

  # 보호자가 수급자의 대시보드를 대리 조회
  def care_view
    # 수락된 보호 관계에서만 조회 가능
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
