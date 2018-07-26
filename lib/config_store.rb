class ConfigStore
  class << self
    attr_reader :config
    
    # options: {key => filen_name, ...}
    def load(options = {})
      @config ||= {}
      options.each do |key, file_name|
        @config[key.to_sym] = load_config_from_yaml(file_name)
      end
    end
    
    protected
    
    def load_config_from_yaml(file)
      c = YAML.load(File.read(file))
      c.merge! c.fetch(Rails.env, {})
      c.symbolize_keys!
    end
  end
end
