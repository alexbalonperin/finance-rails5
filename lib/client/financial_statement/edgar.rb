module Client

  module FinancialStatement
    require 'open-uri'
    require 'cgi'
    require 'zip'
    require 'csv'

    class Edgar
        SERVICE_URI = 'https://www.sec.gov/Archives/edgar/'

      def filing_record(line)
        elements = line.split("|")
        OpenStruct.new(
          {
              cik: elements[0],
              company_name: elements[1],
              form_type: elements[2],
              date: elements[3],
              filename: elements[4].gsub(/\n/, '')
          }
        )
      end

      def cik_record(line)
        elements = line.split(":")
        OpenStruct.new(
          {
              cik: elements[1].strip,
              company_name: elements[0].strip
          }
        )
      end

      def sanitize_company_name(name)
        CGI.unescapeHTML(name).downcase.gsub(/[^0-9a-z ]/i,'').gsub(/\/.*\//,'').gsub(/\(.*\)/,'').gsub(/\s+/,'')
      end

      def cik_to_company_name()
        path = 'cik-lookup-data.txt'
        filename = "data/cik_lookup/#{Time.now.strftime("%Y%m%d")}.txt"
        download_file(filename, path) unless File.file?(filename)
        records = file_to_records(filename, method(:cik_record))
        companies = Company.active.group_by { |r| sanitize_company_name(r.name) }
        r = records.inject([]) do |data, record|
          record_name = sanitize_company_name(record.company_name)
          next data unless companies.has_key?(record_name)
          candidates = companies[record_name]
          next data if candidates.nil?
          company = candidates.sort_by(&:created_at).reverse.first
          element = CikLookup.where('cik = ?', record.cik)
          if element.empty?
            data << CikLookup.new({company_id: company.id, cik: record.cik})
          end
          data
        end

        puts "Found #{r.size} new cik mappings"
        CikLookup.import(r.uniq {|a| a.company_id }) if r.present?
      end

      def get_latest_filings()
        path = 'full-index/master.idx'
        filename = "data/filing_releases/#{Time.now.strftime("%Y%m%d")}.idx"
        get_filings(path, filename)
      end

      def get_old_filings(year, quarter)
        raise ArgumentException unless ['QTR1', 'QTR2', 'QTR3', 'QTR4'].include?(quarter)
        puts "Getting Filings information for quarter #{year}/#{quarter}"
        path = "full-index/#{year}/#{quarter}/master.idx"
        directory = "data/filing_releases/#{year}/#{quarter}"
        FileUtils.mkdir_p directory
        filename = "#{directory}/#{Time.now.strftime("%Y%m%d")}.idx"
        get_filings(path, filename)
      end

      def set_period_focus()
        income_statements = IncomeStatement.select("f.filename, income_statements.*").joins("
            inner join filing_releases f on f.company_id = income_statements.company_id
                                        and f.form_type = income_statements.form_type
                                        and to_char(income_statements.report_date, 'YYYY-MM-DD') = f.date")
        balance_sheets = BalanceSheet.select("f.filename, balance_sheets.*").joins("
            inner join filing_releases f on f.company_id = balance_sheets.company_id
                                        and f.form_type = balance_sheets.form_type
                                        and to_char(balance_sheets.report_date, 'YYYY-MM-DD') = f.date")
        cash_flow_statements = CashFlowStatement.select("f.filename, cash_flow_statements.*").joins("
            inner join filing_releases f on f.company_id = cash_flow_statements.company_id
                                        and f.form_type = cash_flow_statements.form_type
                                        and to_char(cash_flow_statements.report_date, 'YYYY-MM-DD') = f.date")

        find_element = lambda do |adsh, details, el|
           adsh == el.filename.split("/").last.split(".").first &&
           el.form_type == details[:form_type]
        end

        [2011].each do |year|
        #(2009..2017).to_a.each do |year|
          %w[q2].each do |period|
          #%w[q1 q2 q3 q4].each do |period|
            puts "Getting filing details for period #{year}:#{period}"
            filings_details = get_filings_details(year, period)
            next if filings_details.nil?
            key, value = filings_details.first
            {key => value}.each do |adsh, details|
              next if adsh.nil?
              income_statement = income_statements.find { |i| find_element.call(adsh, details, i) }
              balance_sheet = balance_sheets.find { |i| find_element.call(adsh, details, i) }
              cash_flow_statement = cash_flow_statements.find { |i| find_element.call(adsh, details, i) }
              puts income_statement, balance_sheet, cash_flow_statement
              next if income_statement.nil? || balance_sheet.nil? || cash_flow_statement.nil?
              income_statement.year = balance_sheet.year = cash_flow_statement.year = details[:year]
              income_statement.period = balance_sheet.period = cash_flow_statement.period = details[:period]
              unless income_statement.save && balance_sheet.save && cash_flow_statement.save
                puts "Couldn't save year and period for filing details #{adsh}: #{details}"
              end
            end
          end
        end
      end

      private

      def get_filings_details(year, period)
         result = {}
         path = "data/edgar_financials/#{year}#{period}"
         Zip::File.open("#{path}.zip") do |zipfile|
           entry = zipfile.find_entry("sub.txt")
           next if entry.nil?
           filename = "#{path}/#{entry.name}"
           unless File.exist?(filename)
             FileUtils::mkdir_p(File.dirname(filename))
             zipfile.extract(entry, filename)
           end
           CSV.foreach("data/edgar_financials/#{year}#{period}/#{entry.name}", headers: true, col_sep: "\t") do |line|
              result[line['adsh']] = {
                cik: line['cik'],
                year: line['fy'],
                period: line['fp'],
                filed: line['filed'],
                form_type: line['form']
              }
           end
         end
         result
      end

      def download_file(filename, path)
        puts "Downloading file"
        File.open(filename, "wb") do |saved_file|
          open(SERVICE_URI + path) do |index_file|
            saved_file.write(index_file.read)
          end
        end
      end

      def file_to_records(filename, to_record, skip=0)
        data = []
        File.foreach(filename).with_index do |line, line_num|
          if !line.valid_encoding?
            s = line.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
            line = s.gsub(/dr/i,'med')
          end
          next if line_num <= skip
          #puts "#{line_num}: #{line}"
          data << to_record.call(line)
        end
        data
      end

      def get_filings(path, filename)
        download_file(filename, path) unless File.file?(filename)
        records = file_to_records(filename, method(:filing_record), skip=10)
        records.each { |r| r.cik = r.cik.rjust(10, '0')}
        companies = CikLookup.active.group_by(&:cik)
        r = records.inject([]) do |data, record|
          next data unless companies.has_key?(record.cik)
          candidates = companies[record.cik]
          next data if candidates.nil?
          company_id = candidates.sort_by(&:created_at).reverse.first.company_id
          element = FilingRelease.where(['company_id = ? and date = ? and form_type = ?', company_id, record.date, record.form_type])
          if element.empty?
            data << FilingRelease.new({
              company_id: company_id,
              cik: record.cik,
              form_type: record.form_type,
              date: record.date,
              filename: record.filename
            })
          end
          data
        end
        puts "Found #{r.size} new filings"
        FilingRelease.import(r.uniq {|a| [a.cik, a.date, a.form_type]}) if r.present?
      end

    end

  end

end
