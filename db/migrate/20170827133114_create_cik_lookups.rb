class CreateCikLookups < ActiveRecord::Migration[5.0]
  def change
    create_table :cik_lookups do |t|
      t.string :cik
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :cik_lookups, [:cik, :company_id], :unique => true
  end
end
