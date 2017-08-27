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
