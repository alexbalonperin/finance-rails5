class RenameColumnsKfi < ActiveRecord::Migration[5.0]
  def change
    add_column :key_financial_indicators, :eps_diluted, :numeric
    add_column :key_financial_indicators, :eps_diluted_yoy_growth, :numeric
    add_column :key_financial_indicators, :eps_diluted_5y_annual_rate_of_return, :numeric
    add_column :key_financial_indicators, :eps_diluted_10y_annual_rate_of_return, :numeric
  end
end
