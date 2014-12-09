module MarvelExplorer
  def self.get_year comic
    DateTime.parse(comic.dates.select { |d| d['type'] == 'onsaleDate' }[0]['date']).year
  end

  def self.validate_character character
    character.thumbnail &&
    character.thumbnail['path'] !~ /not_available/
  end

  def self.validate_comic comic
    comic.characters['available'] > 1 &&
    MarvelExplorer.get_year(comic) > 1900 &&
    comic.thumbnail &&
    comic.thumbnail['path'] !~ /not_available/
  end
end
