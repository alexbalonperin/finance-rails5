module Client

  module FinancialStatement

    class StockRow < Provider

      SERVICE_URI = 'https://stockrow.com/api/companies'
      FILE_NAME = 'financials'

      PERIODS = %w[MRQ MRY MRT]
      TYPES = ["Metrics", "Cash Flow", "Balance Sheet", "Income Statement", "Growth"]

      def build_url(symbol, type, period)
        unless PERIODS.include?(period)
          raise "Period '#{period}' is unavailable. Please select one of #{PERIODS.join(", ")}."
        end
        unless TYPES.include?(type)
          raise "Type '#{type}' is unavailable. Please select one of #{TYPES.join(", ")}."
        end

        url_symbol = symbol.gsub(".","").gsub("^", "_P_")
        "#{SERVICE_URI}/#{url_symbol}/#{FILE_NAME}.xlsx?dimension=#{period}&section=#{type}"
      end

      def income_statement(symbol, period)
        type = 'Income Statement'
        url = build_url(symbol, type, period)
        downloading_statement(url, symbol, type)
      end

      def balance_sheet(symbol, period)
        type = 'Balance Sheet'
        url = build_url(symbol, type, period)
        downloading_statement(url, symbol, type)
      end

      def cashflow_statement(symbol, period)
        type = 'Cash Flow'
        url = build_url(symbol, type, period)
        downloading_statement(url, symbol, type)
      end

      def download_financials
        ds = downloaded_symbols
        missing_companies = @companies.reject { |c| ds.include?(c.symbol) }
        total = missing_companies.size
        puts "FOUND #{total} companies from which we need the financial statements"
        missing_companies.each_with_index do |company, index|
          puts "(#{index}/#{total}) Downloading financial statements for '#{company.name}' (ID: #{company.id}, Symbol: #{company.symbol})."
          income_statement(company.symbol, 'MRY')
          puts '------ Income statement downloaded'
          balance_sheet(company.symbol, 'MRY')
          puts '------ Balance sheet downloaded'
          cashflow_statement(company.symbol, 'MRY')
          puts '------ Cash flow statement downloaded'
        end
      end

    end

  end

end
