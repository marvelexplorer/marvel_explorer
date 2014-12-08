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

    desc 'ranking', 'Show the most popular characters'
    method_option :commits,
                  type: :numeric,
                  default: 96,
                  desc: 'How many commits to rank over; 96 is 24 hours, 672 is 7 days',
                  aliases: '-c'
    method_option :limit,
                  type: :numeric,
                  default: 5,
                  desc: 'Get top N rankings',
                  aliases: '-l'

    def ranking
      @me = Explorer.new
      @me.record_rankings commits: options[:commits], limit: options[:limit]
    end
    map %w(-r --ranking) => :ranking

    desc 'perform', 'Update, publish and tweet'
    def perform
      @me = Explorer.new
      @me.update
      @me.publish
      @me.tweet
    end
  end
end
