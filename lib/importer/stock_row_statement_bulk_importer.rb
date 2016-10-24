module Importer

  class StockRowStatementBulkImporter < StatementBulkImporter

    def initialize(companies = nil, dry_run = false)
      @companies = companies || Company.active
      @importer = StockRowStatementImporter
      @dry_run = dry_run
    end

  end

end
