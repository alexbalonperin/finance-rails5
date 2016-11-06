class AddMaxPriceToProjection < ActiveRecord::Migration[5.0]
  def change
    add_column :projections, :max_price, :decimal
  end
end
