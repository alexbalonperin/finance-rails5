class ModifyStatementIndices < ActiveRecord::Migration[5.0]
  def change
    add_column :income_statements, :form_type, :string
    add_index :income_statements, [:company_id, :report_date, :form_type], :unique => true, :name => 'income_statements_unique_idx'
    add_column :balance_sheets, :form_type, :string
    add_index :balance_sheets, [:company_id, :report_date, :form_type], :unique => true, :name => 'balance_sheets_unique_idx'
    add_column :cash_flow_statements, :form_type, :string
    add_index :cash_flow_statements, [:company_id, :report_date, :form_type], :unique => true, :name => 'cash_flow_statements_unique_idx'

    remove_index :income_statements, :name => 'index_income_statements_on_company_id_and_year'
    remove_index :balance_sheets, :name => 'index_balance_sheets_on_company_id_and_year'
    remove_index :cash_flow_statements, :name => 'index_cash_flow_statements_on_company_id_and_year'
  end
end
