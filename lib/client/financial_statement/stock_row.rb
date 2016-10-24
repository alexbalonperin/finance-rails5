require "#{Rails.root}/lib/client/financial_statement/provider"

module Client

  module FinancialStatement

    class StockRow < Provider

      SERVICE_URI = 'https://stockrow.com'
      FILE_NAME = 'financials'

      PERIODS = %w[q y t]
      TYPES = %w[metrics cashflow balance income growth]

      def build_url(symbol, type, period)
        unless PERIODS.include?(period)
          raise "Period '#{period}' is unavailable. Please select one of #{PERIODS.join(", ")}."
        end
        unless TYPES.include?(type)
          raise "Type '#{type}' is unavailable. Please select one of #{TYPES.join(", ")}."
        end

        "#{SERVICE_URI}/#{symbol}/#{FILE_NAME}.xlsx?d=#{period}&s=#{type}"
      end

      def income_statement(symbol, period)
        type = 'income'
        url = build_url(symbol, type, period)
        downloading_statement(url, symbol, type)
      end

      def balance_sheet(symbol, period)
        type = 'balance'
        url = build_url(symbol, type, period)
        downloading_statement(url, symbol, type)
      end

      def cashflow_statement(symbol, period)
        type = 'cashflow'
        url = build_url(symbol, type, period)
        downloading_statement(url, symbol, type)
      end

      def download_financials(companies)
        ds = downloaded_symbols
        missing_companies = companies.reject { |c| ds.include?(c.symbol) }
        total = missing_companies.size
        puts "FOUND #{total} companies from which we need the financial statements"
        missing_companies.each_with_index do |company, index|
          puts "(#{index}/#{total}) Downloading financial statements for '#{company.name}' (ID: #{company.id}, Symbol: #{company.symbol})."
          income_statement(company.symbol, 'y')
          puts '------ Income statement downloaded'
          balance_sheet(company.symbol, 'y')
          puts '------ Balance sheet downloaded'
          cashflow_statement(company.symbol, 'y')
          puts '------ Cash flow statement downloaded'
        end
      end

    end

  end

end
