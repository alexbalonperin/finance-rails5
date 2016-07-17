class AddMarketIdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :market_id, :integer
    add_foreign_key :companies, :markets
  end
end
