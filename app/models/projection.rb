class Projection < ApplicationRecord

  belongs_to :company

  def self.latest(type = 'basic')
    Projection.where('latest = true AND selector = ?', type)
  end

end
