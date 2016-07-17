class Industry < ApplicationRecord
  belongs_to :sector
  has_many :companies

  validates :name, presence: true

  def sector_name
    sector.name
  end

end
