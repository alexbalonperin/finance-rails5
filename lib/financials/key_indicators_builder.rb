module Financials


  class KeyIndicatorsBuilder

    KFI = {
        :debt_to_equity => lambda { |calc| calc.debt_to_equity_ratio }
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

      def initialize
        @per_year = Hash.new { |h, k| h[k] = {} }
      end

      def add(year, label, value)
        @per_year[year][label] = value
      end

      def avg_growth(period, label)
        avg(@per_year, period, label)
      end

      def period_growth(period, label)
        period(@per_year, period, label)
      end

      def yoy_growth(period, label)
        yoy(@per_year, period, label)
      end

      def get
        @per_year
      end

      def to_s
        @per_year.each do |year, data|
          puts "YEAR: #{year}"
          data.each do |label, value|
            puts "------ #{label} => #{value}"
          end
        end
      end

    end

    def build
      @years.sort.reverse.inject(KeyIndicator.new) do |kfi, year|
        calc = KFICalculator.new(@balance_sheets[year], @income_statements[year], @cash_flow_statements[year])
        KFI.each { |label, func| kfi.add(year, label, func.call(calc)) }
        kfi
      end
    end

    class KFICalculator

      include Calculator::Ratio

      def initialize(balance_sheet, income_statement, cash_flow_statement)
        @bs = balance_sheet
        @is = income_statement
        @cfs = cash_flow_statement
      end

      def debt_to_equity_ratio
        debt_to_equity(@bs.total_liabilities, @bs.shareholders_equity)
      end

      def eps
        @income
      end

    end

  end

end

