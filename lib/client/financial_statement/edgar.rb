module Client

  module FinancialStatement
    require 'open-uri'
    require 'cgi'

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
        companies = Company.all.group_by { |r| sanitize_company_name(r.name) }
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

      private

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
        companies = CikLookup.all.group_by(&:cik)
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
