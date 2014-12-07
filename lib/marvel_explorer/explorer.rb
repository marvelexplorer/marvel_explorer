module MarvelExplorer
  class Explorer
    attr_accessor :config

    def initialize config_file = "#{ENV['HOME']}/.marvel_explorer/config.yml"
      @config = YAML.load File.open config_file
    end

    def start_character
      @start_character ||= begin
        File.open @config['MARSHAL_FILE'] do |file|
          Marshal.load file
        end
      rescue
        Ultron::Characters.find @config['DEFAULT_ID']
      ensure
        true
      end
    end

    def comic
      @comic ||= begin
        comics = Ultron::Comics.by_character_and_vanilla_comics start_character.id
        @comic  = comics.sample
        # some comics have no characters listed, and we need at least 2 to make the game worth playing
        until validate_comic
          @comic = comics.sample
        end
        @comic
      end
    end

    def end_character
      @end_character ||= begin
        characters = Ultron::Characters.by_comic comic.id
        end_character = start_character
        # we want a different character for the next iteration, obvs.
        until end_character.id != start_character.id && MarvelExplorer.validate_character(end_character)
          end_character = characters.sample
        end

        end_character
      end
    end

    def save
      File.open @config['MARSHAL_FILE'], 'w' do |file|
        Marshal.dump end_character, file
      end
    end

    def yamlise
      FileUtils.mkdir_p '%s/_data' % @config['JEKYLL_DIR']

      [
        'start',
        'end'
      ].each do |c|
        h = {
          'name' => eval("#{c}_character[:name]"),
          'description' => eval("#{c}_character[:description]"),
          'url' => eval("#{c}_character[:urls][1]['url']"),
          'image' => eval("#{c}_character[:thumbnail]")
        }

        y = File.open '%s/_data/%s.yml' % [
          @config['JEKYLL_DIR'],
          c
        ], 'w'
        y.write h.to_yaml
        y.close
      end

      s = MarvelExplorer.series(comic[:title])

      h = {
        'date' => comic[:dates][0]['date'],
        'year' => Date.parse(comic[:dates][0]['date']).strftime('%Y'),
        'title' => comic[:title],
        'issue' => comic[:issueNumber],
        'series' => {
          'period' => s[:period],
          'name' => s[:name]
        },
        'url' => comic[:urls][0]['url'],
        'image' => comic[:thumbnail]
      }

      y = File.open '%s/_data/comic.yml' % @config['JEKYLL_DIR'], 'w'
      y.write h.to_yaml
      y.close
    end

    def update
      yamlise
      save
    end

    def yamls
      @yamls ||= begin
        yamls = {}
        %w{start end comic}.each do |thing|
          y = YAML.load File.open '%s/_data/%s.yml' % [
            @config['JEKYLL_DIR'],
            thing
          ]
          yamls[thing] = y
        end
        yamls
      end
    end

    def tweet_message
      tm = 'In %s, %s appeared in %s of the %s run of %s with %s' % [
        yamls['comic']['year'],
        yamls['start']['name'],
        'issue #%s' % yamls['comic']['issue'],
        yamls['comic']['series']['period'],
        yamls['comic']['series']['name'],
        yamls['end']['name']
      ]

      if tm.length > @config['TWEET_LENGTH'].to_i
        tm = '%s…' % s[0, @config['TWEET_LENGTH'].to_i - 1]
      end

      tm
    end

    def commit_message
      '%s -> %s -> %s' % [
        yamls['start']['name'],
        yamls['comic']['series']['name'],
        yamls['end']['name']
      ]
    end

    def twitter_client
      twitter_config = {
        consumer_key:        @config['TWITTER_CONSUMER_KEY'],
        consumer_secret:     @config['TWITTER_CONSUMER_SECRET'],
        access_token:        @config['TWITTER_OAUTH_TOKEN'],
        access_token_secret: @config['TWITTER_OAUTH_SECRET']
      }
      Twitter::REST::Client.new(twitter_config)
    end

    def validate_comic
      @comic.characters['available'] > 1 &&
      MarvelExplorer.get_year(@comic) > 1900 &&
      @comic.thumbnail['path'] !~ /not_available/
    end

    def tweet
      twitter_client.update tweet_message
    end

    def commit
      g = Git.open @config['JEKYLL_DIR']

      g.add '.'
      g.commit commit_message
      g.push(g.remote('origin'))
    end

    def publish
      commit
    end
  end

  def self.get_year comic
    DateTime.parse(comic.dates.select { |d| d['type'] == 'onsaleDate' }[0]['date']).year
  end

  def self.series s
    s =~ /(.*) \((.*)\) #(.*)/
    { name: $1, period: $2 }
  end

  def self.validate_character character
    character.thumbnail['path'] !~ /not_available/
  end
end
