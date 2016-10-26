module Financials

  module Calculator

    module Compounding

      def annual_rate_of_return(pv, fv, n_years)
        (fv / pv) ** (1 / n_years.to_f) - 1
      end

      def future_val(pv, rate, n_years)
        pv * (1 + rate) ** n_years
      end

      def present_val(fv, rate, n_years)
        fv / (1 + rate) ** n_years
      end

      def n_years(pv, fv, rate)
        Math.log(fv / pv) / Math.log(1 + rate)
      end

    end

    module Ratio

      def debt_to_equity(total_debt, shareholders_equity)
        return 0.0 if total_debt.nil? || shareholders_equity.nil?
        total_debt / shareholders_equity
      end

      def return_on_equity(net_income, shareholders_equity)
        return 0.0 if net_income.nil? || shareholders_equity.nil?
        net_income / shareholders_equity
      end

    end

    module Growth

      def avg(arr)
        return 0.0 if arr.blank?
        arr.inject(:+) / arr.size
      end

      # assuming arr is sorted from newest to oldest
      def period(arr)
        growth(arr.first, arr.last)
      end

      def yoy(years)
        prev = nil
        h = {}
        years.sort.each do |year, data|
          cur = data
          if prev.nil?
            prev = cur
            next
          end
          h[year] = period([cur, prev])
          prev = cur
        end
        h
      end

      def avg_yoy(years)
        yoy = yoy(years)
        avg(yoy.values)
      end

      def growth(current, previous)
        return 0.0 if previous.nil? || previous.zero?
        (current - previous) / previous.to_f
      end
    end

  end

end