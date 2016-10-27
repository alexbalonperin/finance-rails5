module Financials

  class BasicSelector < PotentialInvestmentSelector
    ROE_MIN = 12
    EPS_MIN = 15
    POSITIVE_GROWTH_PERCENTAGE = 0.7
    STEADY_GROWTH_N_YEARS = 10

    def initialize(companies = nil)
      @companies = companies || Company.active.where("first_trade_date < now() - interval '8 years'")
      @roe_min = ROE_MIN
      @eps_min = EPS_MIN
      @positive_growth_percentage = POSITIVE_GROWTH_PERCENTAGE
      @selector = 'basic'
      @steady_growth_n_years = STEADY_GROWTH_N_YEARS
    end


    def select
      selected_ki = {}
      selected = @companies.select do |company|
        kib = Financials::KeyIndicatorsBuilder.new(company)
        ki = kib.build
        ki.add_all('company_id', company.id)
        select = meet_criteria?(ki)
        if select
          selected_ki[company.id] = ki
        end
        select
      end
      save(selected, selected_ki)
    end

  end

end
