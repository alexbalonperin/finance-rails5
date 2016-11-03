class AddColumnsToCompany < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :ipo_year, :string
    add_column :companies, :market_cap, :decimal
  end
end
