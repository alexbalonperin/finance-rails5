class AddColumnIncomeStatement < ActiveRecord::Migration[5.0]
  def change
    add_column :income_statements, :revenue_growth, :decimal
  end
end
