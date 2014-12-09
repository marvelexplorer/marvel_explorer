module MarvelExplorer
  class Explorer
    attr_accessor :config

    def initialize config_file = "#{ENV['HOME']}/.marvel_explorer/config.yml"
      @config = YAML.load(File.open(File.join(File.dirname(__FILE__), '..', '..', 'config/defaults.yml')))
      @config.merge! YAML.load File.open config_file
    end
    
    def publish
      commit
    end
  end
end
