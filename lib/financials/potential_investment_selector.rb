module Financials

  class PotentialInvestmentSelector
    include Financials::Calculator::Compounding

    def selector_name
      @selector
    end

    def active_companies
      Company.active.where("first_trade_date < now() - interval '8 years'")
    end

    def roe_criteria(roe)
      roe.present? && roe * 100 > @roe_min
    end

    def eps_criteria(eps)
      eps.present? && eps * 100 > @eps_min
    end

    def current_ratio_criteria(ki)
      constant_value?(ki, 'current_ratio', @current_ratio_min)
    end

    def free_cash_flow_growth_criteria(ki)
      steady_growth?(ki, 'free_cash_flow')
    end

    def roe_growth_criteria(ki)
      steady_growth?(ki, 'return_on_equity_yoy_growth')
    end

    def eps_growth_criteria(ki)
      steady_growth?(ki, 'eps_diluted_yoy_growth')
    end

    def eps_min_criteria(ki)
      constant_value?(ki, 'eps_diluted')
    end

    def single_year_criteria
      raise 'Should be implemented by subclass'
    end

    def multi_year_criteria
      raise 'Should be implemented by subclass'
    end

    def steady_growth?(ki, label, value = 0)
      data = ki.data_in_period(label, Time.current.year - @steady_growth_n_years)
      positive = data.compact.select { |d| d >= value }
      positive.size >= (@positive_growth_percentage * data.size).floor
    end

    def constant_value?(ki, label, value = 0)
      data = ki.data_in_period(label, Time.current.year - @steady_growth_n_years)
      positive = data.compact.select { |d| d >= value }
      positive.size >= (@positive_constant_value_percentage * data.size).floor
    end

    def meet_criteria?(ki)
      return false if ki.per_year.blank?
      per_year = ki.per_year.compact
      current_year = Time.current.year
      this_year = per_year[current_year.to_s] ||
                  per_year[(current_year - 1).to_s] ||
                  per_year[(current_year - 2).to_s]
      return false if this_year.nil?
      total_criteria = single_year_criteria.size + multi_year_criteria.size
      single = single_year_criteria.select { |label, func|
        result = func.call(this_year[label])
        puts "-------- Result for #{label}: #{result}"
        result
      }
      multi = multi_year_criteria.select { |label, func|
        result = func.call(ki)
        puts "-------- Result for #{label}: #{result}"
        result
      }
      (single.size + multi.size) >= (@positive_criteria_percentage * total_criteria).floor
    end

    def select
      ActiveRecord::Base.transaction do
        @prev_records.update_all(:latest => false)
        @companies.each_with_index do |company, index|
          puts "(#{index}/#{@companies.size}) Evaluating #{company.name} (#{company.id})"
          ki = KeyIndicatorsBuilder.new(company).build
          if meet_criteria?(ki)
            puts "Selected company #{company.name} (id: #{company.id}, symbol: #{company.symbol})"
            save_potential_investment(company, ki)
          end
        end
      end
    end

    def save_potential_investment(company, ki)
      PotentialInvestment.create({
         :company_id => company.id,
         :selector => @selector,
         :roe_5y_annual_compounding_ror => ki.current_year['return_on_equity_5y_annual_rate_of_return'],
         :roe_10y_annual_compounding_ror => ki.current_year['return_on_equity_10y_annual_rate_of_return'],
         :roe_steady_growth => steady_growth?(ki, 'return_on_equity_yoy_growth'),
         :eps_5y_annual_compounding_ror => ki.current_year['eps_diluted_5y_annual_rate_of_return'],
         :eps_10y_annual_compounding_ror => ki.current_year['eps_diluted_10y_annual_rate_of_return'],
         :eps_steady_growth => steady_growth?(ki, 'eps_diluted_yoy_growth'),
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
