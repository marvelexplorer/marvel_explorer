module MarvelExplorer
  class Explorer
    def start_character
      @start_character ||= begin
        File.open @config['marshal_file'] do |file|
          Marshal.load file
        end
      rescue
        Ultron::Characters.find @config['default_id']
      ensure
        true
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
      File.open @config['marshal_file'], 'w' do |file|
        Marshal.dump end_character, file
      end

    #  FileUtils.mkdir_p @config['cache_dir']
    #  File.open '%s/%d' % [ @config['cache_dir'], end_character[:id] ], 'w' do |file|
    #    Marshal.dump end_character, file
    #  end
    end
  end
end
