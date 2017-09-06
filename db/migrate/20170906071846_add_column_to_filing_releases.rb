class AddColumnToFilingReleases < ActiveRecord::Migration[5.0]
  def change
    add_column :filing_releases, :downloaded, :boolean, :default => false
  end
end
