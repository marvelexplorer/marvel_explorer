module MarvelExplorer
  class Explorer
    def comic
      @comic ||= begin
        comics = Ultron::Comics.by_character_and_vanilla_comics start_character.id
        @comic  = comics.sample
        until MarvelExplorer.validate_comic @comic
          @comic = comics.sample
        end
        @comic
      end
    end

    def series
      @comic[:title] =~ /(.*) \((.*)\) #(.*)/
      { name: $1, period: $2 }
    end
  end
end
