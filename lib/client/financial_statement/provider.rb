module Client

  module FinancialStatement

    DOWNLOAD_DIR = 'data/financial_statements'

    class Provider
      require 'open-uri'
      require 'fileutils'

      def initialize(companies = nil)
        @companies = companies || Company.active
        FileUtils::mkdir_p DOWNLOAD_DIR
      end

      def downloading_statement(url, period, symbol, type)
        period_folder = if period == 'MRQ'
          'quarterly'
        elsif period == 'MRY'
          'yearly'
        end
        file_path = "#{DOWNLOAD_DIR}/#{period_folder}/#{symbol}/#{type}/"
        file_name = "#{Time.current.strftime('%Y%m%d%H%M%S')}.xlsx"
        full_path = "#{file_path}#{file_name}"
        begin
          open(url) do |in_io|
            FileUtils::mkdir_p file_path
            File.open(full_path, 'w+') do |out_io|
              out_io.print in_io.read
            end
          end
        rescue => e
          puts "Couldn't fetch the #{type} statement. Error: #{e}"
        end
      end

      def downloaded_symbols
        Utils::FileUtil.folder_names(DOWNLOAD_DIR)
      end

    end

  end

end
