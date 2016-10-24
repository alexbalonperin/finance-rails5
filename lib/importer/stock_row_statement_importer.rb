module Importer

  class StockRowStatementImporter < StatementImporter

    INCOME_STAT_MAPPING = [
        :revenues,
        :cost_of_revenue,
        :gross_profit,
        :selling_general_and_administrative_expense,
        :research_and_development_expense,
        :ebit,
        :interest_expense,
        :income_tax_expense,
        :net_income,
        :net_income_common_stock,
        :preferred_dividends_income_statement_impact,
        :eps_basic,
        :eps_diluted,
        :weighted_avg_shares,
        :weighted_avg_shares_diluted,
        :dividends_per_basic_common_share,
        :net_income_discontinued_operations,
        :gross_margin,
        :revenues_usd,
        :ebit_usd,
        :net_income_common_stock_usd,
        :eps_basic_usd
    ]
    BALANCE_SHEET_MAPPING = [
        :cash_and_equivalents,
        :trade_and_non_trade_receivables,
        :inventory,
        :current_assets,
        :goodwill_and_intangible_assets,
        :assets_non_current,
        :total_assets,
        :trade_and_non_trade_payables,
        :current_liabilities,
        :total_debt,
        :liabilities_non_current,
        :total_liabilities,
        :accumulated_other_comprehensive_income,
        :accumulated_retained_earnings_deficit,
        :shareholders_equity,
        :shareholders_equity_usd,
        :total_debt_usd,
        :cash_and_equivalents_usd
    ]
    CASH_FLOW_STAT_MAPPING = [
        :depreciation_amortization_accretion,
        :net_cash_flow_from_operations,
        :capital_expenditure,
        :net_cash_flow_from_investing,
        :issuance_repayment_of_debt_securities,
        :issuance_purchase_of_equity_shares,
        :payment_of_dividends_and_other_cash_distributions,
        :net_cash_flow_from_financing,
        :effect_of_exchange_rate_changes_on_cash,
        :net_cash_flow_change_in_cash_and_cash_equivalents
    ]

    def income_stat_mapping
      INCOME_STAT_MAPPING
    end

    def balance_sheet_mapping
      BALANCE_SHEET_MAPPING
    end

    def cashflow_statement_mapping
      CASH_FLOW_STAT_MAPPING
    end

    def init_years(row, h)
      years = row.cells.drop(1)
      years = years.map do |cell|
        time = cell.value
        year = time.year
        h[year] = {}
        h[year][:report_date] = time.to_s
        year
      end
      [years, h]
    end

    def map_data(type, mapping)
      i = 0
      h = {}
      years = []
      book = workbook(type)
      return if book.nil?
      book[0].each do |row|
        next if row.nil? || row.cells.blank? || row.cells.any?(&:nil?)
        if i == 0
          years, h = init_years(row, h)
        else
          kfi = row.cells.drop(1)
          kfi.each_with_index do |cell, index|
            h[years[index]][mapping[i-1]] = cell.value
          end
        end
        i += 1
      end
      h
    end

  end

end
