class Industry < ApplicationRecord
  belongs_to :sector
  has_many :companies

  validates :name, presence: true

  def sector_name
    sector.name
  end

  def newcomers
    companies.where("first_trade_date > now() - interval '1 year'").order(first_trade_date: :desc)
  end

end
