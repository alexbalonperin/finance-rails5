module Financials

  class PromisingCompaniesSelector < PotentialInvestmentSelector
    SELECTOR = 'promising'
    ROE_MIN = 5
    EPS_MIN = 5
    FREE_CASH_FLOW_MIN = 0
    CURRENT_RATIO_MIN = 1
    POSITIVE_GROWTH_PERCENTAGE = 0.8
    STEADY_GROWTH_N_YEARS = 10

    def initialize(companies = nil)
      @companies = companies || active_companies
      @roe_min = ROE_MIN
      @eps_min = EPS_MIN
      @positive_growth_percentage = POSITIVE_GROWTH_PERCENTAGE
      @selector = SELECTOR
      @steady_growth_n_years = STEADY_GROWTH_N_YEARS
      @free_cash_flow_min = FREE_CASH_FLOW_MIN
      @current_ratio_min = CURRENT_RATIO_MIN
      @prev_records = PotentialInvestment.latest(@selector)
      @prev_projections = ::Projection.latest(@selector)
    end

    def single_criteria
      {
          'return_on_equity_5y_annual_rate_of_return' => lambda { |roe| roe_criteria(roe) },
          'return_on_equity_10y_annual_rate_of_return' => lambda { |roe| roe_criteria(roe) },
          'eps_diluted_5y_annual_rate_of_return' => lambda { |eps| eps_criteria(eps) },
          'eps_diluted_10y_annual_rate_of_return' => lambda { |eps| eps_criteria(eps) },
      }
    end

    def multi_criteria
      {
          'ROR_steady_growth' => lambda { |ki| steady_growth?(ki, 'return_on_equity_yoy_growth') },
          'EPS_steady_growth' => lambda { |ki| steady_growth?(ki, 'eps_diluted_yoy_growth') },
          'EPS_positive' => lambda { |ki| steady_growth?(ki, 'eps_diluted') },
          'FCF_positive' => lambda { |ki| steady_growth?(ki, 'free_cash_flow') },
          'Current_ratio_positive' => lambda { |ki| steady_growth?(ki, 'current_ratio', @current_ratio_min) }
      }
    end

  end

end
