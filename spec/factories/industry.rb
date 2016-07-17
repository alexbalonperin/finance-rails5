FactoryGirl.define do
  factory :industry do
    sector
    name { generate(:industry_name) }
    created_at { Time.now }
    updated_at { Time.now }
  end
end