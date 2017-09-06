class UpdateFilingReleasesIndex < ActiveRecord::Migration[5.0]
  def change
    remove_index :filing_releases, :name => 'index_filing_releases_on_company_id_and_form_type_and_date'
    add_index :filing_releases, [:cik, :company_id, :form_type, :date], :unique => true, :name => 'filing_releases_unique_idx'
  end
end
