class PotentialInvestment < ApplicationRecord

  belongs_to :company

  def self.latest
    PotentialInvestment.where(:latest => true)
  end

end
