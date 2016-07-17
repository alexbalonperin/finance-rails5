require "#{Rails.root}/lib/client/yahoo"

namespace :populate do

  def client
    @client ||= Client::Yahoo.new
  end

  company_to_industry = lambda do |company|
    sector = Sector.find_by_name(company.sector)
    if sector.nil?
      puts "Couldn't find sector '#{company.sector}. Please update the sector first"
      return
    end
    Industry.new(:sector_id => sector.id, :name => company.industry)
  end

  class BulkUpdater
    def self.update(klass, records)
      records.each do |rec|
        if rec.save
          puts "#{klass} '#{rec.name}' saved to database"
        else
          puts "Couldn't save #{klass.downcase} '#{rec.name}''"
        end
      end
    end
  end

  desc 'populate the database with all entities'
  task all: :environment do
    Rake::Task['sectors'].invoke
    Rake::Task['industries'].invoke
    Rake::Task['companies'].invoke
  end

  desc 'set market to company'
  task markets: :environment do
    Market.select(:name).map(&:name).each do |name|
      nyse_companies = client.get_companies('us', name.downcase)
      puts "Number of companies on the #{name} market: #{nyse_companies.size}."
      companies = Company.where("market_id is null and symbol in ('#{nyse_companies.map{|c| c.symbol.strip }.join("', '")}')")
      puts "Found #{companies.size} companies to update."
      companies.update_all(:market_id => Market.find_by_name(name).id)
      puts "Done adding market to companies in #{name}."
    end
    puts 'DONE'
  end

  desc 'populate the database with a list of sectors from the web'
  task sectors: :environment do
    sectors = Sector.select(:name)
    missing_companies = client.all_companies.reject { |company| sectors.include?(company.sector) }
    missing_sectors = missing_companies.map { |company| Sector.new(:name => company.sector) }.uniq(&:name)
    BulkUpdater.update(Sector, missing_sectors)
  end

  desc 'populate the database with a list of industries from the web'
  task industries: :environment do
    industries = Industry.select(:name)
    missing_companies = client.all_companies.reject { |company| industries.include?(company.industry) }
    missing_industries = missing_companies.map(&company_to_industry).uniq(&:name)
    BulkUpdater.update(Industry, missing_industries)
  end


  desc 'populate the database with a list of companies from the web'
  task companies: :environment do
    Market.all.each do |market|
      company_to_company = lambda do |company|
        Company.new(:industry => Industry.find_by_name(company.industry),
                    :name => company.name,
                    :symbol => company.symbol,
                    :market_id => market.id)
      end
      cur_companies = Company.where("market_id = #{market.id}").select(:name).map(&:name)
      companies = client.companies(market.country_code, market.name)
      missing_companies = companies.reject { |company| cur_companies.include?(company.name) }
      missing_companies = missing_companies.map(&company_to_company).uniq(&:name)
      next unless missing_companies.size > 0
      puts "Found #{missing_companies.size} companies to add to market #{market.name}."
      BulkUpdater.update(Company, missing_companies)
    end
  end

  desc 'mark companies as inactive'
  task deactivate: :environment do
    companies = Company.where('active = true')
    to_deactivate = companies.select { |c| c.liquidated || c.delisted || c.became.present? || c.merged? }
    puts "Found #{to_deactivate.size} companies to deactivate"
    to_deactivate = Company.find(to_deactivate.map(&:id))
    to_deactivate.each { |c| c.update(:active => false) }
    puts 'Done deactivating companies'
  end

  desc 'last trade date'
  task last_trade_date: :environment do
    companies = Company.where('last_trade_date is null and active and skip_historical_data is false')
    puts "Found #{companies.size} companies without last_trade_date"
    i = 0
    companies.each_slice(500) do |batch|
      puts "Batch : #{i}"
      updates = batch.inject({}) do |h, company|
        last_historical_data = company.latest_historical_data
        if last_historical_data.present?
          last_trade_date = last_historical_data.first.trade_date
          h[company.id] = {:last_trade_date => last_trade_date}
        end
        h
      end
      puts updates
      Company.update(updates.keys, updates.values)
      i += 1
    end
    puts 'Done.'
  end
end
