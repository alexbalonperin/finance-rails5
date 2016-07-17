class AddAcquiredByIdToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :acquired_by_id, :integer
    add_foreign_key :companies, :companies, column: :acquired_by_id
  end
end
