class AddHistoricalDataUniqueConstraint < ActiveRecord::Migration[5.0]
  def change
    add_index :historical_data, [:trade_date, :company_id], :unique => true
  end
end
