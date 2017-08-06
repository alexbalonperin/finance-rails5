class Company < ApplicationRecord
  belongs_to :industry
  has_one :sector, :through => :industry
  has_many :historical_data
  has_many :subsidiaries_mergers, :class_name => 'Merger', :foreign_key => :acquiring_id
  has_many :income_statements do
    def latest
      self.order('year desc').limit(1)
    end

    def oldest
      self.order('year asc').limit(1)
    end
  end
  has_many :balance_sheets do
    def latest
      self.order('year desc').limit(1)
    end

    def oldest
      self.order('year asc').limit(1)
    end
  end
  has_many :cash_flow_statements do
    def latest
      self.order('year desc').limit(1)
    end

    def oldest
      self.order('year asc').limit(1)
    end
  end
  has_many :key_financial_indicators do
    def latest
      self.where(:latest => true).order('year desc').limit(1)
    end
  end
  has_many :projections do
    def latest(type = 'basic')
      self.where(:latest => true, :selector => type)
    end
  end
  has_one :parent_merger, :class_name => 'Merger', :foreign_key => :acquired_id
  has_one :parent, :through => :parent_merger, :source => :acquiring
  has_many :subsidiaries, :through => :subsidiaries_mergers, :source => :acquired
  has_one :companies_changes_from, :class_name => 'CompaniesChange', :foreign_key => :from_id
  has_one :became, :through => :companies_changes_from, :source => :to
  has_one :companies_changes_to, :class_name => 'CompaniesChange', :foreign_key => :to_id
  has_one :was, :through => :companies_changes_to, :source => :from

  validates :name, :symbol, presence: true

  def latest_kfi
    key_financial_indicators.latest
  end

  def latest_key_financial_indicators
    key_financial_indicators.where(:latest => true)
  end

  def first_year_with_fully_available_statements
    oldest_income_statement =  income_statements.oldest.first
    oldest_balance_sheet = balance_sheets.oldest.first
    oldest_cash_flow_statement = cash_flow_statements.oldest.first
    return if oldest_balance_sheet.nil? || oldest_cash_flow_statement.nil? || oldest_income_statement.nil?
    [oldest_cash_flow_statement.year, oldest_income_statement.year, oldest_balance_sheet.year].map(&:to_i).max
  end

  def self.active
    Company.where(:active => true)
  end

  def industry_name
    industry.name
  end

  def sector_name
    sector.name
  end

  def sector_id
    sector.id
  end

  def current_price
    latest_historical_data.adjusted_close
  end

  def price_at(date)
    # d = Date.parse(date)
    d = date
    price = nil
    loop do
      hd = historical_data.where("trade_date = date('#{d}')").first
      if hd.present?
        price = hd.adjusted_close
        break
      else
        d -= 1.day
      end
    end
    price
  end

  def adjusted_close_beginning_of(year)
    hd = historical_data_for(year)
    hd_first = hd.sort_by(&:trade_date).first
    return if hd_first.nil?
    hd_first.adjusted_close
  end

  def adjusted_close_end_of(year)
    hd = historical_data_for(year)
    hd_last = hd.sort_by(&:trade_date).last
    return if hd_last.nil?
    hd_last.adjusted_close
  end

  def historical_data_for(year)
    historical_data.where("extract(year from trade_date) = #{year}")
  end

  def latest_historical_data
    hist_data = historical_data.order('trade_date desc').limit(1)
    hist_data.first if hist_data.present?
  end

  def first_historical_data
    hist_data = historical_data.order('trade_date asc').limit(1)
    hist_data.first if hist_data.present?
  end

  def growth(lower_bound = 1.week.ago, upper_bound = Time.now)
    lower, upper = historical_data.where(['trade_date = ? or trade_date = ?', lower_bound.to_date.beginning_of_week, upper_bound.to_date.end_of_week + 1.day])
    lower ||= historical_data.joins(:company).where('trade_date = companies.first_trade_date').first
    upper ||= historical_data.joins(:company).where('trade_date = companies.last_trade_date').first
    return 0 if lower.nil? || upper.nil?
    ((upper.adjusted_close - lower.adjusted_close) / upper.adjusted_close) * 100
  end

  def to_json
    {
        :id => id,
        :symbol => symbol,
        :name => name,
        :industry => industry.name,
        :sector => sector.name,
        :industry_id => industry_id,
        :sector_id => sector.id,
        :delisted => delisted,
        :inactive => !active,
        :liquidated => liquidated,
        :merged => merged?,
        :changed => became.present?,
        :details => details
    }
  end

  def merged?
    parent.present?
  end

  def details
    merger_msg.to_s + changes_msg.to_s + liquidated_msg.to_s + delisted_msg.to_s
  end

  def merger_msg
    msg = ''
    if parent.present?
      msg << "acquired by #{parent.name}"
    end
    if subsidiaries.present?
      msg << "subsidiaries: #{subsidiaries.map(&:name).join(', ')}"
    end
    msg
  end

  def changes_msg
    "became #{became.name}" if became.present?
  end

  def liquidated_msg
    'liquidated' if liquidated
  end

  def delisted_msg
    'delisted' if delisted
  end

end
