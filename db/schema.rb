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

ActiveRecord::Schema[7.0].define(version: 2022_12_12_130914) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "message_id", null: false
    t.string "message_checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    t.index ["record_type"], name: "index_active_storage_attachments_on_record_type"
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "authorizations", force: :cascade do |t|
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "bulk_uploads", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", default: 0
    t.string "error_message"
    t.string "shared_album_url"
    t.index ["user_id"], name: "index_bulk_uploads_on_user_id"
  end

  create_table "charge_variants", force: :cascade do |t|
    t.integer "row_id"
    t.integer "row_number"
    t.decimal "from"
    t.decimal "to"
    t.boolean "impediment"
    t.string "tbnr"
    t.integer "charge_detail"
    t.integer "table_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date", precision: nil
    t.index ["table_id", "date"], name: "index_charge_variants_on_table_id_and_date"
    t.index ["table_id"], name: "index_charge_variants_on_table_id"
    t.index ["tbnr"], name: "index_charge_variants_on_tbnr"
  end

  create_table "charges", force: :cascade do |t|
    t.string "tbnr"
    t.string "description"
    t.decimal "fine"
    t.string "bkat"
    t.string "penalty"
    t.string "fap"
    t.integer "points", default: 0
    t.datetime "valid_from", precision: nil
    t.datetime "valid_to", precision: nil
    t.integer "implementation"
    t.integer "classification"
    t.integer "variant_table_id"
    t.integer "rule_id"
    t.integer "table_id"
    t.string "required_refinements"
    t.integer "number_required_refinements"
    t.decimal "max_fine"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classification"], name: "index_charges_on_classification"
    t.index ["tbnr"], name: "index_charges_on_tbnr"
  end

  create_table "data_sets", force: :cascade do |t|
    t.string "setable_type"
    t.bigint "setable_id"
    t.string "keyable_type"
    t.bigint "keyable_id"
    t.json "data"
    t.integer "kind", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["keyable_type", "keyable_id"], name: "index_data_sets_on_keyable"
    t.index ["kind"], name: "index_data_sets_on_kind"
    t.index ["setable_type", "setable_id"], name: "index_data_sets_on_setable"
  end

  create_table "districts", force: :cascade do |t|
    t.string "name", null: false
    t.string "zip", null: false
    t.string "email", null: false
    t.string "prefixes", default: [], array: true
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aliases", array: true
    t.integer "flags", default: 0
    t.integer "osm_id"
    t.string "state"
    t.integer "status", default: 0
    t.integer "config", default: 0
    t.index ["name"], name: "index_districts_on_name"
    t.index ["status"], name: "index_districts_on_status"
    t.index ["zip"], name: "index_districts_on_zip", unique: true
  end

  create_table "exports", force: :cascade do |t|
    t.integer "export_type", default: 0, null: false
    t.integer "interval", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "identities", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notices", force: :cascade do |t|
    t.string "token", limit: 255
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "status", default: 0
    t.integer "flags", default: 0, null: false
    t.datetime "date", precision: nil
    t.string "charge"
    t.string "kind"
    t.string "brand"
    t.string "color"
    t.string "registration"
    t.float "latitude"
    t.float "longitude"
    t.boolean "incomplete", default: false, null: false
    t.string "note"
    t.integer "bulk_upload_id"
    t.bigint "district_id"
    t.string "street"
    t.string "zip"
    t.string "city"
    t.integer "duration", default: 0
    t.integer "severity", default: 0
    t.string "location"
    t.datetime "sent_at", precision: nil
    t.geography "lonlat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.index ["bulk_upload_id"], name: "index_notices_on_bulk_upload_id"
    t.index ["created_at"], name: "index_notices_on_created_at"
    t.index ["date"], name: "index_notices_on_date"
    t.index ["district_id"], name: "index_notices_on_district_id"
    t.index ["lonlat"], name: "index_notices_on_lonlat", using: :gist
    t.index ["registration"], name: "index_notices_on_registration"
    t.index ["status"], name: "index_notices_on_status"
    t.index ["token"], name: "index_notices_on_token", unique: true
    t.index ["user_id"], name: "index_notices_on_user_id"
    t.index ["zip"], name: "index_notices_on_zip"
  end

  create_table "replies", force: :cascade do |t|
    t.bigint "notice_id"
    t.string "sender"
    t.string "subject"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "action_mailbox_inbound_email_id"
    t.index ["action_mailbox_inbound_email_id"], name: "index_replies_on_action_mailbox_inbound_email_id"
    t.index ["notice_id"], name: "index_replies_on_notice_id"
  end

  create_table "snippets", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_snippets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255
    t.string "nickname", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "token", limit: 255
    t.datetime "validation_date", precision: nil
    t.integer "access", default: 0
    t.integer "flags", default: 0, null: false
    t.string "name"
    t.string "phone"
    t.float "latitude"
    t.float "longitude"
    t.string "api_token"
    t.string "street"
    t.string "zip"
    t.string "city"
    t.string "appendix"
    t.datetime "last_login", precision: nil
    t.date "date_of_birth"
    t.string "project_access_token"
    t.string "project_user_id"
    t.integer "autosuggest", default: 0, null: false
    t.index ["access"], name: "index_users_on_access"
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["token"], name: "index_users_on_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
