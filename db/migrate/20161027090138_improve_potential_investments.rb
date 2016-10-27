class ImprovePotentialInvestments < ActiveRecord::Migration[5.0]
  def change
    add_column :potential_investments, :current_price, :decimal
    add_column :potential_investments, :fair_price_min, :decimal
    add_column :potential_investments, :fair_price_max, :decimal
    add_column :potential_investments, :latest, :boolean, default: true

    add_index :potential_investments, [:latest, :company_id], unique: true
  end
end
