FactoryGirl.define do
  sequence :company_name do |n|
    "Amerco #{n}"
  end

  sequence :industry_name do |n|
    "Aerospace #{n}"
  end

  sequence :sector_name do |n|
    "Technology #{n}"
  end

  sequence :country_name do |n|
    "Belgium #{n}"
  end

  sequence :symbol do |n|
    "MSFT #{n}"
  end

  sequence :market_name do |n|
    "NYSE #{n}"
  end
end