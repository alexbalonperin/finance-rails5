class AddYearToPotentialInvestments < ActiveRecord::Migration[5.0]
  def change
    add_column :potential_investments, :year, :string
  end
end
