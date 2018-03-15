class ChangeVolumeColumnType < ActiveRecord::Migration[5.0]
  def change
    change_column :historical_data, :volume, :integer, :limit => 5
  end
end
