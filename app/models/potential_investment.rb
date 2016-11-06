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
    projected_rate_of_return_min > 15 && projected_rate_of_return_worst > 0 &&
        current_price <= max_price
  end

  def bad?
    current_price > max_price
  end

  def not_so_good?
    projected_rate_of_return_worst <= 0
  end

  def kfi
    company.latest_kfi.first
  end

  def projection(type = 'basic')
    @projection ||= company.projections.latest(type).first
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

  def eps_basic
    kfi.eps_basic
  end

  # def n_past_financial_statements
  #   kfi.n_past_financial_statements
  # end

  def current_price
    @projection.current_price
  end

  def max_price
    @projection.max_price
  end

  def projected_eps
    @projection.projected_eps
  end

  def projected_price_worst
    @projection.projected_price_worst
  end

  def projected_price_min
    @projection.projected_price_min
  end

  def projected_price_max
    @projection.projected_price_max
  end

  def projected_price_best
    @projection.projected_price_best
  end

  def projected_rate_of_return_worst
    @projection.projected_rate_of_return_worst * 100
  end

  def projected_rate_of_return_min
    @projection.projected_rate_of_return_min * 100
  end

  def projected_rate_of_return_max
    @projection.projected_rate_of_return_max * 100
  end

  def projected_rate_of_return_best
    @projection.projected_rate_of_return_best * 100
  end
end
