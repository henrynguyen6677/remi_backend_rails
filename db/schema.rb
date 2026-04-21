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

ActiveRecord::Schema[8.1].define(version: 2026_04_21_012119) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "notifications", primary_key: "notification_id", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.jsonb "info", default: {}
    t.string "language", null: false
    t.boolean "send_email_status", default: false
    t.integer "send_to_user_id", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.integer "user_id", null: false
  end

  create_table "posts", primary_key: "post_id", id: :string, force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "embedUrl"
    t.string "like_user_ids", default: [], array: true
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.integer "user_id", null: false
  end

  create_table "users", primary_key: "user_id", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", limit: 50, null: false
    t.string "name", limit: 32
    t.string "password", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "notifications", "users", column: "send_to_user_id", primary_key: "user_id"
  add_foreign_key "notifications", "users", primary_key: "user_id"
  add_foreign_key "posts", "users", primary_key: "user_id"
end
