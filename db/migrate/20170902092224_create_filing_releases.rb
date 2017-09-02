class CreateFilingReleases < ActiveRecord::Migration[5.0]
  def change
    create_table :filing_releases do |t|
      t.string :cik
      t.references :company, index: true, foreign_key: true
      t.string :form_type
      t.string :date
      t.string :filename

      t.timestamps null: false
    end
    add_index :filing_releases, [:company_id, :form_type, :date], :unique => true
  end
end
