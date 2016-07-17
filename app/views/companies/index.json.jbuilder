json.array!(@companies) do |company|
  json.extract! company, :id, :name, :sector_id, :symbol
  json.url company_url(company, format: :json)
end
