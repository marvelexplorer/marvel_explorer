require 'marvel_explorer'

module MarvelExplorer
  class CLI < Thor
    desc 'version', 'Print marvel_explorer version'
    def version
      puts 'marvel_explorer version %s' % [
        VERSION
      ]
    end
    map %w(-v --version) => :version

    desc 'update', 'Get the next iteration'
    def update
      @me = Explorer.new
      @me.update
    end
    map %w(-u --update) => :update

    desc 'tweet', 'Tweet the current iteration'
    def tweet
      @me = Explorer.new
      @me.tweet
    end
    map %w(-t --tweet) => :tweet

    desc 'publish', 'Publish the current iteration to Github Pages'
    def publish
      @me = Explorer.new
      @me.publish
    end
    map %w(-p --publish) => :publish

    desc 'perform', 'Update, publish and tweet'
    def perform
      @me = Explorer.new
      @me.update
      @me.publish
      @me.tweet
    end
  end
end
