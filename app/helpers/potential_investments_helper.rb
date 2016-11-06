module PotentialInvestmentsHelper

  def extended_range(worst, min, max, best, type)
    func = case type
             when :percent
               lambda { |l| number_to_percentage(l, precision: 2) }
             when :currency
               lambda { |l| number_to_currency(l, precision: 2) }
             else
               lambda { |l| number_with_precision(l, precision: 2) }
            end
    worst = "<span class='small'>#{func.call(worst)}</span>"
    best = "<span class='small'>#{func.call(best)}</span>"
    min = func.call(min)
    max = func.call(max)
    "#{worst} ~ [#{min} - #{max}] ~ #{best}".html_safe
  end

  def evaluate(pi)
    if pi.good?
      'success'
    elsif pi.bad?
      'danger'
    elsif pi.not_so_good?
      'warning'
    end
  end

end
