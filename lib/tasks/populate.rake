namespace :populate do

  def client
    @client ||= Client::HistoricalPrice::Yahoo.new
  end

  to_industry = lambda do |industry|
    sector = Sector.find_by_name(industry.sector)
    if sector.nil?
      puts "Couldn't find sector '#{industry.sector}. Please update the sector first"
      return
    end
    Industry.new(:sector_id => sector.id, :name => industry.name)
  end

  to_company = lambda do |company|
    markets = Market.where(['lower(name) = ?', company.market])
    if markets.blank? || markets.first.nil?
      puts "Couldn't find market '#{company.market}. Please update the market first"
      return
    end
    Company.new(:industry => Industry.find_by_name(company.industry),
                :name => company.name,
                :symbol => company.symbol,
                :market_id => markets.first.id,
                :ipo_year => company.ipo_year,
                :market_cap => Utils::NumberUtil.currency_to_number(company.market_cap))
  end

  to_sector = lambda do |sector|
     Sector.new(:name => sector.name)
   end

  class BulkUpdater
    def self.update(klass, records)
      records.each do |rec|
        if rec.save
          puts "#{klass} '#{rec.name}' saved to database"
        else
          puts "Couldn't save #{klass.to_s.downcase} '#{rec.name}'. Error: #{rec.errors.full_messages.join(',')}"
        end
      end
    end
  end

  task test: :environment do
    # companies = client.companies
    # puts companies.map(&:market_cap).inspect
  end

  desc 'set market to company'
  task markets: :environment do
    Market.select(:name).map(&:name).each do |name|
      companies_in_market = client.companies([name.downcase])
      puts "Number of companies on the #{name} market: #{companies_in_market.size}."
      companies = Company.where("market_id is null and symbol in ('#{companies_in_market.map{|c| c.symbol.strip }.join("', '")}')")
      puts "Found #{companies.size} companies to update."
      companies.update_all(:market_id => Market.find_by_name(name).id)
      puts "Done adding market to companies in #{name}."
    end
    puts 'DONE'
  end

  def populate_missing(klass, entities, &to_func)
    available_entities = klass.select(:name).map(&:name)
    missing_entities = entities.reject { |entity| available_entities.include?(entity.name) }
    missing_entities = missing_entities.map { |m| to_func.call(m) }.uniq(&:name)
    puts "Found #{missing_entities.size} new #{klass.to_s.downcase}."
    BulkUpdater.update(klass, missing_entities)
  end

  desc 'populate the database with a list of sectors from the web'
  task sectors: :environment do
    populate_missing(Sector, client.sectors, &to_sector)
  end

  desc 'populate the database with a list of industries from the web'
  task industries: :environment do
    populate_missing(Industry, client.industries, &to_industry)
  end

  desc 'populate the database with a list of companies from the web'
  task companies: :environment do
    populate_missing(Company, client.companies, &to_company)
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
          last_trade_date = last_historical_data.trade_date
          h[company.id] = {:last_trade_date => last_trade_date}
        end
        h
      end
      Company.update(updates.keys, updates.values)
      i += 1
    end
    puts 'Done.'
  end

  desc 'first trade date'
  task first_trade_date: :environment do
    companies = Company.where('first_trade_date is null and active and skip_historical_data is false')
    puts "Found #{companies.size} companies without first_trade_date"
    i = 0
    companies.each_slice(500) do |batch|
      puts "Batch : #{i}"
      updates = batch.inject({}) do |h, company|
        first_historical_data = company.first_historical_data
        if first_historical_data.present?
          first_trade_date = first_historical_data.trade_date
          h[company.id] = {:first_trade_date => first_trade_date}
        end
        h
      end
      Company.update(updates.keys, updates.values)
      i += 1
    end
    puts 'Done.'
  end

  desc 'financial indices + key indicators (DOW, S&P500, Silver, etc)'
  task indices: :environment do

  end

  desc 'download quarterly financial statements'
  task download_quarterly_financials: :environment do
    client = Client::FinancialStatement::StockRow.new
    client.download_financials('MRQ')
  end

  desc 'download yearly financial statements'
  task download_financials: :environment do
    client = Client::FinancialStatement::StockRow.new
    client.download_financials('MRY')
  end

  desc 'generate key financial indicators'
  task kfi: :environment do
    importer = Financials::KeyIndicatorsImporter.new
    importer.import
  end

  desc 'populate the database with all entities'
  task all: :environment do
    Rake::Task['populate:sectors'].invoke
    Rake::Task['populate:industries'].invoke
    Rake::Task['populate:companies'].invoke
    Rake::Task['populate:markets'].invoke
    Rake::Task['update:symbol_changes'].invoke
    Rake::Task['update:mergers'].invoke
    Rake::Task['update:cik_to_company_name'].invoke
    Rake::Task['update:latest_filings'].invoke
    Rake::Task['update:historical_data'].invoke
    Rake::Task['populate:deactivate'].invoke
    Rake::Task['populate:last_trade_date'].invoke
    Rake::Task['populate:first_trade_date'].invoke
    #Rake::Task['populate:download_financials'].invoke
    #Rake::Task['populate:download_quarterly_financials'].invoke
    # Rake::Task['update:potential_investments'].invoke
  end

end
