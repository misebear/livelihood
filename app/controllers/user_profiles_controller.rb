# frozen_string_literal: true

class UserProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  def show
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
    @profile = current_user.user_profile || current_user.build_user_profile
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
