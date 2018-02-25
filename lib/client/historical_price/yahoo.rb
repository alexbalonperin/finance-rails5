require 'client/yahoo_client.rb'

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

      def symbol_changes
        client.symbol_changes
      end


      def client_v7
        @client ||= Client::YahooFinanceClientV7.new
      end

      def quote(symbol, opts = {})
        client_v7.quotes(symbol)
      end

    end

  end

end
