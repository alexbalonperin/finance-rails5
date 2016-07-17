class AddLastTradeDateToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :last_trade_date, :date
  end
end
