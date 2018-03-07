require 'open-uri'
require 'nokogiri'

module Client

  module HistoricalPrice

    class Investopedia < Provider

      BASE_URL = "https://www.investopedia.com/markets/api/partial"

      def initialize
        @country = 'us'
      end

      def client
        @client ||= ::Client.new
      end

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
            'open': quote["Open"].to_f,
            'high': quote["High"].to_f,
            'low': quote["Low"].to_f,
            'close': quote["Adj. Close"].to_f,
            'adjusted_close': quote["Adj. Close"].to_f,
            'volume': quote["Volume"].gsub(/[^\d^\.]/, '').to_i
          })
        end
        result
      end

    end

  end

end
