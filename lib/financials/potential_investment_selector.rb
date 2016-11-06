module Financials

  class PotentialInvestmentSelector
    include Financials::Calculator::Compounding

    def roe_criteria(roe)
      roe.present? && roe * 100 > @roe_min
    end

    def eps_criteria(eps)
      eps.present? && eps * 100 > @eps_min
    end

    def single_criteria
      raise 'Should be implemented by subclass'
    end

    def multi_criteria
      raise 'Should be implemented by subclass'
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

    def meet_criteria?(ki)
      single = single_criteria.all? { |label, func| func.call(ki.per_year[(Time.current.year - 1).to_s][label]) }
      multi = multi_criteria.all? { |_, func| func.call(ki) }
      single && multi
    end

    def save(selected, selected_ki)
      selected.each do |company|
        ki = selected_ki[company.id]
        save_potential_investment(company, ki)
        save_projection(company, ki)
      end
    end

    def save_projection(company, ki)
      current_price = company.latest_historical_data.adjusted_close
      projection = Financials::Projection.new(ki)
      projection.project(current_price)
      ::Projection.create({
         :company_id => company.id,
         :current_price => current_price,
         :projected_eps => projection['projected_eps'],
         :projected_price_worst => projection['projected_price_worst'],
         :projected_price_min => projection['projected_price_min'],
         :projected_price_max => projection['projected_price_max'],
         :projected_price_best => projection['projected_price_best'],
         :projected_rate_of_return_worst => projection['projected_rate_of_return_worst'],
         :projected_rate_of_return_min => projection['projected_rate_of_return_min'],
         :projected_rate_of_return_max => projection['projected_rate_of_return_max'],
         :projected_rate_of_return_best => projection['projected_rate_of_return_best']
      })

    end

    def save_potential_investment(company, ki)
      PotentialInvestment.create({
         :company_id => company.id,
         :selector => 'basic',
         :roe_5y_annual_compounding_ror => ki.current_year['return_on_equity_5y_annual_rate_of_return'],
         :roe_10y_annual_compounding_ror => ki.current_year['return_on_equity_10y_annual_rate_of_return'],
         :roe_steady_growth => steady_growth?(ki, 'return_on_equity_yoy_growth'),
         :eps_5y_annual_compounding_ror => ki.current_year['eps_basic_5y_annual_rate_of_return'],
         :eps_10y_annual_compounding_ror => ki.current_year['eps_basic_10y_annual_rate_of_return'],
         :eps_steady_growth => steady_growth?(ki, 'eps_basic_yoy_growth'),
         :n_past_financial_statements => ki.n_past_financial_statements,
         :year => Time.current.year
      })
    end

  end

end
