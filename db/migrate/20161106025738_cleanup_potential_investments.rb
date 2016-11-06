class CleanupPotentialInvestments < ActiveRecord::Migration[5.0]
  def change

    remove_column :potential_investments, :current_price
    remove_column :potential_investments, :projected_eps
    remove_column :potential_investments, :projected_price_min
    remove_column :potential_investments, :projected_price_max
    remove_column :potential_investments, :projected_rate_of_return_min
    remove_column :potential_investments, :projected_rate_of_return_max
  end
end
