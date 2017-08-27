require 'parallel'

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
        downloading_statement(url, period, symbol, type)
      end

      def balance_sheet(symbol, period)
        type = 'Balance Sheet'
        url = build_url(symbol, type, period)
        downloading_statement(url, period, symbol, type)
      end

      def cashflow_statement(symbol, period)
        type = 'Cash Flow'
        url = build_url(symbol, type, period)
        downloading_statement(url, period, symbol, type)
      end

      def download_financials(period = 'MRY')
        ds = []# downloaded_symbols
        missing_companies = @companies.reject { |c| ds.include?(c.symbol) }
        total = missing_companies.size
        puts "FOUND #{total} companies from which we need the financial statements"
        #missing_companies.sort.each_with_index do |company, i|
        Parallel.map(missing_companies.sort.each_slice(500).with_index, in_processes: 15, progress: "Downloading #{period} financial statements") do |company_batch, i|
          company_batch.each_with_index do |company, i|
            puts "(#{i + 1}/#{total}) Downloading financial statements for '#{company.name}' (ID: #{company.id}, Symbol: #{company.symbol})."
            income_statement(company.symbol, period)
            puts '------ Income statement downloaded'
            balance_sheet(company.symbol, period)
            puts '------ Balance sheet downloaded'
            cashflow_statement(company.symbol, period)
            puts '------ Cash flow statement downloaded'
          end
        end
      end

    end

  end

end
