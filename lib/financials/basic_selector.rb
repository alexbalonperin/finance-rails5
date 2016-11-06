module Financials

  class BasicSelector < PotentialInvestmentSelector
    SELECTOR = 'basic'
    ROE_MIN = 12
    EPS_MIN = 15
    FREE_CASH_FLOW_MIN = 0
    CURRENT_RATIO_MIN = 1
    POSITIVE_GROWTH_PERCENTAGE = 0.7
    STEADY_GROWTH_N_YEARS = 10

    def initialize(companies = nil)
      @companies = companies || Company.active.where("first_trade_date < now() - interval '8 years'")
      @roe_min = ROE_MIN
      @eps_min = EPS_MIN
      @positive_growth_percentage = POSITIVE_GROWTH_PERCENTAGE
      @selector = SELECTOR
      @steady_growth_n_years = STEADY_GROWTH_N_YEARS
      @free_cash_flow_min = FREE_CASH_FLOW_MIN
      @current_ratio_min = CURRENT_RATIO_MIN
    end

    def single_criteria
      {
          'return_on_equity_5y_annual_rate_of_return' => lambda { |roe| roe_criteria(roe) },
          'return_on_equity_10y_annual_rate_of_return' => lambda { |roe| roe_criteria(roe) },
          'eps_basic_5y_annual_rate_of_return' => lambda { |eps| eps_criteria(eps) },
          'eps_basic_10y_annual_rate_of_return' => lambda { |eps| eps_criteria(eps) },
      }
    end

    def multi_criteria
      {
          'ROR_steady_growth' => lambda { |ki| steady_growth?(ki, 'return_on_equity_yoy_growth') },
          'EPS_steady_growth' => lambda { |ki| steady_growth?(ki, 'eps_basic_yoy_growth') },
          'EPS_positive' => lambda { |ki| constant_value?(ki, 'eps_basic') },
          'FCF_positive' => lambda { |ki| steady_growth?(ki, 'free_cash_flow') },
          'Current_ratio_positive' => lambda { |ki| constant_value?(ki, 'current_ratio', @current_ratio_min) }
      }
    end

    def select
      ActiveRecord::Base.transaction do
        PotentialInvestment.latest.update_all(:latest => false)
        ::Projection.latest.update_all(:latest => false)
        selected_ki = {}
        index = 1
        selected = @companies.select do |company|
          puts "(#{index}/#{@companies.size}) Evaluating #{company.name} (#{company.id})"
          kib = KeyIndicatorsBuilder.new(company)
          ki = kib.build
          select = meet_criteria?(ki)
          if select
            selected_ki[company.id] = ki
          end
          index += 1
          select
        end
        save(selected, selected_ki)
      end
    end

    def to_html
      s = ["Type: #{@selector}"]
      s << "Minimum ROE: #{@roe_min}%"
      s << "Minimum EPS: #{@eps_min}%"
      s << "Minimum positive growth: #{@positive_growth_percentage * 100}%"
      s << "Max period for steady growth: #{@steady_growth_n_years} years"
      s << "Total number of companies evaluated: #{@companies.size}"
      s << "Year over year minimum free cash flow: #{@free_cash_flow_min}"
      s << "Year over year minimum current ratio: #{@current_ratio_min}"
      s.join('<br>')
    end

  end

end
