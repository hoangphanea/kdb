# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160129093447) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "dropbox_links", force: :cascade do |t|
    t.integer  "vol"
    t.string   "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "stype"
    t.string   "password"
  end

  add_index "dropbox_links", ["vol"], name: "index_dropbox_links_on_vol", using: :btree

  create_table "pages", force: :cascade do |t|
    t.integer  "page_num"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "pages", ["page_num"], name: "index_pages_on_page_num", using: :btree

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "pg_search_documents", ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree

  create_table "songs", force: :cascade do |t|
    t.string   "name",        default: ""
    t.string   "song_id",     default: ""
    t.text     "lyric",       default: ""
    t.string   "singer",      default: ""
    t.integer  "vol",         default: 0
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "short_lyric", default: ""
    t.boolean  "check",       default: false
    t.string   "temp"
    t.text     "utf8_lyric"
    t.string   "stype",       default: ""
  end

  add_index "songs", ["name"], name: "index_songs_on_name", using: :btree
  add_index "songs", ["short_lyric"], name: "index_songs_on_short_lyric", using: :btree
  add_index "songs", ["singer"], name: "index_songs_on_singer", using: :btree
  add_index "songs", ["song_id"], name: "index_songs_on_song_id", using: :btree
  add_index "songs", ["stype"], name: "index_songs_on_stype", using: :btree
  add_index "songs", ["vol"], name: "index_songs_on_vol", using: :btree

end
