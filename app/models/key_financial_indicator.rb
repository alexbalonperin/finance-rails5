class KeyFinancialIndicator < ApplicationRecord

  def reset_latest
    latest = false
    save
  end
  
end
