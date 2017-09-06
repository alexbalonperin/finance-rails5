class CikLookup < ApplicationRecord
  belongs_to :company

  def self.active
    CikLookup.all.select { |c| c.company.active }
  end
end
