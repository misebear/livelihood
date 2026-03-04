# frozen_string_literal: true

# 현금흐름 이벤트 CRUD 컨트롤러 — 데이터 변경만 로그인 필요
class CashflowEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:edit, :update, :destroy]

  def new
    @event = current_user.cashflow_events.new(event_date: Date.current)
  end

  def create
    @event = current_user.cashflow_events.new(event_params)

    if @event.save
      redirect_to root_path, notice: "현금흐름 이벤트가 추가되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @event.update(event_params)
      redirect_to root_path, notice: "이벤트가 수정되었습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to root_path, notice: "이벤트가 삭제되었습니다."
  end

  private

  def set_event
    @event = current_user.cashflow_events.find(params[:id])
  end

  def event_params
    params.require(:cashflow_event).permit(:title, :event_type, :event_date, :expected_amount)
  end
end
