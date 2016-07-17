class ModifyIndexesOnCompanies < ActiveRecord::Migration
  def change
    remove_index :companies, name: 'index_companies_on_name'
    remove_index :companies, name: 'index_companies_on_name_and_symbol_and_industry_id'
    add_index :companies, [:name, :symbol, :industry_id, :market_id], :unique => true, name: 'index_companies_on_name_symbol_industry_id_market_id'
  end
end
