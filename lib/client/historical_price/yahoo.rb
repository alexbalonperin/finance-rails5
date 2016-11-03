module Client

  module HistoricalPrice

    class Yahoo < Provider

      def initialize
        @country = 'us'
      end

      def client
        @client ||= YahooFinance::Client.new
      end

      def companies(markets = %w[nyse amex nasdaq])
        client.companies(@country, markets)
      end

      def sectors
        client.sectors(@country)
      end

      def industries
        client.industries(@country)
      end

      def historical_quotes(symbol, opts = {})
        client.historical_quotes(symbol, opts)
      end

    end

  end

end
