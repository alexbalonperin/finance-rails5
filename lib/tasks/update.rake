require 'parallel'

namespace :update do

  def client
    @client ||= Client::HistoricalPrice::Yahoo.new
  end

  desc 'update historical data for all companies in the database'
  task historical_data: :environment do
    number_of_processes = 15
    companies = Company.where('skip_historical_data is false and active')
    companies = companies.reject { |c| c.historical_data_uptodate? }
    puts "Found #{companies.size} to update"
    next if companies.empty?
    batch_size = (companies.size.to_f/number_of_processes).ceil
    Parallel.map(companies.sort.each_slice(batch_size), in_processes: number_of_processes) do |company_batch|
      company_batch.each_with_index do |company, i|
        puts "#{i+1}: #{company.name} (id: #{company.id}, symbol: #{company.symbol})"
        begin
          records = client.historical_data_update(company)
        rescue
          puts "Error fetching historical data for company #{company}"
          next
        end
        next if records.nil? || records.empty?
        data = client.records_to_historical_data(records, company.id)
        last_trade_date = data.sort_by(&:trade_date).last.trade_date
        company.update(:last_trade_date => last_trade_date)
        HistoricalDatum.import(data)
      end
    end
    puts 'Done updating historical data'
  end

  task symbol_changes: :environment do
    records = client.symbol_changes
    companies = Company.where('symbol in (?)', records.map(&:old_symbol))
    old_symbols = companies.map(&:symbol)
    already_changed = Company.where('symbol in (?)', records.map(&:new_symbol)).map(&:symbol)
    records = records.select { |record| !already_changed.include?(record.new_symbol) && old_symbols.include?(record.old_symbol) }
    puts "Found #{records.size} companies that have changed symbols"
    records.each do |record|
      c_old = companies.find { |c| c.symbol == record.old_symbol }
      next if c_old.nil?
      puts "Changing symbol for company #{c_old.name} from #{record.old_symbol} to #{record.new_symbol} (effective date: #{record.effective_date})"
      c_new = c_old.dup
      c_new.symbol = record.new_symbol
      c_old.active = false
      company_change = CompaniesChange.new
      company_change.from = c_old
      company_change.to = c_new
      begin
        if c_new.save && c_old.save && company_change.save
          puts "Done changing symbol for company #{c_old.name}"
        else
          puts "Could not update symbol for company #{c_old.name}. New: #{c_new.errors.full_messages}, Old: #{c_old.errors.full_messages}"
        end
      rescue StandardError => e
        puts "Could not update symbol for company #{c_old.name}. Error: #{e}. New: #{c_new.errors.full_messages}, Old: #{c_old.errors.full_messages}"
      end
    end
  end

  desc 'mergers and acquisitions'
  task mergers: :environment do
    data = []
    CSV.foreach('data/mergers/20170903.csv') do |row|
      next if row.first == 'acquiring'
      acquiring_symbol = row.first
      acquired_symbol = row.last
      acquiring = Company.where('symbol = ?', acquiring_symbol).first
      acquired = Company.where('symbol = ?', acquired_symbol).first
      already_recorded = Merger.where('acquiring_id = ? and acquired_id = ?', acquiring.id, acquired.id)
      if already_recorded.empty?
        data << Merger.new({acquiring_id: acquiring.id, acquired_id: acquired.id})
        acquired.active = false
        if !acquired.save
          puts "Couldn't deactivate company #{acquired.name} (#{acquired.symbol}). Error: #{acquired.errors.full_messages}"
        end
      end
    end
    puts "Found #{data.size} mergers"
    Merger.import(data) if data.present?
  end

  desc 'get latest filings information'
  task latest_filings: :environment do
    client = Client::FinancialStatement::Edgar.new
    client.get_latest_filings
  end

  desc 'get old filings information'
  task all_old_filings: :environment do
    client = Client::FinancialStatement::Edgar.new
    (1993..2015).to_a.reverse.each do |year|
      ['QTR1', 'QTR2', 'QTR3', 'QTR4'].each do |quarter|
        client.get_old_filings(year, quarter)
      end
    end
  end

  desc 'set fiscal year focus and fiscal period focus to statements'
  task set_period_focus: :environment do
    client = Client::FinancialStatement::Edgar.new
    client.set_period_focus
  end

  desc 'get old filings information'
  task :old_filings, [:year, :quarter] => [:environment] do |t, args|
    client = Client::FinancialStatement::Edgar.new
    client.get_old_filings(args[:year], args[:quarter])
  end

  desc 'get cik for each company'
  task cik_to_company_name: :environment do
    client = Client::FinancialStatement::Edgar.new
    client.cik_to_company_name
  end

  desc 'resolve financial statement errors'
  task resolve_fs_errors: :environment do
    resolver = Financials::StatementIssueResolver.new
    resolver.resolve
  end

  desc 'update the list of potential investments'
  task potential_investments: :environment do
    selector = Financials::BasicSelector.new
    selector.select
  end

end
