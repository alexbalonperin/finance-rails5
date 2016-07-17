json.array!(@markets) do |market|
  json.extract! market, :id, :name, :country_id
  json.url market_url(market, format: :json)
end
