module Financials

  class PotentialInvestmentSelector

    def roe_criteria(roe)
      roe.present? && roe * 100 > @roe_min
    end

    def eps_criteria(eps)
      eps.present? && eps * 100 > @eps_min
    end

    def single_criteria
      {
          'return_on_equity_5y_annual_compounding_RoR' => lambda { |roe| roe_criteria(roe) },
          'return_on_equity_10y_annual_compounding_RoR' => lambda { |roe| roe_criteria(roe) },
          'eps_basic_5y_annual_compounding_RoR' => lambda { |eps| eps_criteria(eps) },
          'eps_basic_10y_annual_compounding_RoR' => lambda { |eps| eps_criteria(eps) },
      }
    end

    def steady_growth?(ki, label)
      data = ki.data_in_period(label, Time.current.year - @steady_growth_n_years)
      positive = data.compact.select { |d| d >= 0 }
      positive.size >= (@positive_growth_percentage * data.size).floor
    end

    def constant_value?(ki, label, value = 0)
      data = ki.data_in_period(label, Time.current.year - @steady_growth_n_years)
      data.compact.all? { |d| d >= value }
    end

    def multi_criteria
      {
          'ROR_steady_growth' => lambda { |ki| steady_growth?(ki, 'return_on_equity_yoy_growth') },
          'EPS_steady_growth' => lambda { |ki| steady_growth?(ki, 'eps_basic_yoy_growth') },
          'FCF_positive' => lambda { |ki| constant_value?(ki, 'free_cash_flow') },
          'Current_ratio_positive' => lambda { |ki| constant_value?(ki, 'current_ratio', @current_ratio_min) }
      }
    end

    def meet_criteria?(ki)
      single = single_criteria.all? { |label, func| func.call(ki.per_year[(Time.current.year - 1).to_s][label]) }
      multi = multi_criteria.all? { |_, func| func.call(ki) }
      single && multi
    end

    def save(selected, selected_ki)
      selected.each do |company|
        ki = selected_ki[company.id]
        PotentialInvestment.create({
            :company_id => company.id,
            :selector => 'basic',
            :roe_5y_annual_compounding_ror => ki.all['ROE_5y_annual_compounding_RoR'],
            :roe_10y_annual_compounding_ror => ki.all['ROE_10y_annual_compounding_RoR'],
            :roe_steady_growth => steady_growth?(ki, 'return_on_equity_yoy_growth'),
            :eps_5y_annual_compounding_ror => ki.all['EPS_5y_annual_compounding_RoR'],
            :eps_10y_annual_compounding_ror => ki.all['EPS_10y_annual_compounding_RoR'],
            :eps_steady_growth => steady_growth?(ki, 'eps_basic_yoy_growth'),
            :current_price => company.latest_historical_data.adjusted_close,
            :fair_price_min => 0.0,
            :fair_price_max => 0.0,
            :n_past_financial_statements => ki.n_past_financial_statements,
            :year => Time.current.year
        })
      end
    end

  end

end
