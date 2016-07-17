class AddUniqIndexIndustry < ActiveRecord::Migration
  def change
    add_index :industries, [:name, :sector_id], :unique => true
  end
end
