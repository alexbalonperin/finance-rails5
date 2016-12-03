class CreateWatchlists < ActiveRecord::Migration[5.0]
  def change
    create_table :watchlists do |t|
      t.references :company, foreign_key: true, unique: true
      t.timestamp :deleted_at

      t.timestamps
    end
  end
end
