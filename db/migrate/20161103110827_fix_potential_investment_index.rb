class FixPotentialInvestmentIndex < ActiveRecord::Migration[5.0]
  def change
    remove_index :potential_investments, name: 'index_potential_investments_on_latest_and_company_id'
    add_index :potential_investments, [:company_id, :year], where: 'latest is true', unique: true
  end
end
