class AddPriceAtReportingDateToProjection < ActiveRecord::Migration[5.0]
  def change
    add_column :projections, :price_at_reporting_time, :decimal
  end
end
