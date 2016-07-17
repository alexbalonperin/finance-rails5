FactoryGirl.define do
  factory :country do
    name { generate(:country_name) }
    code 'us'
    created_at { Time.now }
    updated_at { Time.now }
  end
end