class CreateIncomeStatement < ActiveRecord::Migration[5.0]
  def change
    create_table :income_statements do |t|
      t.references :company, foreign_key: true
      t.string :year
      t.timestamp :report_date
      t.decimal :revenues
      t.decimal :cost_of_revenue
      t.decimal :gross_profit
      t.decimal :selling_general_and_administrative_expense
      t.decimal :research_and_development_expense
      t.decimal :ebit
      t.decimal :interest_expense
      t.decimal :income_tax_expense
      t.decimal :net_income
      t.decimal :net_income_common_stock
      t.decimal :preferred_dividends_income_statement_impact
      t.decimal :eps_basic
      t.decimal :eps_diluted
      t.decimal :weighted_avg_shares
      t.decimal :weighted_avg_shares_diluted
      t.decimal :dividends_per_basic_common_share
      t.decimal :net_income_discontinued_operations
      t.decimal :gross_margin
      t.decimal :revenues_usd
      t.decimal :ebit_usd
      t.decimal :net_income_common_stock_usd
      t.decimal :eps_basic_usd

      t.timestamps
    end

    add_index :income_statements, [:company_id, :year], unique: true
  end
end
