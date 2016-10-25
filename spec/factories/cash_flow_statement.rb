FactoryGirl.define do
  factory :cash_flow_statement do
    company
    year '2015'
    report_date '2015-10-25'
    depreciation_amortization_accretion '4021000'
    net_cash_flow_from_operations '12200000'
    capital_expenditure '-2719000'
    net_cash_flow_from_investing '-28105000'
    issuance_repayment_of_debt_securities '14000000'
    issuance_purchase_of_equity_shares '3057000'
    payment_of_dividends_and_other_cash_distributions '0'
    net_cash_flow_from_financing '19151000'
    effect_of_exchange_rate_changes_on_cash '0'
    net_cash_flow_change_in_cash_and_cash_equivalents '3246000'
    created_at { Time.now }
    updated_at { Time.now }
  end
end
