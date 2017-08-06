class AddColumnsToProjections < ActiveRecord::Migration[5.0]
  def change
    rename_column :projections, :projected_eps, :projected_eps_1y
    rename_column :projections, :projected_price_worst, :projected_price_worst_1y
    rename_column :projections, :projected_price_min, :projected_price_min_1y
    rename_column :projections, :projected_price_max, :projected_price_max_1y
    rename_column :projections, :projected_price_best, :projected_price_best_1y
    rename_column :projections, :projected_rate_of_return_worst, :projected_rate_of_return_worst_1y
    rename_column :projections, :projected_rate_of_return_min, :projected_rate_of_return_min_1y
    rename_column :projections, :projected_rate_of_return_max, :projected_rate_of_return_max_1y
    rename_column :projections, :projected_rate_of_return_best, :projected_rate_of_return_best_1y
    add_column :projections, :projected_eps_5y, :decimal
    add_column :projections, :projected_price_worst_5y, :decimal
    add_column :projections, :projected_price_min_5y, :decimal
    add_column :projections, :projected_price_max_5y, :decimal
    add_column :projections, :projected_price_best_5y, :decimal
    add_column :projections, :projected_rate_of_return_worst_5y, :decimal
    add_column :projections, :projected_rate_of_return_min_5y, :decimal
    add_column :projections, :projected_rate_of_return_max_5y, :decimal
    add_column :projections, :projected_rate_of_return_best_5y, :decimal
    add_column :projections, :projected_eps_10y, :decimal
    add_column :projections, :projected_price_worst_10y, :decimal
    add_column :projections, :projected_price_min_10y, :decimal
    add_column :projections, :projected_price_max_10y, :decimal
    add_column :projections, :projected_price_best_10y, :decimal
    add_column :projections, :projected_rate_of_return_worst_10y, :decimal
    add_column :projections, :projected_rate_of_return_min_10y, :decimal
    add_column :projections, :projected_rate_of_return_max_10y, :decimal
    add_column :projections, :projected_rate_of_return_best_10y, :decimal
  end
end
