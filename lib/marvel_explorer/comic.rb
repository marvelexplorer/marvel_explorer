module MarvelExplorer
  class Explorer
    def comic
      @comic ||= begin
        comics = Ultron::Comics.by_character_and_vanilla_comics start_character.id
        @comic  = comics.sample
        # some comics have no characters listed, and we need at least 2 to make the game worth playing
        until MarvelExplorer.validate_comic @comic
          @comic = comics.sample
        end
        @comic
      end
    end
  end
end
