module MarvelExplorer
  class Explorer
    def save
      File.open @config['marshal_file'], 'w' do |file|
        Marshal.dump end_character, file
      end
    end

    def yamlise
      FileUtils.mkdir_p '%s/_data' % @config['jekyll_dir']

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
          @config['jekyll_dir'],
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

      y = File.open '%s/_data/comic.yml' % @config['jekyll_dir'], 'w'
      y.write h.to_yaml
      y.close
    end

    def yamls
      @yamls ||= begin
        yamls = {}
        %w{start end comic}.each do |thing|
          y = YAML.load File.open '%s/_data/%s.yml' % [
            @config['jekyll_dir'],
            thing
          ]
          yamls[thing] = y
        end
        yamls
      end
    end
  end
end
