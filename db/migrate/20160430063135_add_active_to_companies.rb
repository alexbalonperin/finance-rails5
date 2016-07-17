class AddActiveToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :active, :boolean, :default => true
  end
end
