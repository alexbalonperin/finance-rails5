class RenameMaxPriceInProjections < ActiveRecord::Migration[5.0]
  def change
    rename_column :projections, :max_price, :projected_value_1y
    add_column :projections, :projected_value_5y, :decimal
    add_column :projections, :projected_value_10y, :decimal
  end
end
