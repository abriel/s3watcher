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

ActiveRecord::Schema.define(version: 20180413215754) do

  create_table "buckets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.string "name"
    t.string "access_key"
    t.string "secret_key"
    t.string "region"
    t.datetime "last_scaned"
    t.integer "scan_period"
    t.index ["user_id"], name: "index_buckets_on_user_id"
  end

  create_table "s3files", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "bucket_id"
    t.string "etag"
    t.bigint "size"
    t.string "key"
    t.datetime "last_modified"
    t.datetime "presence"
    t.index ["bucket_id"], name: "index_s3files_on_bucket_id"
    t.index ["etag"], name: "index_s3files_on_etag"
    t.index ["key"], name: "index_s3files_on_key"
    t.index ["presence"], name: "index_s3files_on_presence"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "access_key"
    t.string "secret_key"
    t.string "name"
    t.string "email"
  end

  add_foreign_key "buckets", "users", on_delete: :cascade
  add_foreign_key "s3files", "buckets", on_delete: :cascade
end
