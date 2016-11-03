class Sector < ApplicationRecord
  has_many :industries
  has_many :companies, :through => :industries

  validates :name, presence: true


  def newcomers
    companies.where("first_trade_date > now() - interval '3 months'").order(first_trade_date: :desc)
  end
end
