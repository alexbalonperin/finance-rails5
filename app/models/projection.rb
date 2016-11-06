class Projection < ApplicationRecord

  belongs_to :company

  def self.latest
    Projection.where(:latest => true)
  end

end
