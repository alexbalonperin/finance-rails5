require 'quandl'

module Client

  module HistoricalPrice

    class QuandlClient < Provider

      def initialize
        @country = 'us'
        Quandl::ApiConfig.api_key = ENV['QUANDL_API_KEY']
        Quandl::ApiConfig.api_version = '2015-04-09'
        client
      end

      def client
        Quandl::Dataset
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
        client.get("WIKI/#{symbol}").data(params: opts).values
      end

    end

  end

end
