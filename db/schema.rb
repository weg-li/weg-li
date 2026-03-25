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

ActiveRecord::Schema[8.1].define(version: 2026_03_25_122755) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "postgis"

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message_checksum", null: false
    t.string "message_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    t.index ["record_type"], name: "index_active_storage_attachments_on_record_type"
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "authorizations", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["user_id"], name: "index_authorizations_on_user_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "aliases", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.string "falsepositives", default: [], null: false, array: true
    t.integer "kind", default: 0, null: false
    t.string "models", default: [], null: false, array: true
    t.string "name"
    t.decimal "share"
    t.integer "status", default: 0, null: false
    t.string "token"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_brands_on_name"
    t.index ["token"], name: "index_brands_on_token", unique: true
  end

  create_table "bulk_uploads", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "error_message"
    t.string "shared_album_url"
    t.integer "status", default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_bulk_uploads_on_user_id"
  end

  create_table "charge_variants", force: :cascade do |t|
    t.integer "charge_detail"
    t.datetime "created_at", null: false
    t.datetime "date", precision: nil
    t.decimal "from"
    t.boolean "impediment"
    t.integer "row_id"
    t.integer "row_number"
    t.integer "table_id"
    t.string "tbnr"
    t.decimal "to"
    t.datetime "updated_at", null: false
    t.index ["table_id", "date"], name: "index_charge_variants_on_table_id_and_date"
    t.index ["table_id"], name: "index_charge_variants_on_table_id"
    t.index ["tbnr"], name: "index_charge_variants_on_tbnr"
  end

  create_table "charges", force: :cascade do |t|
    t.string "bkat"
    t.integer "classification"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "fap"
    t.decimal "fine"
    t.integer "implementation"
    t.decimal "max_fine"
    t.integer "number_required_refinements"
    t.string "penalty"
    t.integer "points", default: 0
    t.string "required_refinements"
    t.integer "rule_id"
    t.integer "table_id"
    t.string "tbnr"
    t.datetime "updated_at", null: false
    t.datetime "valid_from", precision: nil
    t.datetime "valid_to", precision: nil
    t.integer "variant_table_id"
    t.index ["classification"], name: "index_charges_on_classification"
    t.index ["tbnr"], name: "index_charges_on_tbnr"
  end

  create_table "data_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "data"
    t.bigint "keyable_id"
    t.string "keyable_type"
    t.integer "kind", default: 0
    t.bigint "setable_id"
    t.string "setable_type"
    t.datetime "updated_at", null: false
    t.index ["keyable_type", "keyable_id"], name: "index_data_sets_on_keyable"
    t.index ["kind"], name: "index_data_sets_on_kind"
    t.index ["setable_type", "setable_id"], name: "index_data_sets_on_setable"
  end

  create_table "districts", force: :cascade do |t|
    t.string "ags"
    t.string "aliases", array: true
    t.integer "config", default: 0
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "flags", default: 0
    t.float "latitude"
    t.float "longitude"
    t.string "name", null: false
    t.integer "osm_id"
    t.string "parts", default: [], null: false, array: true
    t.string "prefixes", default: [], null: false, array: true
    t.string "reason"
    t.string "state"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.string "zip", null: false
    t.index ["name"], name: "index_districts_on_name"
    t.index ["status"], name: "index_districts_on_status"
    t.index ["zip"], name: "index_districts_on_zip", unique: true
  end

  create_table "exports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "export_type", default: 0, null: false
    t.integer "file_extension", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_exports_on_user_id"
  end

  create_table "identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
  end

  create_table "notices", force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.string "brand"
    t.integer "bulk_upload_id"
    t.string "city"
    t.string "color"
    t.datetime "created_at", precision: nil
    t.bigint "district_id"
    t.integer "duration", default: 0
    t.datetime "end_date", precision: nil
    t.integer "flags", default: 0, null: false
    t.boolean "incomplete", default: false, null: false
    t.string "kind"
    t.float "latitude"
    t.string "location"
    t.float "longitude"
    t.geography "lonlat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.string "note"
    t.string "old_charge"
    t.string "registration"
    t.datetime "sent_at", precision: nil
    t.integer "severity", default: 0
    t.datetime "start_date", precision: nil
    t.integer "status", default: 0
    t.string "street"
    t.string "tbnr"
    t.string "token", limit: 255
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.string "zip"
    t.index ["archived"], name: "index_notices_on_archived"
    t.index ["bulk_upload_id"], name: "index_notices_on_bulk_upload_id"
    t.index ["created_at"], name: "index_notices_on_created_at"
    t.index ["district_id"], name: "index_notices_on_district_id"
    t.index ["end_date"], name: "index_notices_on_end_date"
    t.index ["lonlat"], name: "index_notices_on_lonlat", using: :gist
    t.index ["registration"], name: "index_notices_on_registration"
    t.index ["start_date"], name: "index_notices_on_start_date"
    t.index ["status", "created_at"], name: "index_notices_on_status_and_created_at"
    t.index ["status"], name: "index_notices_on_status"
    t.index ["tbnr"], name: "index_notices_on_tbnr"
    t.index ["token"], name: "index_notices_on_token", unique: true
    t.index ["user_id"], name: "index_notices_on_user_id"
    t.index ["zip"], name: "index_notices_on_zip"
  end

  create_table "plates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "prefix"
    t.datetime "updated_at", null: false
    t.string "zips", default: [], null: false, array: true
    t.index ["prefix"], name: "index_plates_on_prefix", unique: true
  end

  create_table "replies", force: :cascade do |t|
    t.bigint "action_mailbox_inbound_email_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "notice_id"
    t.string "sender"
    t.string "subject"
    t.datetime "updated_at", null: false
    t.index ["action_mailbox_inbound_email_id"], name: "index_replies_on_action_mailbox_inbound_email_id"
    t.index ["notice_id"], name: "index_replies_on_notice_id"
  end

  create_table "signs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "number"
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_signs_on_number", unique: true
  end

  create_table "snippets", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "priority", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_snippets_on_user_id"
  end

  create_table "user_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message"
    t.bigint "receiver_id"
    t.bigint "sender_id"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_user_messages_on_receiver_id"
    t.index ["sender_id"], name: "index_user_messages_on_sender_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "access", default: 0
    t.integer "analyzer", default: 0, null: false
    t.string "api_token"
    t.string "appendix"
    t.integer "autosuggest", default: 0, null: false
    t.string "city"
    t.datetime "created_at", precision: nil
    t.date "date_of_birth"
    t.string "email", limit: 255
    t.integer "flags", default: 0, null: false
    t.datetime "last_login", precision: nil
    t.float "latitude"
    t.float "longitude"
    t.string "name"
    t.string "nickname", limit: 255
    t.string "phone"
    t.string "street"
    t.string "token", limit: 255
    t.datetime "updated_at", precision: nil
    t.datetime "validation_date", precision: nil
    t.string "zip"
    t.index ["access"], name: "index_users_on_access"
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["token"], name: "index_users_on_token", unique: true
    t.index ["zip"], name: "index_users_on_zip"
  end

  create_table "versions", force: :cascade do |t|
    t.datetime "created_at"
    t.string "event", null: false
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.json "object"
    t.json "object_changes"
    t.string "whodunnit"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "exports", "users"

  create_view "homepages", materialized: true, sql_definition: <<-SQL
      SELECT ( SELECT count(*) AS count
             FROM districts
            WHERE (districts.status = 0)) AS districts,
      ( SELECT count(*) AS count
             FROM users
            WHERE (users.access >= 0)) AS users,
      ( SELECT count(DISTINCT notices.user_id) AS count
             FROM notices) AS active,
      ( SELECT count(*) AS count
             FROM notices
            WHERE (notices.status = 3)) AS shared,
      ( SELECT count(*) AS count
             FROM active_storage_attachments
            WHERE ((active_storage_attachments.record_type)::text = 'Notice'::text)) AS photos;
  SQL
  create_view "leaders", materialized: true, sql_definition: <<-SQL
      SELECT count(*) AS count,
      user_id,
      EXTRACT(week FROM created_at) AS week,
      EXTRACT(year FROM created_at) AS year
     FROM notices
    WHERE (status = 3)
    GROUP BY user_id, (EXTRACT(week FROM created_at)), (EXTRACT(year FROM created_at));
  SQL
end
