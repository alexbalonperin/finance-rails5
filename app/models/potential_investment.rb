class PotentialInvestment < ApplicationRecord

  belongs_to :company

  def self.latest(type = 'basic')
    PotentialInvestment.where('latest = true AND selector = ?', type)
  end

  def self.sorted_latest(type = 'basic')
    pis = PotentialInvestment.latest(type)
    pis.sort_by do |pi|
      [-pi.n_past_financial_statements, -pi.eps_5y_annual_compounding_ror, -pi.roe_5y_annual_compounding_ror]
    end
  end

  def good?
    return false if latest_projection.nil?
    latest_projection.projected_rate_of_return_min_1y > 15 && latest_projection.projected_rate_of_return_worst_1y > 0 &&
        latest_projection.current_price <= latest_projection.projected_value_1y
  end

  def bad?
    return true if latest_projection.nil?
    latest_projection.current_price > latest_projection.projected_value_1y
  end

  def not_so_good?
    return true if latest_projection.nil?
    latest_projection.projected_rate_of_return_worst_1y <= 0
  end

  def kfi
    company.latest_kfi.first
  end

  def projections
    @projections = [2015, 2016].map { |year| projection(year) }
  end

  def latest_projection
    projection(2016)
  end

  def projection(year)
    p = company.projections.where("latest = true AND year = ?", year.to_s).first || company.projections.where("latest = true").first
    puts company.id, p
    p
  end

  def price_earnings_ratio_10y_avg
    kfi.price_earnings_ratio_10y_avg
  end

  def price_earnings_ratio_5y_avg
    kfi.price_earnings_ratio_5y_avg
  end
  #
  # def roe_5y_annual_compounding_ror
  #   kfi.return_on_equity_5y_annual_rate_of_return
  # end
  #
  # def roe_10y_annual_compounding_ror
  #   kfi.return_on_equity_10y_annual_rate_of_return
  # end
  #
  # def eps_5y_annual_compounding_ror
  #   kfi.eps_basic_5y_annual_rate_of_return
  # end
  #
  # def eps_10y_annual_compounding_ror
  #   kfi.eps_basic_10y_annual_rate_of_return
  # end

  def eps_diluted
    kfi.eps_diluted
  end

  # def n_past_financial_statements
  #   kfi.n_past_financial_statements
  # end
end
