require 'open-uri'
require 'nokogiri'

module Client
  class Bloomberg
      BASE_URL = "https://www.bloomberg.com/quote"
      COUNTRY = "US"
      Tor.configure do |config|
         config.port = 9050
      end

      def self.check_all
        companies = Company.active
        total = companies.size
        companies.map(&:symbol).each_with_index do |symbol, i|
          puts "--------------------------------------------------"
          puts "(#{i}/#{total}) symbol: #{symbol}"
          market_status(symbol)
          puts "--------------------------------------------------"
          sleep(15)
        end
      end

      def self.market_status(symbol)
        url = "#{BASE_URL}/#{URI.escape(symbol)}:#{COUNTRY}"
        result = Tor::HTTP.get(URI(url))
        doc = Nokogiri::HTML(result.body)
        market_status = doc.search(".market-status")[0]
        message = doc.search(".market-status-message")[0]
        puts "MARKET STATUS"
        puts market_status
        puts message
        if market_status.nil? || message.nil?
          update_symbol(symbol) if symbol.include?("$")
          return
        end
        status = market_status.text.strip.downcase
        puts status
        if status == "acquired"
          acquisition(message, symbol)
        elsif status == "liquidated"
          liquidation(symbol)
        elsif status == "ticker delisted" || status == "unlisted"
          delisting(symbol)
        elsif status == "ticker change" || status == "pending listing"
          puts status
        else
          puts "Symbol #{symbol} is live"
        end
      rescue => e
        puts "ERROR: #{e}"
        puts e.backtrace
      end

      def self.update_symbol(symbol)
          company = Company.find_by_symbol(symbol)
          company.symbol = company.symbol.gsub('$', '')
          if !company.save
            puts "Couldn't update symbol for company #{company.name} (id: #{company.id}, symbol: #{symbol})"
          else
            puts "Company #{company.name} symbol was changed from #{symbol} to #{company.symbol}"
          end
      end

      def self.delisting(delisted_symbol)
          delisted_company = Company.find_by_symbol(delisted_symbol)
          delisted_company.active = false
          delisted_company.delisted = true
          if !delisted_company.save
            puts "Couldn't delisted company #{delisted_company.name} (id: #{delisted_company.id}, symbol: #{delisted_company.symbol})"
          else
            puts "Company #{delisted_company.name} delisted"
          end
      end

      def self.liquidation(liquidated_symbol)
          liquidated_company = Company.find_by_symbol(liquidated_symbol)
          liquidated_company.active = false
          liquidated_company.liquidated = true
          if !liquidated_company.save
            puts "Couldn't liquidated company #{liquidated_company.name} (id: #{liquidated_company.id}, symbol: #{liquidated_company.symbol})"
          else
            puts "Company #{liquidated_company.name} liquidated"
          end
      end

      def self.acquisition(message, acquired_symbol)
          acquired_company = Company.find_by_symbol(acquired_symbol)
          acquired_company.active = false
          if !acquired_company.save
            puts "Couldn't deactivate company #{acquired_company.name} (id: #{acquired_company.id}, symbol: #{acquired_company.symbol})"
          else
            puts "Company #{acquired_company.name} deactivated"
          end
          link = message.search(".market-status-message_link")[0]
          return if link.nil? 
          acquiring_symbol = link.text.split(":")[0]
          acquiring_company = Company.find_by_symbol(acquiring_symbol)
          if acquiring_company.present?
            merger = Merger.new(acquired_id: acquired_company.id, acquiring_id: acquiring_company.id)
            if !merger.save
              puts "Couldn't save merger between company #{acquiring_company.name} (id: #{acquiring_company.id}, symbol: #{acquiring_company.symbol}) and company #{acquired_company.name} (id: #{acquired_company.id}, symbol: #{acquired_company.symbol})"
            else
              puts "Merger saved"
            end
          else
            puts "Couldn't find acquiring company #{link.text}"
          end
      end

  end
end
