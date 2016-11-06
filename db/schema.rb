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

ActiveRecord::Schema.define(version: 20161106063516) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "balance_sheets", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "year"
    t.datetime "report_date"
    t.decimal  "cash_and_equivalents"
    t.decimal  "trade_and_non_trade_receivables"
    t.decimal  "inventory"
    t.decimal  "current_assets"
    t.decimal  "goodwill_and_intangible_assets"
    t.decimal  "assets_non_current"
    t.decimal  "total_assets"
    t.decimal  "trade_and_non_trade_payables"
    t.decimal  "current_liabilities"
    t.decimal  "total_debt"
    t.decimal  "liabilities_non_current"
    t.decimal  "total_liabilities"
    t.decimal  "accumulated_other_comprehensive_income"
    t.decimal  "accumulated_retained_earnings_deficit"
    t.decimal  "shareholders_equity"
    t.decimal  "shareholders_equity_usd"
    t.decimal  "total_debt_usd"
    t.decimal  "cash_and_equivalents_usd"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["company_id", "year"], name: "index_balance_sheets_on_company_id_and_year", unique: true, using: :btree
    t.index ["company_id"], name: "index_balance_sheets_on_company_id", using: :btree
  end

  create_table "cash_flow_statements", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "year"
    t.datetime "report_date"
    t.decimal  "depreciation_amortization_accretion"
    t.decimal  "net_cash_flow_from_operations"
    t.decimal  "capital_expenditure"
    t.decimal  "net_cash_flow_from_investing"
    t.decimal  "issuance_repayment_of_debt_securities"
    t.decimal  "issuance_purchase_of_equity_shares"
    t.decimal  "payment_of_dividends_and_other_cash_distributions"
    t.decimal  "net_cash_flow_from_financing"
    t.decimal  "effect_of_exchange_rate_changes_on_cash"
    t.decimal  "net_cash_flow_change_in_cash_and_cash_equivalents"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.index ["company_id", "year"], name: "index_cash_flow_statements_on_company_id_and_year", unique: true, using: :btree
    t.index ["company_id"], name: "index_cash_flow_statements_on_company_id", using: :btree
  end

  create_table "commodities", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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
    t.date     "first_trade_date"
    t.string   "ipo_year"
    t.decimal  "market_cap"
    t.index ["active"], name: "index_companies_on_active", using: :btree
    t.index ["industry_id"], name: "index_companies_on_industry_id", using: :btree
    t.index ["name", "symbol", "industry_id", "market_id"], name: "index_companies_on_name_symbol_industry_id_market_id", unique: true, using: :btree
  end

  create_table "companies_changes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "from_id"
    t.integer  "to_id"
    t.index ["from_id"], name: "index_companies_changes_on_from_id", using: :btree
    t.index ["to_id"], name: "index_companies_changes_on_to_id", using: :btree
  end

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
    t.index ["company_id"], name: "index_historical_data_on_company_id", using: :btree
  end

  create_table "income_statements", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "year"
    t.datetime "report_date"
    t.decimal  "revenues"
    t.decimal  "cost_of_revenue"
    t.decimal  "gross_profit"
    t.decimal  "selling_general_and_administrative_expense"
    t.decimal  "research_and_development_expense"
    t.decimal  "ebit"
    t.decimal  "interest_expense"
    t.decimal  "income_tax_expense"
    t.decimal  "net_income"
    t.decimal  "net_income_common_stock"
    t.decimal  "preferred_dividends_income_statement_impact"
    t.decimal  "eps_basic"
    t.decimal  "eps_diluted"
    t.decimal  "weighted_avg_shares"
    t.decimal  "weighted_avg_shares_diluted"
    t.decimal  "dividends_per_basic_common_share"
    t.decimal  "net_income_discontinued_operations"
    t.decimal  "gross_margin"
    t.decimal  "revenues_usd"
    t.decimal  "ebit_usd"
    t.decimal  "net_income_common_stock_usd"
    t.decimal  "eps_basic_usd"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.index ["company_id", "year"], name: "index_income_statements_on_company_id_and_year", unique: true, using: :btree
    t.index ["company_id"], name: "index_income_statements_on_company_id", using: :btree
  end

  create_table "indices", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "industries", force: :cascade do |t|
    t.string   "name"
    t.integer  "sector_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "sector_id"], name: "index_industries_on_name_and_sector_id", unique: true, using: :btree
    t.index ["sector_id"], name: "index_industries_on_sector_id", using: :btree
  end

  create_table "key_financial_indicators", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "year"
    t.decimal  "debt_to_equity"
    t.decimal  "return_on_equity"
    t.decimal  "return_on_assets"
    t.decimal  "eps_basic"
    t.decimal  "free_cash_flow"
    t.decimal  "current_ratio"
    t.decimal  "net_margin"
    t.decimal  "debt_to_equity_yoy_growth"
    t.decimal  "return_on_equity_yoy_growth"
    t.decimal  "return_on_assets_yoy_growth"
    t.decimal  "eps_basic_yoy_growth"
    t.decimal  "free_cash_flow_yoy_growth"
    t.decimal  "current_ratio_yoy_growth"
    t.decimal  "net_margin_yoy_growth"
    t.decimal  "return_on_equity_5y_annual_rate_of_return"
    t.decimal  "return_on_assets_5y_annual_rate_of_return"
    t.decimal  "eps_basic_5y_annual_rate_of_return"
    t.decimal  "debt_to_equity_5y_avg"
    t.decimal  "free_cash_flow_5y_avg"
    t.decimal  "current_ratio_5y_avg"
    t.decimal  "net_margin_5y_avg"
    t.decimal  "return_on_equity_10y_annual_rate_of_return"
    t.decimal  "return_on_assets_10y_annual_rate_of_return"
    t.decimal  "eps_basic_10y_annual_rate_of_return"
    t.decimal  "debt_to_equity_10y_avg"
    t.decimal  "free_cash_flow_10y_avg"
    t.decimal  "current_ratio_10y_avg"
    t.decimal  "net_margin_10y_avg"
    t.integer  "n_past_financial_statements"
    t.boolean  "latest"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.decimal  "price_earnings_ratio"
    t.decimal  "price_earnings_ratio_5y_avg"
    t.decimal  "price_earnings_ratio_10y_avg"
    t.decimal  "price_earnings_ratio_10y_min"
    t.decimal  "price_earnings_ratio_10y_max"
    t.index ["company_id", "year"], name: "index_key_financial_indicators_on_company_id_and_year", unique: true, where: "(latest IS TRUE)", using: :btree
    t.index ["company_id"], name: "index_key_financial_indicators_on_company_id", using: :btree
  end

  create_table "markets", force: :cascade do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_markets_on_country_id", using: :btree
    t.index ["name", "country_id"], name: "index_markets_on_name_and_country_id", unique: true, using: :btree
  end

  create_table "mergers", force: :cascade do |t|
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "acquiring_id"
    t.integer  "acquired_id"
    t.index ["acquired_id"], name: "index_mergers_on_acquired_id", using: :btree
    t.index ["acquiring_id"], name: "index_mergers_on_acquiring_id", using: :btree
  end

  create_table "potential_investments", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "selector"
    t.decimal  "roe_5y_annual_compounding_ror"
    t.decimal  "roe_10y_annual_compounding_ror"
    t.boolean  "roe_steady_growth"
    t.decimal  "eps_5y_annual_compounding_ror"
    t.decimal  "eps_10y_annual_compounding_ror"
    t.boolean  "eps_steady_growth"
    t.decimal  "n_past_financial_statements"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "year"
    t.boolean  "latest",                         default: true
    t.index ["company_id", "year", "selector"], name: "index_potential_investments_on_company_id_and_year_and_selector", unique: true, where: "(latest IS TRUE)", using: :btree
    t.index ["company_id"], name: "index_potential_investments_on_company_id", using: :btree
  end

  create_table "projections", force: :cascade do |t|
    t.integer  "company_id"
    t.boolean  "latest",                         default: true
    t.decimal  "current_price"
    t.decimal  "projected_eps"
    t.decimal  "projected_price_worst"
    t.decimal  "projected_price_min"
    t.decimal  "projected_price_max"
    t.decimal  "projected_price_best"
    t.decimal  "projected_rate_of_return_worst"
    t.decimal  "projected_rate_of_return_min"
    t.decimal  "projected_rate_of_return_max"
    t.decimal  "projected_rate_of_return_best"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "selector"
    t.decimal  "max_price"
    t.index ["company_id"], name: "index_projections_on_company_id", using: :btree
  end

  create_table "sectors", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sectors_on_name", unique: true, using: :btree
  end

  create_table "statement_errors", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "statement_type"
    t.string   "error"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "resolved",       default: false
    t.datetime "resolved_at"
    t.string   "error_type"
    t.index ["company_id"], name: "index_statement_errors_on_company_id", using: :btree
  end

  add_foreign_key "balance_sheets", "companies"
  add_foreign_key "cash_flow_statements", "companies"
  add_foreign_key "companies", "industries"
  add_foreign_key "companies", "markets"
  add_foreign_key "companies_changes", "companies", column: "from_id"
  add_foreign_key "companies_changes", "companies", column: "to_id"
  add_foreign_key "historical_data", "companies"
  add_foreign_key "income_statements", "companies"
  add_foreign_key "industries", "sectors"
  add_foreign_key "key_financial_indicators", "companies"
  add_foreign_key "markets", "countries"
  add_foreign_key "mergers", "companies", column: "acquired_id"
  add_foreign_key "mergers", "companies", column: "acquiring_id"
  add_foreign_key "potential_investments", "companies"
  add_foreign_key "projections", "companies"
  add_foreign_key "statement_errors", "companies"
end
