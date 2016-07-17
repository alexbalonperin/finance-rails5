class CreateTableCompaniesChanges < ActiveRecord::Migration
  def change
    create_table :companies_changes do |t|
      t.timestamps null: false
    end
    add_reference :companies_changes, :from, references: :companies, index: true
    add_reference :companies_changes, :to, references: :companies, index: true
    add_foreign_key :companies_changes, :companies, column: :from_id
    add_foreign_key :companies_changes, :companies, column: :to_id
  end
end
