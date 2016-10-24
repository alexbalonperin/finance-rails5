module Client

  module HistoricalPrice

    class Yahoo < Provider

      def client
        @client ||= YahooFinance::Client.new
      end

      def all_companies
        nyse_companies = companies('us', 'nyse')
        nasdaq_companies = companies('us', 'nasdaq')
        amex_companies = companies('us', 'amex')
        nyse_companies + nasdaq_companies + amex_companies
      end

      def companies(country, market_name)
        client.companies_by_market(country, market_name.downcase)
      end

      def historical_quotes(symbol, opts = {})
        client.historical_quotes(symbol, opts)
      end

    end

  end

end
