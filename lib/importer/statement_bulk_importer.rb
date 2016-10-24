module Importer

  class StatementBulkImporter

    def initialize(companies = nil, dry_run = false)
      @companies = companies || Company.active
      @importer = StatementImporter
      @dry_run = dry_run
    end

    def import
      total = @companies.size
      @companies.each_with_index do |company, index|
        "(#{index}/#{total}) Importing Statements for company #{company.name}"
        importer = @importer.new(company.symbol, @dry_run)
        importer.import_statements
      end
      puts 'Done'
    end

  end

end
