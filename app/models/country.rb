class Country < ApplicationRecord
  validates :name, :code, presence: true
end
