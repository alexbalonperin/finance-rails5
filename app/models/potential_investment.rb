class PotentialInvestment < ApplicationRecord

  belongs_to :company

  def self.latest
    PotentialInvestment.where(:latest => true)
  end

  def reset_latest
    latest = false
    save
  end

end
