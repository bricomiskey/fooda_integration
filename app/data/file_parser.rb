require 'yaml'

class FileParser

  def self.load_file(file, options={})
    if options[:erb].to_i == 1
      YAML.load(ERB.new(File.read(file)).result)
    else
      YAML.load_file(file)
    end
  end

end
