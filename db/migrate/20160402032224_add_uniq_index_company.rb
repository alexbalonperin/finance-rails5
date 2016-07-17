class AddUniqIndexCompany < ActiveRecord::Migration
  def change
    add_index :companies, [:name, :symbol, :industry_id], :unique => true
  end
end
