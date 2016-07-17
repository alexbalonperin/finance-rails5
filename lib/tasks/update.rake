require "#{Rails.root}/lib/client/yahoo"

namespace :update do

  def client
    @client ||= Client::Yahoo.new
  end

  desc 'update historical data for all companies in the database'
  task historical_data: :environment do
    companies = Company.where('skip_historical_data is false and active')
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

end
