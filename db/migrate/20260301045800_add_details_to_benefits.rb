# frozen_string_literal: true

# benefits 테이블에 카테고리·대상자·지원금액 등 상세 정보 컬럼 추가
class AddDetailsToBenefits < ActiveRecord::Migration[8.1]
  def change
    add_column :benefits, :category, :string          # 카테고리 (기초급여, 감면, 바우처 등)
    add_column :benefits, :target_group, :text         # 대상자 조건
    add_column :benefits, :support_amount, :string     # 지원 금액 요약
    add_column :benefits, :apply_period, :string       # 신청 기간
    add_column :benefits, :source, :string             # 정보 출처 (seed, data.go.kr, scraper 등)
    add_column :benefits, :eligibility_type, :string   # 수급자 유형 (생계/의료/주거/교육/차상위)
    add_column :benefits, :provider, :string           # 제공 기관
    add_column :benefits, :deadline, :date             # 마감일
    add_column :benefits, :priority, :integer, default: 0  # 노출 우선순위
    add_column :benefits, :last_synced_at, :datetime   # 마지막 동기화 시각

    add_index :benefits, :category
    add_index :benefits, :eligibility_type
  end
end
