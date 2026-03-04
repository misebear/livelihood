# frozen_string_literal: true

# 관심 혜택 관리 — 개인 데이터이므로 로그인 필요
class UserBenefitsController < ApplicationController
  before_action :authenticate_user!

  # POST /user_benefits — 관심 혜택 등록
  def create
    @benefit = Benefit.find(params[:benefit_id])
    @user_benefit = current_user.user_benefits.find_or_initialize_by(benefit: @benefit)
    @user_benefit.status = :interested
    @user_benefit.save!

    redirect_to benefit_path(@benefit), notice: "관심 혜택에 등록되었습니다."
  end

  # PATCH /user_benefits/:id — 상태 업데이트
  def update
    @user_benefit = current_user.user_benefits.find(params[:id])
    @user_benefit.update!(status: params[:status])

    redirect_to benefit_path(@user_benefit.benefit), notice: "상태가 업데이트되었습니다."
  end

  # DELETE /user_benefits/:id — 관심 해제
  def destroy
    @user_benefit = current_user.user_benefits.find(params[:id])
    @user_benefit.destroy!

    redirect_to benefits_path, notice: "관심 혜택에서 제거되었습니다."
  end
end
