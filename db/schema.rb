# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_05_124745) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.datetime "published_at"
    t.string "tags", limit: 255, default: [], array: true
    t.json "content"
    t.json "headline"
  end

  create_table "authorizations", force: :cascade do |t|
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notices", force: :cascade do |t|
    t.json "data"
    t.string "token", limit: 255
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "status", default: 0
    t.integer "flags", default: 0, null: false
    t.datetime "date"
    t.string "charge"
    t.string "kind"
    t.string "brand"
    t.string "model"
    t.string "color"
    t.string "registration"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.boolean "incomplete", default: false, null: false
    t.string "note"
    t.string "district"
    t.integer "bulk_upload_id"
    t.index ["registration"], name: "index_notices_on_registration"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255
    t.string "nickname", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "token", limit: 255
    t.datetime "validation_date"
    t.integer "access", default: 0
    t.string "time_zone"
    t.integer "flags", default: 0, null: false
    t.string "name"
    t.string "address"
    t.string "district", default: "hamburg", null: false
    t.string "phone"
    t.float "latitude"
    t.float "longitude"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
