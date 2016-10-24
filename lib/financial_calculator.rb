class FinancialCalculator

  module Compounding
    def self.annual_rate_of_return(pv, fv, n_years)
      Math.log(fv / pv) / n_years
    end

    def self.future_val(pv, rate, n_years)
      pv * (1 + rate) ** n_years
    end

    def self.present_val(fv, rate, n_years)
      fv / (1 + rate) ** n_years
    end

    def self.n_years(pv, fv, rate)
      Math.log(fv / pv) / Math.log(1 + rate)
    end
  end

end