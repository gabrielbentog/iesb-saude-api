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

ActiveRecord::Schema[8.0].define(version: 2025_04_10_215215) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "appointments", force: :cascade do |t|
    t.bigint "time_slot_id", null: false
    t.bigint "user_id", null: false
    t.date "date"
    t.time "start_time"
    t.time "end_time"
    t.integer "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "consultation_room_id"
    t.index ["consultation_room_id"], name: "index_appointments_on_consultation_room_id"
    t.index ["time_slot_id"], name: "index_appointments_on_time_slot_id"
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "college_locations", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "consultation_rooms", force: :cascade do |t|
    t.bigint "college_location_id", null: false
    t.bigint "specialty_id", null: false
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["college_location_id"], name: "index_consultation_rooms_on_college_location_id"
    t.index ["specialty_id"], name: "index_consultation_rooms_on_specialty_id"
  end

  create_table "location_specialties", force: :cascade do |t|
    t.bigint "college_location_id", null: false
    t.bigint "specialty_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["college_location_id", "specialty_id"], name: "index_location_specialties_on_location_and_specialty", unique: true
    t.index ["college_location_id"], name: "index_location_specialties_on_college_location_id"
    t.index ["specialty_id"], name: "index_location_specialties_on_specialty_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "name", null: false
    t.integer "users_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recurrence_rules", force: :cascade do |t|
    t.bigint "time_slot_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "frequency_type", null: false
    t.integer "frequency_interval"
    t.integer "max_occurrences"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["time_slot_id"], name: "index_recurrence_rules_on_time_slot_id"
  end

  create_table "specialties", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "time_slots", force: :cascade do |t|
    t.bigint "college_location_id", null: false
    t.bigint "specialty_id", null: false
    t.bigint "intern_id"
    t.integer "turn"
    t.time "start_time"
    t.time "end_time"
    t.integer "week_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["college_location_id"], name: "index_time_slots_on_college_location_id"
    t.index ["intern_id"], name: "index_time_slots_on_intern_id"
    t.index ["specialty_id"], name: "index_time_slots_on_specialty_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "profile_id", null: false
    t.integer "registration"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["profile_id"], name: "index_users_on_profile_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "appointments", "consultation_rooms"
  add_foreign_key "appointments", "time_slots"
  add_foreign_key "appointments", "users"
  add_foreign_key "consultation_rooms", "college_locations"
  add_foreign_key "consultation_rooms", "specialties"
  add_foreign_key "location_specialties", "college_locations"
  add_foreign_key "location_specialties", "specialties"
  add_foreign_key "recurrence_rules", "time_slots"
  add_foreign_key "time_slots", "college_locations"
  add_foreign_key "time_slots", "specialties"
  add_foreign_key "time_slots", "users", column: "intern_id"
  add_foreign_key "users", "profiles"
end
