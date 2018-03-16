class AddDefaultToCompaniesTimestamps < ActiveRecord::Migration[5.0]
  def change
    change_column_default :companies, :created_at, -> { 'CURRENT_TIMESTAMP' }
    change_column_default :companies, :updated_at, -> { 'CURRENT_TIMESTAMP' }
  end
end
