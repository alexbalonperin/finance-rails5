class CreatePotentialInvestments < ActiveRecord::Migration[5.0]
  def change
    create_table :potential_investments do |t|
      t.references :company, foreign_key: true, index: true
      t.string :selector
      t.decimal :roe_5y_annual_compounding_ror
      t.decimal :roe_10y_annual_compounding_ror
      t.boolean :roe_steady_growth
      t.decimal :eps_5y_annual_compounding_ror
      t.decimal :eps_10y_annual_compounding_ror
      t.boolean :eps_steady_growth
      t.decimal :n_past_financial_statements

      t.timestamps
    end
  end
end
