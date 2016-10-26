module Importer

  class StatementImporter
    require 'roo'

    DOWNLOAD_DIR = 'public/financial_statements'

    def initialize(symbol, dry_run = false)
      @symbol = symbol
      @company = Company.where(:symbol => @symbol).first
      @file_path = "#{DOWNLOAD_DIR}/#{@symbol}"
      @dry_run = dry_run
    end

    def latest_file(file_path)
      filenames = Utils::FileUtil.filenames(file_path)
      return if filenames.nil?
      latest_filename = filenames.sort.last
      return if latest_filename.nil?
      "#{file_path}/#{latest_filename}"
    end

    def workbook(type)
      file_path = "#{@file_path}/#{type}"
      file = latest_file(file_path)
      if file.nil?
        puts "Couldn't find any file to import for symbol '#{@symbol}"
        return
      end
      Roo::Spreadsheet.open(file, extension: :xlsx)
    rescue => e
      puts "Couldn't parse the file for symbol #{@symbol}. Error: #{e}"
      puts 'Skipping....'
    end

    def map_data(type, mapping)
      raise 'Should be implemented by subclass'
    end

    def import_data(klass, type, mapping)
      puts '****************DRY RUN*************' if @dry_run
      text = klass.to_s.split(/(?=[A-Z])/).join(' ').downcase
      puts "Importing #{text} data for company #{@company.name} (ID: #{@company.id}, Symbol: #{@company.symbol})"
      h = map_data(type, mapping)
      return if h.nil?
      h.each do |year, kfi|
        if klass.where(:year => year, :company_id => @company.id).first.present?
          puts "------- #{text} data for company #{@company.name}, year #{year} already exists."
        else
          puts "------- importing data for year #{year}"
          entity = kfi.merge({:year => year, :company_id => @company.id})
          if @dry_run
            puts "Would import: #{entity.inspect}"
            next
          end
          klass.create(entity)
        end
      end
      puts 'Done'
    end

    def import_statements
      import_income_statement
      import_balance_sheet
      import_cashflow_statement
    end

    def income_stat_mapping
      raise 'Should be implemented by subclass'
    end

    def balance_sheet_mapping
      raise 'Should be implemented by subclass'
    end

    def cashflow_statement_mapping
      raise 'Should be implemented by subclass'
    end

    def import_income_statement
      import_data(IncomeStatement, 'income', income_stat_mapping)
    end

    def import_balance_sheet
      import_data(BalanceSheet, 'balance', balance_sheet_mapping)
    end

    def import_cashflow_statement
      import_data(CashFlowStatement, 'cashflow', cashflow_statement_mapping)
    end

  end

end
