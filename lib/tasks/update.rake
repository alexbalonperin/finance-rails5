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
    batch_size = (companies.size.to_f/number_of_processes).ceil
    Parallel.map(companies.sort.each_slice(batch_size), in_processes: number_of_processes) do |company_batch|
      company_batch.each_with_index do |company, i|
        puts "#{i+1}: #{company.name}"
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

  task test: :environment do
    company = Company.where('symbol = ?', 'BRK-A').first
    puts company.name, company.id, company.symbol

    records = client.historical_data_update(company)
    data = client.records_to_historical_data(records, company.id)
    last_trade_date = data.sort_by(&:trade_date).last.trade_date

    company.update(:last_trade_date => last_trade_date)
    result = HistoricalDatum.import(data)
  end

  task symbol_changes: :environment do
    records = client.symbol_changes
    companies = Company.where('symbol in (?)', records.map(&:old_symbol))
    old_symbols = companies.map(&:symbol)
    records.select { |record| old_symbols.include?(record.old_symbol) }.each do |record|
      c_old = companies.find { |c| c.symbol == record.old_symbol }
      puts "Changing symbol for company #{c_old.name} from #{record.old_symbol} to #{record.new_symbol} (effective date: #{record.effective_date})"
      c_new = c_old.dup
      c_new.symbol = record.new_symbol
      c_old.active = false
      begin
        if c_new.save && c_old.save
          puts "Done changing symbol for company #{c_old.name}"
        else
          puts "Could not update symbol for company #{c_old.name}"
        end
      rescue StandardError => e
        puts "Could not update symbol for company #{c_old.name}"
      end
    end
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
