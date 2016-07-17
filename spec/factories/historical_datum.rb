FactoryGirl.define do
  factory :historical_datum do
    trade_date "2016-04-10"
    open "9.99"
    high "9.99"
    low "9.99"
    close "9.99"
    volume 1
    adjusted_close "9.99"
    company
  end
end
