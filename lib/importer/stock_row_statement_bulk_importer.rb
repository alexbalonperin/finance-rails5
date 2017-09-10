module Importer

  class StockRowStatementBulkImporter < StatementBulkImporter

    def initialize(dry_run = false)
      @importer = StockRowStatementImporter
      @dry_run = dry_run
    end

  end

end
