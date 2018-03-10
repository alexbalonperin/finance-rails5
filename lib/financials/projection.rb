module Financials
  require 'ostruct'
  class Projection
    include Calculator::Compounding

    def self.project_for_potential_investments(year)
       pis = PotentialInvestment.latest
       pis.each do |pi|
         puts "Project returns for company #{pi.company.name} (id: #{pi.company.id})"
         pi.company.projections.update_all(:latest => false)
         ki = KeyIndicatorsBuilder.new(pi.company).build
         projection = Projection.new(ki, pi.company)
         projection.save_projection(year)
       end
    end

    def self.project_for_all_companies(year)
      companies = Company.active
      companies.each do |company|
         company.projections.update_all(:latest => false)
         ki = KeyIndicatorsBuilder.new(company).build
         projection = Projection.new(ki, company)
         projection.save_projection(year)
      end
    end

    def initialize(ki, company)
      @ki = ki
      @company = company
      @target_rate = 0.15
      @projection = OpenStruct.new
    end

    def to_s
      s = "Company: #{@company.name}\n"
      s << "   target rate: #{@target_rate}\n"
      s << "   projections:\n"
      s << "                    1y        5y        10y\n"
      s << "   projected eps: %.2f      %.2f      %.2f\n" % [@projection["projected_eps_1y"], @projection["projected_eps_5y"], @projection["projected_eps_10y"]]
      s
    end

    def project(year)
      company = @company
      income_statement = company.income_statements.at(year).first || company.income_statements.latest.first
      current_price = company.price_at(income_statement.report_date)
      year = income_statement.year
      this_year = @ki.per_year[year]
      min_per, max_per = [this_year['price_earnings_ratio_5y_avg'], this_year['price_earnings_ratio_10y_avg']].minmax
      worst_per, best_per = [this_year['price_earnings_ratio_10y_min'], this_year['price_earnings_ratio_10y_max']]

      @projection['eps_diluted_10y_annual_rate_of_return'] = this_year['eps_diluted_10y_annual_rate_of_return']

      [1, 5, 10].each do |period|
        @projection["projected_eps_#{period}y"] = future_val(this_year['eps_diluted'], this_year['eps_diluted_10y_annual_rate_of_return'], period)
        @projection["projected_price_worst_#{period}y"] = @projection["projected_eps_#{period}y"] * worst_per
        @projection["projected_price_min_#{period}y"] = @projection["projected_eps_#{period}y"] * min_per
        @projection["projected_price_max_#{period}y"] = @projection["projected_eps_#{period}y"] * max_per
        @projection["projected_price_best_#{period}y"] = @projection["projected_eps_#{period}y"] * best_per
        @projection["projected_rate_of_return_worst_#{period}y"] = annual_rate_of_return(current_price, @projection["projected_price_worst_#{period}y"], period)
        @projection["projected_rate_of_return_min_#{period}y"] = annual_rate_of_return(current_price, @projection["projected_price_min_#{period}y"], period)
        @projection["projected_rate_of_return_max_#{period}y"] = annual_rate_of_return(current_price, @projection["projected_price_max_#{period}y"], period)
        @projection["projected_rate_of_return_best_#{period}y"] = annual_rate_of_return(current_price, @projection["projected_price_best_#{period}y"], period)
        @projection["projected_value_#{period}y"] = present_val(@projection["projected_eps_#{period}y"], @target_rate, period) * this_year['price_earnings_ratio']
      end
      puts self.to_s
      @projection
    end

    def save_projection(year)
      company = @company
      #TODO: use price at date of the financial report
      projection = project(year)
      ::Projection.create({
         :company_id => company.id,
         :year => year,
         :actual_price => company.adjusted_close_end_of(year),
         :selector => @selector,
         :current_price => company.current_price,
         :projected_eps_1y => projection['projected_eps_1y'],
         :projected_price_worst_1y => projection['projected_price_worst_1y'],
         :projected_price_min_1y => projection['projected_price_min_1y'],
         :projected_price_max_1y => projection['projected_price_max_1y'],
         :projected_price_best_1y => projection['projected_price_best_1y'],
         :projected_rate_of_return_worst_1y => projection['projected_rate_of_return_worst_1y'],
         :projected_rate_of_return_min_1y => projection['projected_rate_of_return_min_1y'],
         :projected_rate_of_return_max_1y => projection['projected_rate_of_return_max_1y'],
         :projected_rate_of_return_best_1y => projection['projected_rate_of_return_best_1y'],
         :projected_value_1y => projection['projected_value_1y'],
         :projected_eps_5y => projection['projected_eps_5y'],
         :projected_price_worst_5y => projection['projected_price_worst_5y'],
         :projected_price_min_5y => projection['projected_price_min_5y'],
         :projected_price_max_5y => projection['projected_price_max_5y'],
         :projected_price_best_5y => projection['projected_price_best_5y'],
         :projected_rate_of_return_worst_5y => projection['projected_rate_of_return_worst_5y'],
         :projected_rate_of_return_min_5y => projection['projected_rate_of_return_min_5y'],
         :projected_rate_of_return_max_5y => projection['projected_rate_of_return_max_5y'],
         :projected_rate_of_return_best_5y => projection['projected_rate_of_return_best_5y'],
         :projected_value_5y => projection['projected_value_5y'],
         :projected_eps_10y => projection['projected_eps_10y'],
         :projected_price_worst_10y => projection['projected_price_worst_10y'],
         :projected_price_min_10y => projection['projected_price_min_10y'],
         :projected_price_max_10y => projection['projected_price_max_10y'],
         :projected_price_best_10y => projection['projected_price_best_10y'],
         :projected_rate_of_return_worst_10y => projection['projected_rate_of_return_worst_10y'],
         :projected_rate_of_return_min_10y => projection['projected_rate_of_return_min_10y'],
         :projected_rate_of_return_max_10y => projection['projected_rate_of_return_max_10y'],
         :projected_rate_of_return_best_10y => projection['projected_rate_of_return_best_10y'],
         :projected_value_10y => projection['projected_value_10y'],
      })
     end

  end

end
