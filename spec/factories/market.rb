FactoryGirl.define do
  factory :market do
    country
    name { generate(:market_name) }
    created_at { Time.now }
    updated_at { Time.now }
  end
end