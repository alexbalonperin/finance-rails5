require 'parallel'

namespace :update do

  def client
    @client ||= Client::HistoricalPrice::Yahoo.new
  end

  def historical_data_client
    @historical_data_client ||= Client::HistoricalPrice::Investopedia.new
  end

  desc 'update historical data for all companies in the database'
  task historical_data: :environment do
    number_of_processes = 15
    companies = Company.where('skip_historical_data is false and active')
    companies = companies.reject { |c| c.historical_data_uptodate? }
    puts "Found #{companies.size} companies to update"
    next if companies.empty?
    batch_size = (companies.size.to_f/number_of_processes).ceil
    Parallel.map(companies.sort.each_slice(batch_size), in_processes: number_of_processes) do |company_batch|
      ActiveRecord::Base.connection.reconnect!
      company_batch.each_with_index do |company, i|
        puts "#{i+1}: #{company.name} (id: #{company.id}, symbol: #{company.symbol})"
        begin
          records = historical_data_client.historical_data_update(company)
        rescue
          puts "Error fetching historical data for company #{company}"
          next
        end
        next if records.nil? || records.empty?
        data = historical_data_client.records_to_historical_data(records, company.id)
        last_trade_date = data.sort_by(&:trade_date).last.trade_date
        company.update(:last_trade_date => last_trade_date)
        duplicate_config = {
          constraint_name: :for_upsert,
          columns: [:open, :high, :low, :close, :adjusted_close, :volume]
        }
        HistoricalDatum.import(data, on_duplicate_key_update: duplicate_config)
      end
    end
    ActiveRecord::Base.connection.reconnect!
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

  desc 'Manual Symbol changes'
  task manual_symbol_changes: :environment do
    data = []
    CSV.foreach('data/symbol_change/changes.csv') do |row|
      next if row.first == 'from'
      from_symbol = row.first
      to_symbol = row.last
      puts "Changing symbol from #{from_symbol} to #{to_symbol}"
      from = Company.where('symbol = ?', from_symbol).first
      to = Company.new(
        name: from.name,
        industry: from.industry,
        symbol: to_symbol,
        market_id: from.market_id,
        last_trade_date: from.last_trade_date,
        first_trade_date: from.first_trade_date,
        ipo_year: from.ipo_year,
        market_cap: from.market_cap
      )
      company_change = CompaniesChange.new
      company_change.from = from
      company_change.to = to
      already_exists = Company.where("symbol = ?", to_symbol).first
      unless already_exists
        from.active = false
        if !from.save || !company_change.save || !to.save
          puts "Couldn't change symbol for company #{from.name} (#{from.symbol})."
        end
      end
    end
  end

  desc 'get latest filings information'
  task latest_filings: :environment do
    client = Client::FinancialStatement::Edgar.new
    client.get_latest_filings
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

  desc 'calculate projections for potential investments'
  task :potential_investments_projections, [:year] => [:environment] do |r, args|
    Financials::Projection.project_for_potential_investments(args[:year] || Time.current.year - 1)
  end

  desc 'statements health check'
  task statements_health_check: :environment do
    companies = Company.active
    companies.each_with_index do |company, j|
      #puts "#{j+1}: checking company #{company.name}"
      bs_years = company.balance_sheets.yearly.map(&:year).sort
      is_years = company.income_statements.yearly.map(&:year).sort
      cfs_years = company.cash_flow_statements.yearly.map(&:year).sort
      if check_years(bs_years)
        puts "Balance sheet for company #{company.name} (#{company.id}/#{company.symbol}) missing"
        puts bs_years.join(',')
      end
      if check_years(is_years)
        puts "Income statement for company #{company.name} (#{company.id}/#{company.symbol}) missing"
        puts is_years.join(',')
      end
      if check_years(cfs_years)
        puts "Cash flow statement for company #{company.name} (#{company.id}/#{company.symbol}) missing"
        puts cfs_years.join(',')
      end
    end
  end

  def check_years(years)
    error = false
    years.each_with_index do |year, i|
      next if i >= years.size - 1
      if years[i + 1].to_i != year.to_i + 1
        error = true
      end
    end
    error
  end

  desc 'quote'
  task quote: :environment do
    client.quote("AAPL")
  end

end
