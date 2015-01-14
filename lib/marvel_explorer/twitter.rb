module MarvelExplorer
  class Explorer
    def twitter_client
      twitter_config = {
        consumer_key:        @config['twitter']['consumer']['key'],
        consumer_secret:     @config['twitter']['consumer']['secret'],
        access_token:        @config['twitter']['oauth']['token'],
        access_token_secret: @config['twitter']['oauth']['secret']
      }
      Twitter::REST::Client.new(twitter_config)
    end

    def tweet_message
      tm = 'In %s, %s appeared in %s #%s with %s %s' % [
        yamls['comic']['year'],
        yamls['start']['name'],
        yamls['comic']['series']['name'],
        yamls['comic']['issue'],
        yamls['end']['name'],
        @config['marvelexplorer_url']
      ]

      if tm.length > @config['tweet_length'].to_i
        tm = '%s…' % s[0, @config['tweet_length'].to_i - 1]
      end

      tm
    end
  end
end
