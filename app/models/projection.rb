class Projection < ApplicationRecord

  belongs_to :company

  def to_s
    s = "Company: #{company.name}\n"
    s << "   projections: #{year}\n"
    s << "                    1y        5y        10y\n"
    s << "   projected eps: %.2f      %.2f      %.2f\n" % [projected_eps_1y || 0, projected_eps_5y || 0, projected_eps_10y || 0]
    s
  end
end
