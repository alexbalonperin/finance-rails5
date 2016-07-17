json.array!(@historical_data) do |historical_datum|
  json.extract! historical_datum, :id, :trade_date, :open, :high, :low, :close, :volume, :adjusted_close, :company_id
  json.url historical_datum_url(historical_datum, format: :json)
end
