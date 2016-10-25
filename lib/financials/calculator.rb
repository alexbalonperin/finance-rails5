module Financials

  module Calculator

    module Compounding

      def annual_rate_of_return(pv, fv, n_years)
        Math.log(fv / pv) / n_years
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

      def debt_to_equity(total_liabilities, shareholders_equity)
        total_liabilities / shareholders_equity
      end


    end

    module Growth

      def avg(all, period, label)
        sorted_by_year = all.sort.reverse.to_h
        in_period = sorted_by_year.take(period)
        data = in_period.map { |_, data| data[label] }
        data.inject(:+) / period.to_f
      end

      def period(all, period, label)
        return 0.0 if period < 2
        in_period = all.sort.reverse.take(period)
        growth(in_period.first.last[label], in_period.last.last[label])
      end

      def yoy(all, period, label)
        return 0.0 if period < 2
        in_period = all.sort.reverse.take(period)
        data = in_period.to_h
        years, _ = in_period.transpose
        years[0..-2].inject({}) do |h, year|
          h[year] = period(data, 2, label)
          data = data.drop(1)
          h
        end
      end

      def avg_yoy(all, period, label)
        return 0.0 if period < 2
        yoy = yoy(all, period, label)
        yoy.values.inject(:+) / yoy.size
      end

      def growth(current, previous)
        return 0.0 if previous.zero?
        (current - previous) / previous.to_f
      end
    end

  end

end
