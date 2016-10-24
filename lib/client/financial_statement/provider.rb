module Client

  module FinancialStatement

    DOWNLOAD_DIR = 'public/financial_statements'

    class Provider
      require 'open-uri'
      require 'fileutils'

      def downloading_statement(url, symbol, type)
        file_path = "#{DOWNLOAD_DIR}/#{symbol}/#{type}/"
        FileUtils::mkdir_p file_path
        file_name = "#{Time.current.strftime('%Y%m%d%H%M%S')}.xlsx"
        file_path << file_name
        begin
          open(url) do |in_io|
            File.open(file_path, 'w+') do |out_io|
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

