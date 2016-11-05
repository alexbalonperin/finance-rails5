module Financials

  class BasicSelector < PotentialInvestmentSelector
    SELECTOR = 'basic'
    ROE_MIN = 12
    EPS_MIN = 15
    FREE_CASH_FLOW_MIN = 0
    CURRENT_RATIO_MIN = 1
    POSITIVE_GROWTH_PERCENTAGE = 0.7
    STEADY_GROWTH_N_YEARS = 10

    def initialize(companies = nil)
      @companies = companies || Company.active.where("first_trade_date < now() - interval '8 years'")
      @roe_min = ROE_MIN
      @eps_min = EPS_MIN
      @positive_growth_percentage = POSITIVE_GROWTH_PERCENTAGE
      @selector = SELECTOR
      @steady_growth_n_years = STEADY_GROWTH_N_YEARS
      @free_cash_flow_min = FREE_CASH_FLOW_MIN
      @current_ratio_min = CURRENT_RATIO_MIN
    end

    def select
      ActiveRecord::Base.transaction do
        pis = PotentialInvestment.latest
        pis.each(&:reset_latest)
        selected_ki = {}
        index = 1
        selected = @companies.select do |company|
          puts "(#{index}/#{@companies.size}) Evaluating #{company.name} (#{company.id})"
          kib = Financials::KeyIndicatorsBuilder.new(company)
          ki = kib.build
          select = meet_criteria?(ki)
          puts ki.to_s
          if select
            selected_ki[company.id] = ki
          end
          index += 1
          select
        end
        save(selected, selected_ki)
      end
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
