require 'upsert/active_record_upsert'

module Importer

  class StatementImporter
    require 'roo'

    DOWNLOAD_DIR = 'data/financial_statements'
    FORM_10K = '10-K'
    FORM_10Q = '10-Q'
    FORM_TYPES = [FORM_10K, FORM_10Q]
    FORM_TYPE_TO_PERIOD = {
      FORM_10K => 'yearly',
      FORM_10Q => 'quarterly'
    }

    def initialize(symbol, dry_run = false)
      @symbol = symbol
      @company = Company.where(:symbol => @symbol).first
      @file_path = DOWNLOAD_DIR
      @dry_run = dry_run
    end

    def latest_file(file_path)
      filenames = Utils::FileUtil.filenames(file_path)
      return if filenames.nil?
      latest_filename = filenames.sort.last
      return if latest_filename.nil?
      "#{file_path}/#{latest_filename}"
    end

    def record_error(statement_type, error_type, error)
      begin
        StatementError.create({
            :company_id => @company.id,
            :statement_type => statement_type,
            :error => error,
            :error_type => error_type
        })
      rescue => e1
        puts "Couldn't save error. Error: #{e1}"
      end
    end

    def workbook(type, form_type=FORM_10K)
      period = FORM_TYPE_TO_PERIOD[form_type]
      file_path = "#{@file_path}/#{period}/#{@symbol}/#{type}"
      file = latest_file(file_path)
      if file.nil?
        error = "Couldn't find any file to import for symbol '#{@symbol}'"
        puts error
        record_error(type, 'missing', error)
        return
      end
      Roo::Spreadsheet.open(file, extension: :xlsx)
    end

    def map_data(type, mapping)
      raise 'Should be implemented by subclass'
    end

    def import_data(klass, type, mapping, form_type=FORM_10K)
      raise ArgumentError unless FORM_TYPES.include?(form_type)
      puts '****************DRY RUN*************' if @dry_run
      text = klass.to_s.split(/(?=[A-Z])/).join(' ').downcase
      puts "Importing #{text} data for company #{@company.name} (ID: #{@company.id}, Symbol: #{@company.symbol})"
      h = map_data(type, mapping)
      return if h.nil?
      h.each do |year, kfi|
        puts "------- importing data for year #{year}"
        entity = kfi.merge({:year => year, :company_id => @company.id, created_at: Time.now, updated_at: Time.now, form_type: form_type})
        if @dry_run
          puts "Would import: #{entity.inspect}"
          next
        end
        klass.upsert({company_id: @company.id, report_date: kfi[:report_date]}, entity)
      end
      puts 'Done'
    end

    def import_statements(form_type=FORM_10K)
      import_income_statement(form_type)
      import_balance_sheet(form_type)
      import_cashflow_statement(form_type)
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

    def import_income_statement(form_type=FORM_10K)
      import_data(IncomeStatement, 'Income Statement', income_stat_mapping, form_type)
    end

    def import_balance_sheet(form_type=FORM_10K)
      import_data(BalanceSheet, 'Balance Sheet', balance_sheet_mapping, form_type)
    end

    def import_cashflow_statement(form_type=FORM_10K)
      import_data(CashFlowStatement, 'Cash Flow', cashflow_statement_mapping, form_type)
    end

  end

end
