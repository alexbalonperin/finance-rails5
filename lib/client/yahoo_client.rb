module Client
      class YahooFinanceClientV7
        require 'http'
        require 'json'

        URL = "https://query1.finance.yahoo.com/v7/finance"

        Quote = Struct.new(
          :symbol,
          :currency,
          :previous_close,
          :bid,
          :ask,
          :company_name,
          :fifty_two_week_low_change,
          :fifty_two_week_low_change_percent,
          :fifty_two_week_high_change,
          :fifty_two_week_high_change_percent,
          :fifty_two_week_low,
          :fifty_two_week_high,
          :dividend_date,
          :earnings_timestamp,
          :earnings_timestamp_start,
          :earnings_timestamp_end,
          :shares_outstanding,
          :fifty_day_average,
          :fifty_day_average_change,
          :fifty_day_average_change_percent,
          :two_hundred_day_average,
          :two_hundred_day_average_change,
          :two_hundred_day_average_change_percent,
          :market_cap,
          :market,
          :open,
          :high,
          :low,
          :volume
        )

        def quotes(symbol)
          result = HTTP.get("#{URL}/quote?symbols=#{symbol}")
          json = JSON.parse(result)
          result = json["quoteResponse"]["result"][0]
          quote = Quote.new(
            result["symbol"],
            result["currency"],
            result["regularMarketPreviousClose"],
            result["bid"],
            result["ask"],
            result["shortName"],
            result["fiftyTwoWeekLowChange"],
            result["fiftyTwoWeekLowChangePercent"],
            result["fiftyTwoWeekHighChange"],
            result["fiftyTwoWeekHighChangePercent"],
            result["fiftyTwoWeekLow"],
            result["fiftyTwoWeekHigh"],
            result["dividendDate"],
            result["earningsTimestamp"],
            result["earningsTimestampStart"],
            result["earningsTimestampEnd"],
            result["sharesOutstanding"],
            result["fiftyDayAverage"],
            result["fiftyDayAverageChange"],
            result["fiftyDayAverageChangePercent"],
            result["twoHundredDayAverage"],
            result["twoHundredDayAverageChange"],
            result["twoHundredDayAverageChangePercent"],
            result["marketCap"],
            result["market"],
            result["regularMarketOpen"],
            result["regularMarketDayHigh"],
            result["regularMarketDayLow"],
            result["regularMarketVolume"]
          )
          quote
        end

      end

end
