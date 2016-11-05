module Financials


  class KeyIndicatorsBuilder

    KFI = {
        'debt_to_equity' => lambda { |calc| calc.debt_to_equity_ratio },
        'return_on_equity' => lambda { |calc| calc.return_on_equity_ratio },
        'return_on_assets' => lambda { |calc| calc.return_on_assets_ratio },
        'eps_basic' => lambda { |calc| calc.eps_basic },
        'free_cash_flow' => lambda { |calc| calc.free_cash_flow },
        'current_ratio' => lambda { |calc| calc.current_ratio },
        'net_margin' => lambda { |calc| calc.net_margin_ratio }
    }

    def initialize(company)
      @company = company

      @balance_sheets = company.balance_sheets.inject({}) { |h, bs| h[bs.year] = bs; h }
      @income_statements = company.income_statements.inject({}) { |h, bs| h[bs.year] = bs; h }
      @cash_flow_statements = company.cash_flow_statements.inject({}) { |h, bs| h[bs.year] = bs; h }
      @years = company.balance_sheets.map(&:year)
    end

    def build
      years = @years.sort.reverse
      res = years.inject(KeyIndicator.new) do |kfi, year|
        calc = KFICalculator.new(@balance_sheets[year], @income_statements[year], @cash_flow_statements[year], @balance_sheets[(year.to_i-1).to_s])
        KFI.each { |label, func| kfi.add(year, label, func.call(calc)) }
        kfi
      end
      years.each do |year|
        KFI.each do |label, _|
          res.add(year, "#{label}_5y_annual_rate_of_return", res.annual_compounding_rate_of_return(label, year.to_i - 5, year.to_i))
          res.add(year, "#{label}_10y_annual_rate_of_return", res.annual_compounding_rate_of_return(label, year.to_i - 10, year.to_i))
          res.add(year, "#{label}_5y_avg", res.avg_value(label, year.to_i - 5, year.to_i))
          res.add(year, "#{label}_10y_avg", res.avg_value(label, year.to_i - 10, year.to_i))
          res.yoy_growth(label, year.to_i - 10, year.to_i)
        end
      end
      res
    end

    class KeyIndicator

      include Calculator::Growth
      include Calculator::Compounding

      attr_reader :per_year

      def initialize(per_year = nil)
        @per_year = per_year || Hash.new { |h, k| h[k] = {} }
      end

      def n_past_financial_statements
        @per_year.keys.size
      end

      def all_years(period_start, period_end = Time.current.year)
        @per_year.keys.delete_if {|year| year.to_i > period_end || year.to_i < period_start }
      end

      def add(year, label, value)
        @per_year[year.to_s][label] = value
      end

      def per_year_in_asc_order
        @per_year.sort
      end

      def per_year_in_desc_order
        @per_year.sort.reverse
      end

      def avg_value(label, period_start, period_end = Time.current.year)
        avg(data_in_period(label, period_start, period_end))
      end

      def period_growth(label, period_start, period_end = Time.current.year)
        data = data_in_period(label, period_start, period_end)
        period(data)
      end

      def yoy_growth(label, period_start, period_end = Time.current.year)
        yoy = yoy(data_as_hash(label, period_start, period_end))
        yoy.each do |year, value|
          @per_year[year.to_s]["#{label}_yoy_growth"] = value
        end
      end

      def avg_yoy_growth(label, period_start, period_end = Time.current.year)
        avg_yoy(data_as_hash(label, period_start, period_end))
      end

      def yoy_annual_compounding_rate_of_return(label, period_start, period_end = Time.current.year)
        yoy_annual_rate_of_return(data_as_hash(label, period_start, period_end))
      end

      def annual_compounding_rate_of_return(label, period_start, period_end = Time.current.year)
        data = data_in_period(label, period_start, period_end)
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
      #   in_period(2014)
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
      def in_period(period_start, period_end = Time.current.year)
        sorted_by_year = @per_year.sort.reverse.to_h
        sorted_by_year.delete_if {|year, _| year.to_i > period_end || year.to_i < period_start }
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
      def data_in_period(label, period_start, period_end = Time.current.year)
        in_period = in_period(period_start, period_end)
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
      #   data_as_hash(2014, :debt_to_equity)
      #    => {'2015' => 1.23, '2014' => 1.33}
      #
      def data_as_hash(label, period_start, period_end = Time.current.year)
        years(in_period(period_start, period_end)).zip(data_in_period(label, period_start, period_end)).to_h
      end

      def to_s
        s = ''
        @per_year.each do |year, data|
          s << "YEAR: #{year}\n"
          data.each do |label, value|
            s << "------ #{label} => #{value}\n"
          end
        end
        s
      end

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
        return BigDecimal(0) if @bs.total_liabilities.nil? || @bs.shareholders_equity.nil?
        return BigDecimal(0) if @bs.shareholders_equity.zero?
        debt_to_equity(@bs.total_liabilities, @bs.shareholders_equity)
      end

      def return_on_equity_ratio
        return BigDecimal(0) if @bs.nil? || @is.nil?
        return BigDecimal(0) if @bs.shareholders_equity.nil? || @is.net_income.nil?
        return_on_equity(@is.net_income, (@bs.shareholders_equity + @pbs.shareholders_equity)/2)
      end

      def return_on_assets_ratio
        return BigDecimal(0) if @bs.nil? || @is.nil?
        return BigDecimal(0) if @bs.shareholders_equity.nil? || @is.net_income.nil?
        return_on_assets(@is.net_income, (@bs.total_assets + @pbs.total_assets)/2)
      end

      def net_margin_ratio
        return BigDecimal(0) if @is.nil?
        return BigDecimal(0) if @is.net_income.nil? || @is.revenues.nil?
        net_margin(@is.net_income, @is.revenues)
      end

      def free_cash_flow
        return BigDecimal(0) if @cfs.nil?
        return BigDecimal(0) if @cfs.net_cash_flow_from_operations.nil? || @cfs.capital_expenditure.nil?
        @cfs.net_cash_flow_from_operations + @cfs.capital_expenditure
      end

      def current_ratio
        return BigDecimal(0) if @bs.nil?
        return BigDecimal(0) if @bs.current_liabilities.nil? || @bs.current_assets.nil?
        return BigDecimal(0) if @bs.current_liabilities.zero?
        @bs.current_assets / @bs.current_liabilities
      end

      def eps_basic
        return BigDecimal(0) if @is.nil?
        @is.eps_basic
      end

    end

  end

end
