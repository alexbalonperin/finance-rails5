require 'open-uri'
require 'nokogiri'

module Client

  module HistoricalPrice

    class Investopedia < Provider

      BASE_URL = "https://www.investopedia.com/markets/api/partial"

      def historical_quotes(symbol, opts = {})
        params = {
          Symbol: symbol,
					Type: "Historical Prices",
          Timeframe: "Daily",
          StartDate: (opts[:start_date] - 1.day || Time.now - 2.day).strftime("%m/%d/%Y"),
          EndDate: Time.now.strftime("%m/%d/%Y")
        }
        url = "#{BASE_URL}/historical/?#{URI.escape(params.map{|k, v| "#{k}=#{v}"}.join("&"))}"

        doc = Nokogiri::HTML(open(url))
        data = doc.search(".data")[0]
        headers = data.search("th").map(&:text)
        result = []
        data.search(".in-the-money").each do |row|
          values = row.search("td").map(&:text)
          quote = Hash[headers.zip(values)]
          next if quote.values.any? { |v| v.nil? }
          result << OpenStruct.new({
            'symbol': symbol,
            'trade_date': Date.parse(quote["Date"]).to_s,
            'open': clean_number(quote["Open"]),
            'high': clean_number(quote["High"]),
            'low': clean_number(quote["Low"]),
            'close': clean_number(quote["Adj. Close"]),
            'adjusted_close': clean_number(quote["Adj. Close"]),
            'volume': clean_number(quote["Volume"]).to_i
          })
        end
        result
      end

      def clean_number(input)
        input.gsub(/[^\d^\.]/, '').to_f
      end

    end

  end

end
