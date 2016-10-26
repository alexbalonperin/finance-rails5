class CreateStatementDownloadErrors < ActiveRecord::Migration[5.0]
  def change
    create_table :statement_download_errors do |t|
      t.references :company, index: true, foreign_key: true
      t.string :statement_type
      t.string :error

      t.timestamps
    end
  end
end
