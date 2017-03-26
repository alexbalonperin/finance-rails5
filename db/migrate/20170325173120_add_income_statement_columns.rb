class AddIncomeStatementColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :income_statements, :operating_expenses, :decimal
    add_column :income_statements, :operating_income, :decimal
    add_column :income_statements, :earnings_before_tax, :decimal
    add_column :income_statements, :net_income_to_non_controlling_interests, :decimal
    add_column :income_statements, :ebitda, :decimal
  end
end
