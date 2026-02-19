# frozen_string_literal: true

class BenefitsController < ApplicationController
  before_action :authenticate_user!

  def index
    @benefits = Benefit.all.order(:title)
    @safe_savings = Benefit.safe_savings_products
    @general = Benefit.general
  end

  def show
    @benefit = Benefit.find(params[:id])
    @user_benefit = current_user.user_benefits.find_by(benefit: @benefit)
  end
end
