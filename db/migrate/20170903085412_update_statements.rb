class UpdateStatements < ActiveRecord::Migration[5.0]
  def change
    add_column :income_statements, :ebitda_margin, :decimal
    add_column :income_statements, :ebit_margin, :decimal
    add_column :income_statements, :profit_margin, :decimal
    add_column :income_statements, :free_cash_flow_margin, :decimal
    add_column :income_statements, :consolidated_income, :decimal
    add_column :balance_sheets, :cash_and_short_term_investments, :decimal
  end
end
