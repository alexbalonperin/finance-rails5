class AddColumnsToKeyFinancialIndicator < ActiveRecord::Migration[5.0]
  def change
    add_column :key_financial_indicators, :price_earnings_ratio, :decimal
    add_column :key_financial_indicators, :price_earnings_ratio_5y_avg, :decimal
    add_column :key_financial_indicators, :price_earnings_ratio_10y_avg, :decimal
  end
end
