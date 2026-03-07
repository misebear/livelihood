# frozen_string_literal: true

# 사용자 프로필 — 조회는 로그인 없이, 수정은 로그인 필요
class UserProfilesController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update]
  before_action :set_profile

  def show
    # 게스트 사용자는 프로필 안내 페이지 표시 (로그인 유도)
    return if @profile.nil?
    redirect_to edit_user_profile_path unless @profile.persisted?
  end

  def edit
  end

  def update
    if @profile.update(profile_params)
      redirect_to root_path, notice: "내 정보가 저장되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    if current_user
      @profile = current_user.user_profile || current_user.build_user_profile
    else
      @profile = nil
    end
  end

  def profile_params
    params.require(:user_profile).permit(
      :household_size,
      :region_type,
      :housing_type,
      :declared_monthly_income,
      :declared_assets,
      :vehicle_value
    )
  end
end
