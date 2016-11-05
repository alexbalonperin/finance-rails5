module Financials
  class Projection < Hash
    include Calculator::Compounding

    def initialize(ki)
      @ki = ki
    end

    def project(current_price)
      this_year = @ki.current_year
      min_per, max_per = [this_year['price_earnings_ratio_5y_avg'], this_year['price_earnings_ratio_10y_avg']].minmax
      self['projected_eps'] = projected_eps(this_year['eps_basic'], this_year['eps_basic_10y_annual_rate_of_return'], 5)
      self['projected_price_min'] = self['projected_eps'] * min_per
      self['projected_price_max'] = self['projected_eps'] * max_per
      self['projected_rate_of_return_min'] = annual_rate_of_return(current_price, self['projected_price_min'] * max_per, 5)
      self['projected_rate_of_return_max'] = annual_rate_of_return(current_price, self['projected_price_max'] * max_per, 5)
    end

    def projected_eps(eps_basic, eps_basic_annual_rate_of_return, n_years)
      future_val(eps_basic, eps_basic_annual_rate_of_return, n_years)
    end
  end

end

