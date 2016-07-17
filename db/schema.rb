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

ActiveRecord::Schema.define(version: 20160501101733) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.integer  "industry_id"
    t.string   "symbol"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "skip_historical_data", default: false
    t.integer  "market_id"
    t.boolean  "liquidated",           default: false
    t.boolean  "delisted",             default: false
    t.boolean  "active",               default: true
    t.date     "last_trade_date"
  end

  add_index "companies", ["industry_id"], name: "index_companies_on_industry_id", using: :btree
  add_index "companies", ["name", "symbol", "industry_id", "market_id"], name: "index_companies_on_name_symbol_industry_id_market_id", unique: true, using: :btree

  create_table "companies_changes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "from_id"
    t.integer  "to_id"
  end

  add_index "companies_changes", ["from_id"], name: "index_companies_changes_on_from_id", using: :btree
  add_index "companies_changes", ["to_id"], name: "index_companies_changes_on_to_id", using: :btree

  create_table "countries", force: :cascade do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "historical_data", force: :cascade do |t|
    t.date     "trade_date"
    t.decimal  "open"
    t.decimal  "high"
    t.decimal  "low"
    t.decimal  "close"
    t.integer  "volume"
    t.decimal  "adjusted_close"
    t.integer  "company_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "historical_data", ["company_id"], name: "index_historical_data_on_company_id", using: :btree

  create_table "industries", force: :cascade do |t|
    t.string   "name"
    t.integer  "sector_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "industries", ["name", "sector_id"], name: "index_industries_on_name_and_sector_id", unique: true, using: :btree
  add_index "industries", ["sector_id"], name: "index_industries_on_sector_id", using: :btree

  create_table "markets", force: :cascade do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "markets", ["country_id"], name: "index_markets_on_country_id", using: :btree
  add_index "markets", ["name", "country_id"], name: "index_markets_on_name_and_country_id", unique: true, using: :btree

  create_table "mergers", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "acquiring_id"
    t.integer  "acquired_id"
  end

  add_index "mergers", ["acquired_id"], name: "index_mergers_on_acquired_id", using: :btree
  add_index "mergers", ["acquiring_id"], name: "index_mergers_on_acquiring_id", using: :btree

  create_table "sectors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sectors", ["name"], name: "index_sectors_on_name", unique: true, using: :btree

  add_foreign_key "companies", "industries"
  add_foreign_key "companies", "markets"
  add_foreign_key "companies_changes", "companies", column: "from_id"
  add_foreign_key "companies_changes", "companies", column: "to_id"
  add_foreign_key "historical_data", "companies"
  add_foreign_key "industries", "sectors"
  add_foreign_key "markets", "countries"
  add_foreign_key "mergers", "companies", column: "acquired_id"
  add_foreign_key "mergers", "companies", column: "acquiring_id"
end
