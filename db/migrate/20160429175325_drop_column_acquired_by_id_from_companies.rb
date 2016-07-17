class DropColumnAcquiredByIdFromCompanies < ActiveRecord::Migration
  def change
    remove_column :companies, :acquired_by_id
  end
end
