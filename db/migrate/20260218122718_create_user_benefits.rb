# frozen_string_literal: true

class CreateUserBenefits < ActiveRecord::Migration[8.1]
  def change
    create_table :user_benefits do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :benefit, null: false, foreign_key: true

      t.integer :status, default: 0, null: false  # interested, preparing_documents, applied

      t.timestamps
    end

    add_index :user_benefits, [ :user_id, :benefit_id ], unique: true
  end
end
