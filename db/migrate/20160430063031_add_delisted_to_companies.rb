class AddDelistedToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :delisted, :boolean, :default => false
  end
end
