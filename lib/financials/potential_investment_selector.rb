module Financials

  class PotentialInvestmentSelector
    include Financials::Calculator::Compounding

    def selector_name
      @selector
    end

    def active_companies
      Company.where(:id =>
           Company.active
                  .select('companies.id')
                  .joins(:key_financial_indicators).where("first_trade_date < now() - interval '8 years'")
                  .group('companies.id, key_financial_indicators.year')
                  .having("key_financial_indicators.year::int = (extract(year from now()) - 1)"))
    end

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

    def select
      ActiveRecord::Base.transaction do
        @prev_records.update_all(:latest => false)
        @prev_projections.update_all(:latest => false)
        selected_ki = {}
        index = 1
        selected = @companies.select do |company|
          puts "(#{index}/#{@companies.size}) Evaluating #{company.name} (#{company.id})"
          kfi = company.latest_key_financial_indicators.map(&:attributes).inject({}) { |h, kfi| h[kfi['year']] = kfi; h }
          ki = ::Financials::KeyIndicatorsBuilder::KeyIndicator.new(kfi)
          ki ||= KeyIndicatorsBuilder.new(company).build
          select = meet_criteria?(ki)
          selected_ki[company.id] = ki if select
          index += 1
          select
        end
        save(selected, selected_ki)
      end
    end

    def steady_growth?(ki, label, value = 0)
      data = ki.data_in_period(label, Time.current.year - @steady_growth_n_years)
      positive = data.compact.select { |d| d >= value }
      positive.size >= (@positive_growth_percentage * data.size).floor
    end

    def constant_value?(ki, label, value = 0)
      data = ki.data_in_period(label, Time.current.year - @steady_growth_n_years)
      data.compact.all? { |d| d >= value }
    end

    def meet_criteria?(ki)
      return false if ki.per_year.blank?
      this_year = ki.per_year[Time.current.year.to_s] ||
                  ki.per_year[(Time.current.year - 1).to_s] ||
                  ki.per_year[(Time.current.year - 2).to_s]
      single = single_criteria.all? { |label, func| func.call(this_year[label]) }
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
         :selector => @selector,
         :current_price => current_price,
         :projected_eps => projection['projected_eps'],
         :projected_price_worst => projection['projected_price_worst'],
         :projected_price_min => projection['projected_price_min'],
         :projected_price_max => projection['projected_price_max'],
         :projected_price_best => projection['projected_price_best'],
         :projected_rate_of_return_worst => projection['projected_rate_of_return_worst'],
         :projected_rate_of_return_min => projection['projected_rate_of_return_min'],
         :projected_rate_of_return_max => projection['projected_rate_of_return_max'],
         :projected_rate_of_return_best => projection['projected_rate_of_return_best'],
         :max_price => projection['max_price']
      })

    end

    def save_potential_investment(company, ki)
      PotentialInvestment.create({
         :company_id => company.id,
         :selector => @selector,
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
