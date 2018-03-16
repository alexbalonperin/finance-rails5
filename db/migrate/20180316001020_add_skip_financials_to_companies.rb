class AddSkipFinancialsToCompanies < ActiveRecord::Migration[5.0]
  def change
    add_column :companies, :skip_financials, :boolean, default: false
  end
end
