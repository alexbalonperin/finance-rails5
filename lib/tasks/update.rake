namespace :update do

  def client
    @client ||= Client::HistoricalPrice::Yahoo.new
  end

  desc 'update historical data for all companies in the database'
  task historical_data: :environment do
    companies = Company.where('skip_historical_data is false and active')
    puts "Found #{companies.size} to update"
    companies.sort.each_with_index do |company, i|
      puts "#{i}: #{company.name}"
      records = client.historical_data_update(company)
      next if records.nil? || records.empty?
      data = client.records_to_historical_data(records, company.id)
      last_trade_date = data.sort_by(&:trade_date).last.trade_date
      company.update(:last_trade_date => last_trade_date)
      HistoricalDatum.import(data)
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
