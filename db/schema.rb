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

ActiveRecord::Schema.define(version: 20160109010837) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ballot_configurations", force: :cascade do |t|
    t.integer "ballot_id"
    t.string  "key"
    t.string  "value"
    t.integer "position"
  end

  create_table "ballot_papers", force: :cascade do |t|
    t.integer  "ballot_id"
    t.string   "uuid"
    t.string   "signature"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ballot_registration_fields", force: :cascade do |t|
    t.integer "ballot_id"
    t.string  "name"
    t.text    "description"
    t.string  "expected_value"
    t.integer "position",       default: 0
  end

  create_table "ballots", force: :cascade do |t|
    t.string   "uuid"
    t.string   "password"
    t.text     "instructions"
    t.text     "notes"
    t.string   "voting_system_type"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ballots", ["uuid"], name: "index_ballots_on_uuid", unique: true, using: :btree

  create_table "candidates", force: :cascade do |t|
    t.integer  "ballot_id"
    t.string   "uuid"
    t.integer  "candidate_type"
    t.uuid     "candidate_uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "candidates", ["uuid"], name: "index_candidates_on_uuid", unique: true, using: :btree

  create_table "votes", force: :cascade do |t|
    t.integer  "candidate_id"
    t.integer  "ballot_paper_id"
    t.string   "value"
    t.integer  "value_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
