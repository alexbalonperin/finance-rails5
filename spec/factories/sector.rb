FactoryGirl.define do
  factory :sector do
    name { generate(:sector_name) }
    created_at { Time.now }
    updated_at { Time.now }
  end
end