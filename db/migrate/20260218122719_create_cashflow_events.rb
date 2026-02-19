# frozen_string_literal: true

class CreateCashflowEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :cashflow_events do |t|
      t.references :user, null: false, foreign_key: true

      t.date    :event_date, null: false
      t.string  :title, null: false
      t.decimal :expected_amount, precision: 12, scale: 0, default: 0  # 원 단위
      t.integer :event_type, default: 0, null: false  # payment, deduction

      t.timestamps
    end

    add_index :cashflow_events, [ :user_id, :event_date ]
  end
end
