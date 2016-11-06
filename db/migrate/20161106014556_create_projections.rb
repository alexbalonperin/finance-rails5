class CreateProjections < ActiveRecord::Migration[5.0]
  def change
    create_table :projections do |t|
      t.references :company, foreign_key: true, index: true
      t.boolean :latest, default: true
      t.decimal :current_price
      t.decimal :projected_eps
      t.decimal :projected_price_worst
      t.decimal :projected_price_min
      t.decimal :projected_price_max
      t.decimal :projected_price_best
      t.decimal :projected_rate_of_return_worst
      t.decimal :projected_rate_of_return_min
      t.decimal :projected_rate_of_return_max
      t.decimal :projected_rate_of_return_best

      t.timestamps
    end
  end
end
