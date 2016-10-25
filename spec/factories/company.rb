FactoryGirl.define do
  factory :company do
    industry
    name { generate(:company_name) }
    symbol { generate(:symbol) }
    created_at { Time.now }
    updated_at { Time.now }

    factory :company_with_statements do
      transient do
        income_statement_count 1
        balance_sheet_count 1
        cash_flow_statement_count 1
      end
      after(:create) do |company, evaluator|
        create_list(:income_statement, evaluator.income_statement_count, company_id: company.id)
        create_list(:balance_sheet, evaluator.balance_sheet_count, company_id: company.id)
        create_list(:cash_flow_statement, evaluator.cash_flow_statement_count, company_id: company.id)
      end
    end
  end
end