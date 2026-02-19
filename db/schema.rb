# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_18_122719) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "benefits", force: :cascade do |t|
    t.string "apply_url"
    t.datetime "created_at", null: false
    t.string "external_id", null: false
    t.boolean "is_safe_savings", default: false, null: false
    t.text "summary"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_benefits_on_external_id", unique: true
  end

  create_table "care_relations", force: :cascade do |t|
    t.bigint "caregiver_id", null: false
    t.datetime "created_at", null: false
    t.bigint "recipient_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["caregiver_id", "recipient_id"], name: "index_care_relations_on_caregiver_id_and_recipient_id", unique: true
    t.index ["caregiver_id"], name: "index_care_relations_on_caregiver_id"
    t.index ["recipient_id"], name: "index_care_relations_on_recipient_id"
  end

  create_table "cashflow_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "event_date", null: false
    t.integer "event_type", default: 0, null: false
    t.decimal "expected_amount", precision: 12, default: "0"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "event_date"], name: "index_cashflow_events_on_user_id_and_event_date"
    t.index ["user_id"], name: "index_cashflow_events_on_user_id"
  end

  create_table "user_benefits", force: :cascade do |t|
    t.bigint "benefit_id", null: false
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["benefit_id"], name: "index_user_benefits_on_benefit_id"
    t.index ["user_id", "benefit_id"], name: "index_user_benefits_on_user_id_and_benefit_id", unique: true
    t.index ["user_id"], name: "index_user_benefits_on_user_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "declared_assets"
    t.string "declared_monthly_income"
    t.integer "household_size", default: 1
    t.string "housing_type"
    t.string "region_type"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "vehicle_value"
    t.index ["user_id"], name: "index_user_profiles_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "care_relations", "users", column: "caregiver_id"
  add_foreign_key "care_relations", "users", column: "recipient_id"
  add_foreign_key "cashflow_events", "users"
  add_foreign_key "user_benefits", "benefits"
  add_foreign_key "user_benefits", "users"
  add_foreign_key "user_profiles", "users"
end
