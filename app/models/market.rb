class Market < ApplicationRecord
  belongs_to :country

  validates :name, presence: true

  def country_name
    country.name
  end

  def country_code
    country.code
  end

end
