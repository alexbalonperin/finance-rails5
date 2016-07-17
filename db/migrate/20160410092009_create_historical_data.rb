class CreateHistoricalData < ActiveRecord::Migration
  def change
    create_table :historical_data do |t|
      t.date :trade_date
      t.decimal :open
      t.decimal :high
      t.decimal :low
      t.decimal :close
      t.integer :volume
      t.decimal :adjusted_close
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
