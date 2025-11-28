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

ActiveRecord::Schema[8.0].define(version: 2025_11_11_000008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "appointment_interns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "appointment_id", null: false
    t.uuid "intern_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["appointment_id", "intern_id"], name: "index_appointment_interns_on_appointment_id_and_intern_id", unique: true
    t.index ["deleted_at"], name: "index_appointment_interns_on_deleted_at"
    t.index ["intern_id"], name: "index_appointment_interns_on_intern_id"
  end

  create_table "appointment_status_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "appointment_id", null: false
    t.integer "from_status"
    t.integer "to_status"
    t.string "changed_by_type", null: false
    t.uuid "changed_by_id", null: false
    t.datetime "changed_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_appointment_status_histories_on_appointment_id"
    t.index ["changed_by_type", "changed_by_id"], name: "index_appointment_status_histories_on_changed_by"
  end

  create_table "appointments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "time_slot_id", null: false
    t.uuid "user_id", null: false
    t.date "date"
    t.time "start_time"
    t.time "end_time"
    t.integer "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "consultation_room_id"
    t.datetime "deleted_at"
    t.index ["consultation_room_id"], name: "index_appointments_on_consultation_room_id"
    t.index ["deleted_at"], name: "index_appointments_on_deleted_at"
    t.index ["time_slot_id"], name: "index_appointments_on_time_slot_id"
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "college_locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_college_locations_on_deleted_at"
  end

  create_table "consultation_rooms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "college_location_id", null: false
    t.uuid "specialty_id", null: false
    t.string "name"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["college_location_id"], name: "index_consultation_rooms_on_college_location_id"
    t.index ["deleted_at"], name: "index_consultation_rooms_on_deleted_at"
    t.index ["specialty_id"], name: "index_consultation_rooms_on_specialty_id"
  end

  create_table "location_specialties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "college_location_id", null: false
    t.uuid "specialty_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["college_location_id", "specialty_id"], name: "index_location_specialties_on_location_and_specialty", unique: true
    t.index ["college_location_id"], name: "index_location_specialties_on_college_location_id"
    t.index ["specialty_id"], name: "index_location_specialties_on_specialty_id"
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "appointment_id"
    t.string "title", null: false
    t.text "body", null: false
    t.boolean "read", default: false, null: false
    t.jsonb "data", default: {}
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["appointment_id"], name: "index_notifications_on_appointment_id"
    t.index ["deleted_at"], name: "index_notifications_on_deleted_at"
    t.index ["read"], name: "index_notifications_on_read"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.integer "users_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recurrence_rules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "time_slot_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.integer "frequency_type", null: false
    t.integer "frequency_interval"
    t.integer "max_occurrences"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["time_slot_id"], name: "index_recurrence_rules_on_time_slot_id"
  end

  create_table "request_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "method"
    t.string "path"
    t.string "controller"
    t.string "action"
    t.json "params"
    t.string "ip"
    t.uuid "user_id"
    t.string "model_touchedt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "specialties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "users_count"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_specialties_on_deleted_at"
  end

  create_table "time_slot_exceptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "time_slot_id", null: false
    t.date "date"
    t.time "start_time"
    t.time "end_time"
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["time_slot_id"], name: "index_time_slot_exceptions_on_time_slot_id"
  end

  create_table "time_slots", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "college_location_id", null: false
    t.uuid "specialty_id", null: false
    t.uuid "intern_id"
    t.integer "turn"
    t.time "start_time"
    t.time "end_time"
    t.integer "week_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date"
    t.boolean "is_recurring", default: false, null: false
    t.datetime "deleted_at"
    t.index ["college_location_id"], name: "index_time_slots_on_college_location_id"
    t.index ["deleted_at"], name: "index_time_slots_on_deleted_at"
    t.index ["intern_id"], name: "index_time_slots_on_intern_id"
    t.index ["specialty_id"], name: "index_time_slots_on_specialty_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.uuid "profile_id", null: false
    t.integer "registration"
    t.uuid "specialty_id"
    t.string "reset_password_code_digest"
    t.datetime "reset_password_code_sent_at"
    t.datetime "last_activity_at"
    t.string "cpf"
    t.string "phone"
    t.string "registration_code"
    t.integer "theme_preference", default: 0, null: false
    t.uuid "college_location_id"
    t.integer "semester"
    t.datetime "deleted_at"
    t.index ["college_location_id"], name: "index_users_on_college_location_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_activity_at"], name: "index_users_on_last_activity_at"
    t.index ["profile_id"], name: "index_users_on_profile_id"
    t.index ["registration_code"], name: "index_users_on_registration_code"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["specialty_id"], name: "index_users_on_specialty_id"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointment_interns", "appointments"
  add_foreign_key "appointment_interns", "users", column: "intern_id"
  add_foreign_key "appointment_status_histories", "appointments"
  add_foreign_key "appointments", "consultation_rooms"
  add_foreign_key "appointments", "time_slots"
  add_foreign_key "appointments", "users"
  add_foreign_key "consultation_rooms", "college_locations"
  add_foreign_key "consultation_rooms", "specialties"
  add_foreign_key "location_specialties", "college_locations"
  add_foreign_key "location_specialties", "specialties"
  add_foreign_key "notifications", "appointments"
  add_foreign_key "notifications", "users"
  add_foreign_key "recurrence_rules", "time_slots"
  add_foreign_key "time_slot_exceptions", "time_slots"
  add_foreign_key "time_slots", "college_locations"
  add_foreign_key "time_slots", "specialties"
  add_foreign_key "time_slots", "users", column: "intern_id"
  add_foreign_key "users", "college_locations"
  add_foreign_key "users", "profiles"
  add_foreign_key "users", "specialties"
end
