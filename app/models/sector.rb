class Sector < ApplicationRecord
  has_many :industries
  has_many :companies, :through => :industries

  validates :name, presence: true
end
