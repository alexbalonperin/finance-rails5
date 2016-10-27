class RenameStatementDownloadErrors < ActiveRecord::Migration[5.0]
  def change
    rename_table :statement_download_errors, :statement_errors
  end
end
