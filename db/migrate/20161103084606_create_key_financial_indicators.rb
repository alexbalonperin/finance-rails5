class CreateKeyFinancialIndicators < ActiveRecord::Migration[5.0]
  def change
    create_table :key_financial_indicators do |t|
      t.references :company, foreign_key: true
      t.string :year
      t.decimal :debt_to_equity
      t.decimal :return_on_equity
      t.decimal :return_on_assets
      t.decimal :eps_basic
      t.decimal :free_cash_flow
      t.decimal :current_ratio
      t.decimal :net_margin
      t.decimal :debt_to_equity_yoy_growth
      t.decimal :return_on_equity_yoy_growth
      t.decimal :return_on_assets_yoy_growth
      t.decimal :eps_basic_yoy_growth
      t.decimal :free_cash_flow_yoy_growth
      t.decimal :current_ratio_yoy_growth
      t.decimal :net_margin_yoy_growth
      t.decimal :return_on_equity_5y_annual_rate_of_return
      t.decimal :return_on_assets_5y_annual_rate_of_return
      t.decimal :eps_basic_5y_annual_rate_of_return
      t.decimal :debt_to_equity_5y_avg
      t.decimal :free_cash_flow_5y_avg
      t.decimal :current_ratio_5y_avg
      t.decimal :net_margin_5y_avg
      t.decimal :return_on_equity_10y_annual_rate_of_return
      t.decimal :return_on_assets_10y_annual_rate_of_return
      t.decimal :eps_basic_10y_annual_rate_of_return
      t.decimal :debt_to_equity_10y_avg
      t.decimal :free_cash_flow_10y_avg
      t.decimal :current_ratio_10y_avg
      t.decimal :net_margin_10y_avg
      t.integer :n_past_financial_statements
      t.boolean :latest
      t.timestamps
    end

    add_index :key_financial_indicators, [:company_id, :year], where: 'latest is true', unique: true
  end
end
