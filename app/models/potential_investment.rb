class PotentialInvestment < ApplicationRecord

  belongs_to :company

  def self.latest
    PotentialInvestment.select('DISTINCT ON(company_id) *')
        .order('company_id DESC, created_at')
  end

end
