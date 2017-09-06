module Client

  module HistoricalPrice

    class Provider

      def records_to_historical_data(records, company_id)
        records.inject([]) do |arr, record|
          arr << HistoricalDatum.new(trade_date: record.trade_date,
                                     open: record.open,
                                     high: record.high,
                                     low: record.low,
                                     close: record.close,
                                     volume: record.volume,
                                     adjusted_close: record.adjusted_close,
                                     company_id: company_id)
        end
      end

      def historical_data_update(company)
        last = company.last_trade_date
        start_date = last.present? ? last + 1.day : Time.now() - 30.years
        if company.historical_data_uptodate?
          puts "Historical data up-to-date for #{company.name}"
          return
        end
        puts "Updating historical data for : #{company.name}"
        begin
          historical_quotes(company.symbol.gsub('.', '-'), :start_date => start_date)
        rescue StandardError => e
          puts "Couldn't fetch data for company #{company.name}. Error: #{e.message}"
          company.update(:skip_historical_data => true)
          []
        end
      end

      def historical_data(companies)
        companies.inject({}) do |h, company|
          h[company.id] = historical_data_update(company)
          h
        end
      end

    end

  end

end
