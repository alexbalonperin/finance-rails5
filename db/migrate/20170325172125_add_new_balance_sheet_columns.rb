class AddNewBalanceSheetColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :balance_sheets, :investments_current, :decimal
    add_column :balance_sheets, :investments_non_current, :decimal
    add_column :balance_sheets, :property_plant_and_equipment_net, :decimal
    add_column :balance_sheets, :tax_assets, :decimal
    add_column :balance_sheets, :debt_current, :decimal
    add_column :balance_sheets, :debt_non_current, :decimal
    add_column :balance_sheets, :tax_liabilities, :decimal
    add_column :balance_sheets, :deferred_revenue, :decimal
    add_column :balance_sheets, :deposit_liabilities, :decimal
    add_column :balance_sheets, :investments, :decimal
  end
end
