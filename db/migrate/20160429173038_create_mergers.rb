class CreateMergers < ActiveRecord::Migration
  def change
    create_table :mergers do |t|
      t.timestamps null: false
    end
    add_reference :mergers, :acquiring, references: :companies, index: true
    add_reference :mergers, :acquired, references: :companies, index: true
    add_foreign_key :mergers, :companies, column: :acquiring_id
    add_foreign_key :mergers, :companies, column: :acquired_id
  end
end
