class AddSelectorToProjection < ActiveRecord::Migration[5.0]
  def change
    add_column :projections, :selector, :string
  end
end
