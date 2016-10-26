class CreateCashFlowStatement < ActiveRecord::Migration[5.0]
  def change
    create_table :cash_flow_statements do |t|
      t.references :company, foreign_key: true
      t.string :year
      t.timestamp :report_date
      t.decimal :depreciation_amortization_accretion
      t.decimal :net_cash_flow_from_operations
      t.decimal :capital_expenditure
      t.decimal :net_cash_flow_from_investing
      t.decimal :issuance_repayment_of_debt_securities
      t.decimal :issuance_purchase_of_equity_shares
      t.decimal :payment_of_dividends_and_other_cash_distributions
      t.decimal :net_cash_flow_from_financing
      t.decimal :effect_of_exchange_rate_changes_on_cash
      t.decimal :net_cash_flow_change_in_cash_and_cash_equivalents

      t.timestamps
    end
    add_index :cash_flow_statements, [:company_id, :year], unique: true
  end
end
