FactoryGirl.define do
  factory :balance_sheet do
    company
    year '2015'
    report_date '2015-10-25'
    cash_and_equivalents '23993000'
    trade_and_non_trade_receivables '28091000'
    inventory '0'
    current_assets '57002000'
    goodwill_and_intangible_assets '72418000'
    assets_non_current '96586000'
    total_assets '153588000'
    trade_and_non_trade_payables '7643000'
    current_liabilities '23637000'
    total_debt '27000000'
    liabilities_non_current '21750000'
    total_liabilities '45387000'
    accumulated_other_comprehensive_income '0'
    accumulated_retained_earnings_deficit '-234295000'
    shareholders_equity '108201000'
    shareholders_equity_usd '108201000'
    total_debt_usd '27000000'
    cash_and_equivalents_usd '23993000'
    created_at { Time.now }
    updated_at { Time.now }
  end
end
