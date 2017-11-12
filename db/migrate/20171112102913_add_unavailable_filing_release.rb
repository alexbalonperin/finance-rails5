class AddUnavailableFilingRelease < ActiveRecord::Migration[5.0]
  def change
    add_column :filing_releases, :available, :boolean, :default => true
  end
end
