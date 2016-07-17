class AddSkipHistoricalDataToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :skip_historical_data, :boolean, :default => false
  end
end
