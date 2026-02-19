# frozen_string_literal: true

class CreateUserProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :user_profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.integer :household_size, default: 1
      t.string  :region_type                  # 대도시/중소도시/농어촌
      t.string  :housing_type                 # 자가/전세/월세/공공임대

      # 민감 정보 — Rails encrypts (string 타입으로 저장)
      t.string :declared_monthly_income       # 월 소득 (암호화)
      t.string :declared_assets               # 총 재산 (암호화)
      t.string :vehicle_value                 # 차량가액 (암호화)

      t.timestamps
    end
  end
end
