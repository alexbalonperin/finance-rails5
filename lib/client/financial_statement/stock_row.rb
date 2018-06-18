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

        url_symbol = symbol.gsub(".","").gsub("^", "_P_").gsub("-", "")
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
        reports = new_reports(period)
        reports = reports.select(&:available)
        total = reports.size
        puts "FOUND #{total} #{period} financial reports to download"
        Parallel.map(reports.sort.each_slice(100).with_index, in_processes: 5, progress: "Downloading #{period} financial statements") do |report_batch, i|
          report_batch.each_with_index do |report, j|
            company = report.company
            next unless company.active
            download(company, i, j, total, period)
            report.downloaded = true
            if !report.save
              puts "Couldn't mark report as downloaded for company #{company.name} (id: #{company.id}, symbol: #{company.symbol})"
            end
          end
        end
        begin
          ActiveRecord::Base.connection.reconnect!
        rescue
          ActiveRecord::Base.connection.reconnect!
        end
      end

      def download_all_financials(period = 'MRY')
        companies = Company.active
        total = companies.size
        puts "FOUND #{total} #{period} financial reports to download"
        Parallel.map(companies.sort.each_slice(100).with_index, in_processes: 5, progress: "Downloading #{period} financial statements") do |company_batch, i|
          company_batch.each_with_index do |company, j|
            next if company.skip_financials
            download(company, i, j, total, period)
          end
        end
        begin
          ActiveRecord::Base.connection.reconnect!
        rescue
          ActiveRecord::Base.connection.reconnect!
        end
      end

      def download(company, i, j, total, period)
          puts "(#{(i + 1)*(j + 1)}/#{total}) Downloading financial statements for '#{company.name}' (ID: #{company.id}, Symbol: #{company.symbol})."
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
