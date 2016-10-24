class CreateBalanceSheet < ActiveRecord::Migration[5.0]
  def change
    create_table :balance_sheets do |t|
      t.references(:company)
      t.string :year
      t.timestamp :report_date
      t.decimal :cash_and_equivalents
      t.decimal :trade_and_non_trade_receivables
      t.decimal :inventory
      t.decimal :current_assets
      t.decimal :goodwill_and_intangible_assets
      t.decimal :assets_non_current
      t.decimal :total_assets
      t.decimal :trade_and_non_trade_payables
      t.decimal :current_liabilities
      t.decimal :total_debt
      t.decimal :liabilities_non_current
      t.decimal :total_liabilities
      t.decimal :accumulated_other_comprehensive_income
      t.decimal :accumulated_retained_earnings_deficit
      t.decimal :shareholders_equity
      t.decimal :shareholders_equity_usd
      t.decimal :total_debt_usd
      t.decimal :cash_and_equivalents_usd

      t.timestamps
    end
    add_index :balance_sheets, [:company_id, :year], unique: true
  end
end
