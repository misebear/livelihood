# frozen_string_literal: true

class CreateCareRelations < ActiveRecord::Migration[8.1]
  def change
    create_table :care_relations do |t|
      t.references :caregiver, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }

      t.integer :status, default: 0, null: false  # pending, accepted

      t.timestamps
    end

    add_index :care_relations, [ :caregiver_id, :recipient_id ], unique: true
  end
end
