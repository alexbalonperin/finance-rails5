module CompanyHelper

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