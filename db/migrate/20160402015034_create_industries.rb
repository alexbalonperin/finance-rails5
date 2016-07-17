class CreateIndustries < ActiveRecord::Migration
  def change
    create_table :industries do |t|
      t.string :name
      t.references :sector, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
