module Financials


  class KeyIndicatorsBuilder

    KFI = {
        'debt_to_equity' => lambda { |calc| calc.debt_to_equity_ratio },
        'return_on_equity' => lambda { |calc| calc.return_on_equity_ratio },
        'eps_basic' => lambda { |calc| calc.eps_basic },
        'free_cash_flow' => lambda { |calc| calc.free_cash_flow },
        'current_ratio' => lambda { |calc| calc.current_ratio }
    }

    def initialize(company)
      @company = company

      @balance_sheets = company.balance_sheets.inject({}) { |h, bs| h[bs.year] = bs; h }
      @income_statements = company.income_statements.inject({}) { |h, bs| h[bs.year] = bs; h }
      @cash_flow_statements = company.cash_flow_statements.inject({}) { |h, bs| h[bs.year] = bs; h }
      @years = company.balance_sheets.map(&:year)
    end


    class KeyIndicator

      include Calculator::Growth
      include Calculator::Compounding

      attr_reader :per_year, :all

      def initialize(per_year = nil)
        @per_year = per_year || Hash.new { |h, k| h[k] = {} }
        @all = {}
      end

      def n_past_financial_statements
        @per_year.keys.size
      end

      def add(year, label, value)
        @per_year[year][label] = value
      end

      def per_year_in_asc_order
        @per_year.sort
      end

      def per_year_in_desc_order
        @per_year.sort.reverse
      end

      def add_all(label, value)
        @all[label] = value
      end

      def avg_growth(period, label)
        return 0.0 if period < 2
        avg(data_in_period(period, label))
      end

      def period_growth(period, label)
        return 0.0 if period < 2
        data = data_in_period(period, label)
        period(data)
      end

      def yoy_growth(period, label)
        return 0.0 if period < 2
        yoy = yoy(data_as_hash(period, label))
        yoy.each do |year, value|
          @per_year[year]["#{label}_yoy_growth"] = value
        end
      end

      def avg_yoy_growth(period, label)
        return 0.0 if period < 2
        avg_yoy(data_as_hash(period, label))
      end

      def yoy_annual_compounding_rate_of_return(period, label)
        return 0.0 if period < 2
        yoy_annual_rate_of_return(data_as_hash(period, label))
      end

      def annual_compounding_rate_of_return(period, label)
        return 0.0 if period < 2
        data = data_in_period(period, label)
        ror = annual_rate_of_return(data.last, data.first, data.size)
        ror
      end

      # INPUT:
      #    {
      #      '2015' => {
      #          :debt_to_equity => 1.23,
      #          :eps_basic => 2.23
      #      },
      #      '2014' => {
      #          :debt_to_equity => 1.33,
      #          :eps_basic => 2.33
      #      }
      #    }
      #
      # OUTPUT:
      #    ['2015', '2014']
      #
      #
      def years(in_period)
        in_period.map { |el| el.first }
      end

      # example:
      #    {
      #     '2015' => {
      #         :debt_to_equity => 1.23,
      #         :eps_basic => 2.23
      #     },
      #     '2014' => {
      #         :debt_to_equity => 1.33,
      #         :eps_basic => 2.33
      #     },
      #     '2013' => {
      #         :debt_to_equity => 1.43,
      #         :eps_basic => 2.43
      #     },
      #   }
      #   in_period(2)
      #    => {
      #         '2015' => {
      #             :debt_to_equity => 1.23,
      #             :eps_basic => 2.23
      #         },
      #         '2014' => {
      #             :debt_to_equity => 1.33,
      #             :eps_basic => 2.33
      #         }
      #       }
      #
      def in_period(period)
        sorted_by_year = @per_year.sort.reverse.to_h
        sorted_by_year.take(period)
      end

      # example:
      #   @per_year = {
      #     '2015' => {
      #         :debt_to_equity => 1.23,
      #         :eps_basic => 2.23
      #     },
      #     '2014' => {
      #         :debt_to_equity => 1.33,
      #         :eps_basic => 2.33
      #     },
      #     '2013' => {
      #         :debt_to_equity => 1.43,
      #         :eps_basic => 2.43
      #     },
      #   }
      #   data_in_period(2, :debt_to_equity)
      #    =>  [1.23, 1.33]
      #
      def data_in_period(period, label)
        in_period = in_period(period)
        in_period.map { |_, data| data[label] }
      end

      # example:
      #   @per_year = {
      #     '2015' => {
      #         :debt_to_equity => 1.23,
      #         :eps_basic => 2.23
      #     },
      #     '2014' => {
      #         :debt_to_equity => 1.33,
      #         :eps_basic => 2.33
      #     },
      #     '2013' => {
      #         :debt_to_equity => 1.43,
      #         :eps_basic => 2.43
      #     },
      #   }
      #   data_as_hash(2, :debt_to_equity)
      #    => {'2015' => 1.23, '2014' => 1.33}
      #
      def data_as_hash(period, label)
        years(in_period(period)).zip(data_in_period(period, label)).to_h
      end

      def to_s
        s = ''
        @per_year.each do |year, data|
          s << "YEAR: #{year}\n"
          data.each do |label, value|
            s << "------ #{label} => #{value}\n"
          end
        end
        s << "\nGROWTH\n"
        @all.each do |k, value|
          s << "------ #{k} => #{value}\n"
        end
        s
      end

    end

    def build
      res = @years.sort.reverse.inject(KeyIndicator.new) do |kfi, year|
        calc = KFICalculator.new(@balance_sheets[year], @income_statements[year], @cash_flow_statements[year], @balance_sheets[(year.to_i-1).to_s])
        KFI.each { |label, func| kfi.add(year, label, func.call(calc)) }
        kfi
      end
      res.add_all('EPS_5y_avg_growth', res.avg_growth(5, 'eps_basic'))
      res.add_all('EPS_10y_avg_growth', res.avg_growth(10, 'eps_basic'))
      res.add_all('EPS_5y_period_growth', res.period_growth(5, 'eps_basic'))
      res.add_all('EPS_10y_period_growth', res.period_growth(10, 'eps_basic'))
      res.add_all('EPS_5y_avg_yoy_growth', res.avg_yoy_growth(5, 'eps_basic'))
      res.add_all('EPS_10y_avg_yoy_growth', res.avg_yoy_growth(10, 'eps_basic'))
      res.add_all('EPS_5y_annual_compounding_RoR', res.annual_compounding_rate_of_return(5, 'eps_basic'))
      res.add_all('EPS_10y_annual_compounding_RoR', res.annual_compounding_rate_of_return(10, 'eps_basic'))
      res.add_all('ROE_5y_annual_compounding_RoR', res.annual_compounding_rate_of_return(5, 'return_on_equity'))
      res.add_all('ROE_10y_annual_compounding_RoR', res.annual_compounding_rate_of_return(10, 'return_on_equity'))
      res.yoy_growth(10, 'eps_basic')
      res.yoy_growth(10, 'debt_to_equity')
      res.yoy_growth(10, 'return_on_equity')
      res.yoy_growth(10, 'free_cash_flow')
      res.yoy_growth(10, 'current_ratio')
      res
    end

    class KFICalculator

      include Calculator::Ratio

      def initialize(balance_sheet, income_statement, cash_flow_statement, previous_balance_sheet)
        @bs = balance_sheet
        @is = income_statement
        @cfs = cash_flow_statement
        @pbs = previous_balance_sheet.nil? ? @bs : previous_balance_sheet
      end

      def debt_to_equity_ratio
        return BigDecimal(0) if @bs.nil?
        debt_to_equity(@bs.total_debt, @bs.shareholders_equity)
      end

      def return_on_equity_ratio
        return BigDecimal(0) if @bs.nil? || @is.nil?
        return BigDecimal(0) if @bs.shareholders_equity.nil? || @is.net_income.nil?
        return_on_equity(@is.net_income, (@bs.shareholders_equity + @pbs.shareholders_equity)/2)
      end

      def free_cash_flow
        @cfs.net_cash_flow_from_operations - @cfs.capital_expenditure
      end

      def current_ratio
        return BigDecimal(0) if @bs.nil?
        return BigDecimal(0) if @bs.current_liabilities.nil? || @bs.current_assets.nil?
        @bs.current_assets / @bs.current_liabilities
      end

      def eps_basic
        return BigDecimal(0) if @is.nil?
        @is.eps_basic
      end

    end

  end

end

