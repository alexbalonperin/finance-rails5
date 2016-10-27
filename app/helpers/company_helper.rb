module CompanyHelper

  def percent_func(val, precision = 4)
    return 0.0 if val.nil?
    number_to_percentage(val.to_f * 100, precision: precision)
  end

  def precision_func(val, precision = 4)
    return 0.0 if val.nil?
    number_with_precision(val, precision: precision)
  end

  def currency_func(val, precision = 0)
    return 0.0 if val.nil?
    number_to_currency(val, precision: precision)
  end

  def kfis
    {
        'debt_to_equity'              => lambda { |val| precision_func(val) },
        'debt_to_equity_yoy_growth'   => lambda { |val| percent_func(val) },
        'return_on_equity'            => lambda { |val| precision_func(val) },
        'return_on_equity_yoy_growth' => lambda { |val| percent_func(val) },
        'eps_basic'                   => lambda { |val| precision_func(val) },
        'eps_basic_yoy_growth'        => lambda { |val| percent_func(val) },
        'free_cash_flow'              => lambda { |val| currency_func(val) },
        'free_cash_flow_yoy_growth'   => lambda { |val| percent_func(val) },
        'current_ratio'               => lambda { |val| precision_func(val) }
    }
  end

  def display_income_attributes
    col_to_reject = %w[created_at updated_at id year report_date company_id]
    attributes = IncomeStatement.column_names.reject { |col| col_to_reject.include?(col) }
    display_function = lambda { |a| a.split('_').map(&:capitalize).join(' ') }
    attributes.inject({}) do |h, attribute|
      h[attribute] = {
          :display => display_function,
          :format =>
              case attribute.to_sym
                when :eps_basic, :eps_diluted, :preferred_dividends_income_statement_impact,
                    :dividends_per_basic_common_share, :gross_margin, :eps_basic_usd
                  lambda { |a| a }
                else
                  lambda { |a| number_to_currency(a, precision: 0)}
              end
      }
      h
    end
  end

  def display_balance_sheet_attributes
    col_to_reject = %w[created_at updated_at id year report_date company_id]
    attributes = BalanceSheet.column_names.reject { |col| col_to_reject.include?(col) }
    display_function = lambda { |a| a.split('_').map(&:capitalize).join(' ') }
    attributes.inject({}) do |h, attribute|
      h[attribute] = {
          :display => display_function,
          :format =>
              case attribute.to_sym
                when :eps_basic, :eps_diluted, :preferred_dividends_income_statement_impact,
                    :dividends_per_basic_common_share, :gross_margin, :eps_basic_usd
                  lambda { |a| a }
                else
                  lambda { |a| number_to_currency(a, precision: 0)}
              end
      }
      h
    end
  end

  def display_cash_flow_attributes
    col_to_reject = %w[created_at updated_at id year report_date company_id]
    attributes = CashFlowStatement.column_names.reject { |col| col_to_reject.include?(col) }
    display_function = lambda { |a| a.split('_').map(&:capitalize).join(' ') }
    attributes.inject({}) do |h, attribute|
      h[attribute] = {
          :display => display_function,
          :format =>
              case attribute.to_sym
                when :eps_basic, :eps_diluted, :preferred_dividends_income_statement_impact,
                    :dividends_per_basic_common_share, :gross_margin, :eps_basic_usd
                  lambda { |a| a }
                else
                  lambda { |a| number_to_currency(a, precision: 0)}
              end
      }
      h
    end
  end
end