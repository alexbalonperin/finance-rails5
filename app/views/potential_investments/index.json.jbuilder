json.array!(@potential_investments) do |potential_investment|
  json.extract! potential_investment, :id
  json.url potential_investment_url(potential_investment, format: :json)
end
