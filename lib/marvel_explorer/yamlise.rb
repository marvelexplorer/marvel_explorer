module MarvelExplorer
  class Explorer
    def yamlise_characters
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

        write_yaml h, c
      end
    end

    def yamlise_comic
      h = {
        'date' => comic[:dates][0]['date'],
        'year' => Date.parse(comic[:dates][0]['date']).strftime('%Y'),
        'title' => comic[:title],
        'issue' => comic[:issueNumber],
        'series' => {
          'period' => series[:period],
          'name' => series[:name]
        },
        'url' => comic[:urls][0]['url'],
        'image' => comic[:thumbnail]
      }

      write_yaml h, 'comic'
    end

    def write_yaml h, path
      FileUtils.mkdir_p '%s/_data/' % @config['jekyll_dir']
      y = File.open '%s/_data/%s.yml' % [
        @config['jekyll_dir'],
        path
      ], 'w'
      y.write h.to_yaml
      y.close
    end

    def yamlise
      FileUtils.mkdir_p '%s/_data' % @config['jekyll_dir']
      %w{ comic characters }.each do |item|
        eval "yamlise_#{item}"
      end
    end

    def yamls
      @yamls ||= begin
        yamls = {}
        %w{ start end comic }.each do |thing|
          begin
            file = File.open '%s/_data/%s.yml' % [
              @config['jekyll_dir'],
              thing
            ]
          rescue Exception
            update
            file = File.open '%s/_data/%s.yml' % [
              @config['jekyll_dir'],
              thing
            ]
          end
          y = YAML.load file
          yamls[thing] = y
        end
        yamls
      end
    end
  end
end
