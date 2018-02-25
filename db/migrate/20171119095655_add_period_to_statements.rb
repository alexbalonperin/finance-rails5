class AddPeriodToStatements < ActiveRecord::Migration[5.0]
  def change
    add_column :income_statements, :period, :string
    add_column :balance_sheets, :period, :string
    add_column :cash_flow_statements, :period, :string
  end
end
