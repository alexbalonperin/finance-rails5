json.array!(@sectors) do |sector|
  json.extract! sector, :id, :name
  json.url sector_url(sector, format: :json)
end
