module Importer

  class StatementBulkImporter
    FORM_10K = '10-K'

    def initialize(companies = nil, dry_run = false)
      @companies = companies || Company.active
      @importer = StatementImporter
      @dry_run = dry_run
    end

    def import(form_type=FORM_10K)
      total = @companies.size
      @companies.each_with_index do |company, index|
        "(#{index}/#{total}) Importing Statements for company #{company.name}"
        importer = @importer.new(company.symbol, @dry_run)
        importer.import_statements(form_type)
      end
      puts 'Done'
    end

  end

end
