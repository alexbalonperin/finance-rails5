module Financials
  require 'ostruct'
  class Projection
    include Calculator::Compounding

    def initialize(ki)
      @ki = ki
      @target_rate = 0.15
      @projection = OpenStruct.new
    end

    def project(current_price)
      this_year = @ki.current_year
      min_per, max_per = [this_year['price_earnings_ratio_5y_avg'], this_year['price_earnings_ratio_10y_avg']].minmax
      worst_per, best_per = [this_year['price_earnings_ratio_10y_min'], this_year['price_earnings_ratio_10y_max']]
      @projection['eps_diluted_10y_annual_rate_of_return'] = this_year['eps_diluted_10y_annual_rate_of_return']

      [1, 5, 10].each do |period|
        @projection["projected_eps_#{period}y"] = future_val(this_year['eps_diluted'], this_year['eps_diluted_10y_annual_rate_of_return'], period)
        @projection["projected_price_#{period}y_worst"] = @projection["projected_eps_#{period}y"] * worst_per
        @projection["projected_price_#{period}y_min"] = @projection["projected_eps_#{period}y"] * min_per
        @projection["projected_price_#{period}y_max"] = @projection["projected_eps_#{period}y"] * max_per
        @projection["projected_price_#{period}y_best"] = @projection["projected_eps_#{period}y"] * best_per
        @projection["projected_rate_of_return_#{period}y_worst"] = annual_rate_of_return(current_price, @projection["projected_price_#{period}y_worst"], period)
        @projection["projected_rate_of_return_#{period}y_min"] = annual_rate_of_return(current_price, @projection["projected_price_#{period}y_min"], period)
        @projection["projected_rate_of_return_#{period}y_max"] = annual_rate_of_return(current_price, @projection["projected_price_#{period}y_max"], period)
        @projection["projected_rate_of_return_#{period}y_best"] = annual_rate_of_return(current_price, @projection["projected_price_#{period}y_best"], period)
        @projection["max_price_#{period}y"] = present_val(@projection["projected_eps_#{period}y"], @target_rate, period) * this_year['price_earnings_ratio']
      end
      @projection
    end

  end

end

