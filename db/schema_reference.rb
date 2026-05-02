# AUTO-GENERATED — DO NOT EDIT
# ============================
# This file is regenerated whenever you run `bin/rails db:schema:dump`.
# The canonical schema is db/structure.sql; this file exists as a
# human-readable companion view for quick reference. If you spot a
# discrepancy, structure.sql is the truth — Rails' schema dumper can't
# represent every Postgres feature (triggers, RLS, custom types, etc.).
#
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

ActiveRecord::Schema[8.1].define(version: 2026_04_22_202012) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "event_attendances", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["event_id"], name: "index_event_attendances_on_event_id"
    t.index ["user_id", "event_id"], name: "index_event_attendances_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_event_attendances_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "ends_at", null: false
    t.string "location", null: false
    t.string "name", null: false
    t.datetime "starts_at", null: false
    t.string "time_zone", null: false
    t.datetime "updated_at", null: false
    t.string "website", null: false
    t.index ["starts_at"], name: "index_events_on_starts_at"
    t.check_constraint "ends_at > starts_at", name: "events_ends_after_starts"
  end

  create_table "hobbies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.vector "embedding", limit: 1536
    t.citext "name", null: false
    t.datetime "updated_at", null: false
    t.index ["embedding"], name: "index_hobbies_on_embedding", opclass: :vector_cosine_ops, using: :hnsw
    t.index ["name"], name: "index_hobbies_on_name", unique: true
  end

  create_table "user_hobbies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "hobby_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["hobby_id", "user_id"], name: "index_user_hobbies_on_hobby_id_and_user_id", unique: true
    t.index ["hobby_id"], name: "index_user_hobbies_on_hobby_id"
    t.index ["user_id"], name: "index_user_hobbies_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.text "bio"
    t.string "bluesky_url"
    t.datetime "created_at", null: false
    t.string "email"
    t.boolean "email_notifications_enabled", default: true, null: false
    t.string "linkedin_url"
    t.string "location"
    t.string "mastodon_url"
    t.string "name", null: false
    t.string "pronouns"
    t.string "provider", null: false
    t.string "twitter_url"
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.string "website"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "event_attendances", "events"
  add_foreign_key "event_attendances", "users"
  add_foreign_key "user_hobbies", "hobbies"
  add_foreign_key "user_hobbies", "users"
end
