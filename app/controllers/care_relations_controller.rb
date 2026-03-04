# frozen_string_literal: true

# 보호자 관계 — 목록 조회는 로그인 없이, 생성/수락/삭제는 로그인 필요
class CareRelationsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :accept, :destroy]

  def index
    if current_user
      @as_caregiver = current_user.caregiving_relations.includes(:recipient)
      @as_recipient = current_user.receiving_relations.includes(:caregiver)
    else
      @as_caregiver = CareRelation.none
      @as_recipient = CareRelation.none
    end
  end

  # POST /care_relations — 보호자가 수급자에게 케어 요청 (로그인 필수)
  def create
    recipient = User.find_by(email: params[:recipient_email])

    unless recipient
      redirect_to care_relations_path, alert: "해당 이메일의 사용자를 찾을 수 없습니다."
      return
    end

    if recipient == current_user
      redirect_to care_relations_path, alert: "본인에게는 보호 관계를 설정할 수 없습니다."
      return
    end

    relation = CareRelation.find_or_initialize_by(
      caregiver: current_user,
      recipient: recipient
    )
    relation.status = :pending
    relation.save!

    redirect_to care_relations_path, notice: "#{recipient.name || recipient.email}님에게 보호 요청을 보냈습니다."
  end

  # PATCH /care_relations/:id/accept — 수급자가 수락 (로그인 필수)
  def accept
    relation = current_user.receiving_relations.find(params[:id])
    relation.update!(status: :accepted)

    redirect_to care_relations_path, notice: "보호 관계가 수락되었습니다."
  end

  # DELETE /care_relations/:id — 관계 해제 (로그인 필수)
  def destroy
    relation = CareRelation.find(params[:id])

    unless [relation.caregiver_id, relation.recipient_id].include?(current_user.id)
      redirect_to care_relations_path, alert: "권한이 없습니다."
      return
    end

    relation.destroy!
    redirect_to care_relations_path, notice: "보호 관계가 해제되었습니다."
  end
end
