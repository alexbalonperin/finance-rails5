module Utils

  module FileUtil

    def self.folder_names(dir)
      Dir.entries(dir).select do |entry|
        File.directory? File.join(dir, entry) and !(entry =='.' || entry == '..')
      end
    end

    def self.filenames(dir)
      Dir.entries(dir).select do |entry|
        File.file? File.join(dir, entry)
      end
    end

  end

end
