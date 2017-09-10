module Importer

  class StatementBulkImporter
    FORM_10K = '10-K'

    def initialize(dry_run = false)
      @importer = StatementImporter
      @dry_run = dry_run
    end

    def import(form_type=FORM_10K)
      filings = filings_to_import(form_type)
      total = filings.size
      filings.each_with_index do |filing, index|
        company = filing.company
        puts "(#{index}/#{total}) Importing Statements for company #{company.name}"
        importer = @importer.new(company.symbol, @dry_run)
        importer.import_statements(form_type)
        filing.imported = true
        if !filing.save
          puts "Couldn't mark report as imported for company #{company.name} (id: #{company.id}, symbol: #{company.symbol})"
        end
      end
      puts 'Done'
    end

    def filings_to_import(form_type=FORM_10K)
      FilingRelease.where('form_type = ? and not imported', form_type)
    end

  end

end
