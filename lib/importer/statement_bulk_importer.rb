module Importer

  class StatementBulkImporter
    FORM_10K = '10-K'

    def initialize(dry_run = false)
      @importer = StatementImporter
      @dry_run = dry_run
    end

    def import(form_type=FORM_10K)
      filings = filings_to_import(form_type)
      filings = filings.select(&:available)
      total = filings.size
      puts "Found #{total} reports to import"
      filings.each_with_index do |filing, index|
        company = filing.company
        next unless company.active
        next unless filing.available
        puts "(#{index}/#{total}) Importing Statements for company #{company.name}"
        importer = @importer.new(company.symbol, @dry_run)
        begin
          importer.import_statements(form_type)
          filing.imported = true
        rescue => e
          puts "Coudn't find statements for company #{company.id} - #{form_type} (filing: #{filing.id}) (Error: #{e})"
          filing.downloaded = false
        end
        if !filing.save
          puts "Couldn't mark report as imported for company #{company.name} (id: #{company.id}, symbol: #{company.symbol})"
        end
      end
      puts 'Done'
    end

    def import_all(form_type=FORM_10K)
      companies = Company.active
      total = companies.size
      puts "Found #{total} reports to import"
      companies.each_with_index do |company, index|
        next if company.skip_financials
        puts "(#{index}/#{total}) Importing Statements for company #{company.name}"
        importer = @importer.new(company.symbol, @dry_run)
        begin
          importer.import_statements(form_type)
        rescue => e
          puts "Coudn't find statements for company #{company.id} - #{form_type}"
        end
      end
      puts 'Done'
    end


    def filings_to_import(form_type=FORM_10K)
      FilingRelease.where('form_type = ? and not imported', form_type)
    end

  end

end
