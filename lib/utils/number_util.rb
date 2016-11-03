module Utils

  module NumberUtil

    def self.currency_to_number(str)
      return 0.0 if str == 'n/a'
      currency, str = str.first, str[1..-1]
      number, multiplier = Float(str[0..-2]), str.last
      case multiplier
      when 'k'
        number * 1000
      when 'M'
        number * 1000_000
      when 'B'
        number * 1000_000_000
      when 'T'
        number * 1000_000_000_000
      end
    end

  end

end
