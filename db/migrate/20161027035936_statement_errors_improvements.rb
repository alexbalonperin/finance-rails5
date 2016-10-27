class StatementErrorsImprovements < ActiveRecord::Migration[5.0]
  def change
    add_column :statement_errors, :resolved, :boolean, default: false
    add_column :statement_errors, :resolved_at, :timestamp
    add_column :statement_errors, :error_type, :string
  end
end
