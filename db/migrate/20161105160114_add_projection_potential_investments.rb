class AddProjectionPotentialInvestments < ActiveRecord::Migration[5.0]
  def change
    remove_column :potential_investments, :fair_price_min
    remove_column :potential_investments, :fair_price_max

    add_column :potential_investments, :projected_eps, :decimal
    add_column :potential_investments, :projected_price_min, :decimal
    add_column :potential_investments, :projected_price_max, :decimal
    add_column :potential_investments, :projected_rate_of_return_min, :decimal
    add_column :potential_investments, :projected_rate_of_return_max, :decimal
  end
end
