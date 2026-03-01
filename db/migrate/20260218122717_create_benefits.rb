# frozen_string_literal: true

class CreateBenefits < ActiveRecord::Migration[8.1]
  def change
    create_table :benefits do |t|
      t.string  :external_id, null: false                # 공공 API 기준 ID
      t.string  :title, null: false
      t.text    :summary
      t.string  :apply_url                                # 공식 신청 딥링크
      t.boolean :is_safe_savings, default: false, null: false  # 정부매칭통장 여부

      t.timestamps
    end

    add_index :benefits, :external_id, unique: true
  end
end
