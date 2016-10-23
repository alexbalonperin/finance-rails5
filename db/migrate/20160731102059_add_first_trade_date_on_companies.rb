class AddFirstTradeDateOnCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :first_trade_date, :date
  end
end
