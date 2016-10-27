module Financials

  class StatementIssueResolver

    class Resolver

      def initialize(error)
        @error = error
      end

      def resolve
        raise 'Should implement in subclass'
      end
    end

    class UnreadableResolver < Resolver

      STATEMENT_TYPE = {
          'income' => 'income_statement',
          'balance' => 'balance_sheet',
          'cashflow' => 'cashflow_statement'
      }

      def initialize(error)
        @provider_class = Client::FinancialStatement::StockRow
        @importer_class = Importer::StockRowStatementImporter
        @error = error
      end

      def resolve
        company = @error.company
        provider = @provider_class.new
        provider.send(STATEMENT_TYPE[@error.statement_type], company.symbol, 'y')
        importer = @importer_class.new(company.symbol)
        begin
          importer.send("import_#{STATEMENT_TYPE[@error.statement_type]}")
          true
        rescue
          false
        end
      end

    end

    class MissingResolver < Resolver
      def resolve
        puts 'TODO: implement this resolver'
        false
      end
    end

    class ResolverBuilder
      def initialize(error)
        @error = error
      end

      def build
        case @error.error_type
          when 'unreadable'
            UnreadableResolver.new(@error)
          when 'missing'
            MissingResolver.new(@error)
          else
            raise 'No resolver available'
        end
      end
    end

    def initialize
      @errors = StatementError.all
    end

    def mark_resolved(error)
      error.resolved = true
      error.resolved_at = Time.current
      error.save
    end

    def resolve
      @errors.each do |error|
        builder = ResolverBuilder.new(error)
        resolver = builder.build
        mark_resolved(error) if resolver.resolve
      end
    end

  end

end
