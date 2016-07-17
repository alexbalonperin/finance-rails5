class AddUniqIndexMarket < ActiveRecord::Migration
  def change
    add_index :markets, [:name, :country_id], :unique => true
  end
end
