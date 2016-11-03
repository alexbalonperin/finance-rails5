module financials

  class KeyIndicatorsImporter

    def initialize(companies = nil)
      @companies = companies || Company.active
    end

    def import
      @companies.each do |company|
        kib = KeyIndicatorsBuilder.new(company)
        ki = kib.build
        ActiveRecord::Base.transaction do
          company.latest_key_financial_indicators.update_all(:latest => false)
          save(ki, company)
        end
      end
    end

    def save(ki, company)
      ki.years.each do |year|
        KeyFinancialIndicator.create({
          :company_id => company.id,
          :debt_to_equity => ki.per_year[year]['debt_to_equity'],
          :return_on_equity => ki.per_year[year]['return_on_equity'],
          :return_on_assets => ki.per_year[year]['return_on_assets'],
          :eps_basic => ki.per_year[year]['eps_basic'],
          :free_cash_flow => ki.per_year[year]['free_cash_flow'],
          :current_ratio => ki.per_year[year]['current_ratio'],
          :net_margin => ki.per_year[year]['net_margin'],
          :debt_to_equity_yoy_growth => ki.per_year[year]['debt_to_equity_yoy_growth'],
          :return_on_equity_yoy_growth => ki.per_year[year]['return_on_equity_yoy_growth'],
          :return_on_assets_yoy_growth => ki.per_year[year]['return_on_assets_yoy_growth'],
          :eps_basic_yoy_growth => ki.per_year[year]['eps_basic_yoy_growth'],
          :free_cash_flow_yoy_growth => ki.per_year[year]['free_cash_flow_yoy_growth'],
          :current_ratio_yoy_growth => ki.per_year[year]['current_ratio_yoy_growth'],
          :net_margin_yoy_growth => ki.per_year[year]['net_margin_yoy_growth'],
          :return_on_equity_5y_annual_rate_of_return => ki.per_year[year]['return_on_equity_5y_annual_rate_of_return'],
          :return_on_assets_5y_annual_rate_of_return => ki.per_year[year]['return_on_assets_5y_annual_rate_of_return'],
          :eps_basic_5y_annual_rate_of_return => ki.per_year[year]['eps_basic_5y_annual_rate_of_return'],
          :debt_to_equity_5y_avg => ki.per_year[year]['debt_to_equity_5y_avg'],
          :free_cash_flow_5y_avg => ki.per_year[year]['free_cash_flow_5y_avg'],
          :current_ratio_5y_avg => ki.per_year[year]['current_ratio_5y_avg'],
          :net_margin_5y_avg => ki.per_year[year]['net_margin_5y_avg'],
          :return_on_equity_10y_annual_rate_of_return => ki.per_year[year]['return_on_equity_10y_annual_rate_of_return'],
          :return_on_assets_10y_annual_rate_of_return => ki.per_year[year]['return_on_assets_10y_annual_rate_of_return'],
          :eps_basic_10y_annual_rate_of_return => ki.per_year[year]['eps_basic_10y_annual_rate_of_return'],
          :debt_to_equity_10y_avg => ki.per_year[year]['debt_to_equity_10y_avg'],
          :free_cash_flow_10y_avg => ki.per_year[year]['free_cash_flow_10y_avg'],
          :current_ratio_10y_avg => ki.per_year[year]['current_ratio_10y_avg'],
          :net_margin_10y_avg  => ki.per_year[year]['net_margin_10y_avg '],
          :n_past_financial_statements => ki.n_past_financial_statements,
          :year => year,
          :latest => true
        })
      end
    end

  end

end
