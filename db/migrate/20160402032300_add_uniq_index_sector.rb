class AddUniqIndexSector < ActiveRecord::Migration
  def change
    add_index :sectors, :name, :unique => true
  end
end
