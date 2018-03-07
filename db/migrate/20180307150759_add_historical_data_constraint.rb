class AddHistoricalDataConstraint < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      alter table historical_data
        add constraint for_upsert unique (company_id, trade_date);
    SQL
  end

  def down
    execute <<-SQL
      alter table historical_data
        drop constraint if exists for_upsert;
    SQL
  end
end
