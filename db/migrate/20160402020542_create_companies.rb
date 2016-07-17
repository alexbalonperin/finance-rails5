class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.references :industry, index: true, foreign_key: true
      t.string :symbol

      t.timestamps null: false
    end
  end
end
