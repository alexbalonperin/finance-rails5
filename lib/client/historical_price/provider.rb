module Client

  module HistoricalPrice

    class Provider

      def last_open_ended_trading_date
        time = Time.current
        if time.monday?
          time = time - 3.days
        elsif time.sunday?
          time = time - 2.days
        elsif time.saturday?
          time = time - 1.day
        end
        time.to_date
      end

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
        start_date = last.present? ? last + 1.day : nil
        if start_date.present? &&
            start_date >= last_open_ended_trading_date &&
            start_date <= Time.current.to_date
          puts "Historical data up-to-date for #{company.name}"
          return
        end
        puts "Updating historical data for : #{company.name}"
        begin
          historical_quotes(company.symbol, :start_date => start_date)
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
