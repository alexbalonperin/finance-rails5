class Watchlist < ApplicationRecord

  belongs_to :company

  def self.active
    self.where(:deleted_at => nil)
  end

  def dynamic_kfi
    Rails.cache.fetch("#{company.id}/kfi", expires_in: 24.hours) do
      Financials::KeyIndicatorsBuilder.new(company).build
    end
  end

  def price_at_beginning_of_year
    company.price_at(DateTime.now.beginning_of_year)
  end

  def dynamic_projection
    # Rails.cache.fetch("#{company.id}/projection", expires_in: 24.hours) do
      projection = Financials::Projection.new(dynamic_kfi)
      projection.project(price_at_beginning_of_year)
    # end
  end

  def eps_diluted
    dynamic_kfi.current_year['eps_diluted']
  end

  def projected_eps_1y
    dynamic_projection.projected_eps_1y
  end

  def projected_price_1y_min
    dynamic_projection.projected_price_1y_min
  end

  def projected_price_1y_max
    dynamic_projection.projected_price_1y_max
  end

  def projected_price_1y_worst
    dynamic_projection.projected_price_1y_worst
  end

  def projected_price_1y_best
    dynamic_projection.projected_price_1y_best
  end

  def projected_rate_of_return_1y_min
    dynamic_projection.projected_rate_of_return_1y_min * 100
  end

  def projected_rate_of_return_1y_max
    dynamic_projection.projected_rate_of_return_1y_max * 100
  end

  def projected_rate_of_return_1y_worst
    dynamic_projection.projected_rate_of_return_1y_worst * 100
  end

  def projected_rate_of_return_1y_best
    dynamic_projection.projected_rate_of_return_1y_best * 100
  end

  def projected_eps_5y
    dynamic_projection.projected_eps_5y
  end

  def projected_price_5y_min
    dynamic_projection.projected_price_5y_min
  end

  def projected_price_5y_max
    dynamic_projection.projected_price_5y_max
  end

  def projected_price_5y_worst
    dynamic_projection.projected_price_5y_worst
  end

  def projected_price_5y_best
    dynamic_projection.projected_price_5y_best
  end

  def projected_rate_of_return_5y_min
    dynamic_projection.projected_rate_of_return_5y_min * 100
  end

  def projected_rate_of_return_5y_max
    dynamic_projection.projected_rate_of_return_5y_max * 100
  end

  def projected_rate_of_return_5y_worst
    dynamic_projection.projected_rate_of_return_5y_worst * 100
  end

  def projected_rate_of_return_5y_best
    dynamic_projection.projected_rate_of_return_5y_best * 100
  end

  def eps_diluted_10y_annual_rate_of_return
    dynamic_projection.eps_diluted_10y_annual_rate_of_return * 100
  end
end
