class AddColumnMinMaxToKeyFinancialIndicators < ActiveRecord::Migration[5.0]
  def change
    add_column :key_financial_indicators, :price_earnings_ratio_10y_min, :decimal
    add_column :key_financial_indicators, :price_earnings_ratio_10y_max, :decimal
  end
end
