class ModifyPotentialInvestmentIndex < ActiveRecord::Migration[5.0]
  def change
    remove_index :potential_investments, name: 'index_potential_investments_on_company_id_and_year'
    add_index :potential_investments, [:company_id, :year, :selector], where: 'latest is true', unique: true
  end
end
