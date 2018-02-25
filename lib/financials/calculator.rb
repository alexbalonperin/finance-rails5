module Financials

  module Calculator

    module Compounding
      FIXNUM_MAX = (2 ** (0.size * 8 -2) -1)
      FIXNUM_MIN = -(2 ** (0.size * 8 -2))

      def annual_rate_of_return(pv, fv, n_years)
        return 0.0 if pv.nil? || fv.nil?
        pv = pv <= 0 ? 10.0**-6 : pv
        fv = fv <= 0 ? 10.0**-6 : fv
        exponent = (BigDecimal(1) / BigDecimal(n_years))
        divisor = BigDecimal(fv / pv, 2)
        return BigDecimal(FIXNUM_MAX) if divisor.infinite?

        (divisor.power(exponent)) - BigDecimal(1)
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

      def yoy_annual_rate_of_return(years)
        sorted_years = years.sort
        first = sorted_years.first.last
        i = 1
        sorted_years.drop(1).inject({}) do |h, (year, data)|
          h[year.to_s] = annual_rate_of_return(first, data, i)
          i += 1
          h
        end
      end

    end

    module Ratio

      def debt_to_equity(total_liabilities, shareholders_equity)
        return 0.0 if total_liabilities.nil? || shareholders_equity.nil? || shareholders_equity.zero?
        total_liabilities / shareholders_equity
      end

      def return_on_equity(net_income, shareholders_equity)
        return 0.0 if net_income.nil? || shareholders_equity.nil? || shareholders_equity.zero?
        net_income / shareholders_equity
      end

      def return_on_assets(net_income, total_assets)
        return 0.0 if net_income.nil? || total_assets.nil? || total_assets.zero?
        net_income / total_assets
      end

      def net_margin(net_income, revenues)
        return 0.0 if net_income.nil? || revenues.nil? || revenues.zero?
        net_income / revenues
      end

    end

    module Growth

      def avg(arr)
        return 0.0 if arr.blank?
        arr = arr.compact
        return if arr.blank?
        arr.inject(:+) / arr.size
      end

      def min(arr)
        return 0.0 if arr.blank?
        arr = arr.compact
        return if arr.blank?
        arr.min
      end

      def max(arr)
        return 0.0 if arr.blank?
        arr = arr.compact
        return if arr.blank?
        arr.max
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
          h[year.to_s] = growth(cur, prev)
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
        cur = BigDecimal(current, 5)
        prev = BigDecimal(previous, 5)
        ((cur - prev) / prev) * (prev.sign / BigDecimal(2))
      end
    end

  end

end
