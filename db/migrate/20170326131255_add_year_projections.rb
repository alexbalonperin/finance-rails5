class AddYearProjections < ActiveRecord::Migration[5.0]
  def change
    add_column :projections, :year, :string
    add_column :projections, :actual_price, :decimal
  end
end
