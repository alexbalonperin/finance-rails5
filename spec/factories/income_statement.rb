FactoryGirl.define do
  factory :income_statement do
    company
    year '2015'
    report_date '2015-10-25'
    revenues '558524000'
    cost_of_revenue '415739000'
    gross_profit '142785000'
    selling_general_and_administrative_expense '76820000'
    research_and_development_expense '7937000'
    ebit '60851000'
    interest_expense '6997000'
    income_tax_expense '19088000'
    net_income '34766000'
    net_income_common_stock '34766000'
    preferred_dividends_income_statement_impact '0'
    eps_basic '1.19'
    eps_diluted '1.19'
    weighted_avg_shares '29110000'
    weighted_avg_shares_diluted '29581000'
    dividends_per_basic_common_share '0.24'
    net_income_discontinued_operations '558524000'
    gross_margin '0.2556'
    revenues_usd '0'
    ebit_usd '60851000'
    net_income_common_stock_usd '34766000'
    eps_basic_usd '1.19'
    created_at { Time.now }
    updated_at { Time.now }
  end
end
