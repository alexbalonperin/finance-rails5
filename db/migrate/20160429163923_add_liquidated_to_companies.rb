class AddLiquidatedToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :liquidated, :boolean, :default => false
  end
end
