class AddColumnFilingRelease < ActiveRecord::Migration[5.0]
  def change
    add_column :filing_releases, :imported, :boolean, :default => false
  end
end
