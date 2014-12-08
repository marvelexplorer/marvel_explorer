require 'spec_helper'

module MarvelExplorer
  describe Explorer do
    before :each do
      Timecop.freeze '2014-12-03T19:01:00+00:00'
      @me = Explorer.new 'config.yml'
    end

    after :each do
      Timecop.return
    end

    it 'should get the default start character', :vcr do
      @me.config['marshal_file'] = 'not_a_path'
      expect(@me.start_character.name).to eq 'Hulk'
    end

    it 'should load the stored character', :vcr do
      expect(@me.start_character.name).to eq 'Avengers'
    end

    it 'should select a comic for the start character', :vcr do
      @me.config['marshal_file'] = 'not_a_path'
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters\/1009351\/comics/)
      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
      expect(@me.comic.title).to eq 'Marvel Double Shot (2003) #2'
    end

    it 'should get the end character from the comic', :vcr do
      @me.config['marshal_file'] = 'not_a_path'
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters\/1009351\/comics/)
      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
      stub_request(:get, /gateway.marvel.com\/v1\/public\/comics\/19843\/characters/)
      .to_return(status: 200, body: File.read('spec/fixtures/double-shot-characters.json'))
      expect(@me.end_character.name).to eq 'Avengers'
    end

    it 'should save the end character', :vcr do
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters\/1009351\/comics/)
      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
      stub_request(:get, /gateway.marvel.com\/v1\/public\/comics\/19843\/characters/)
      .to_return(status: 200, body: File.read('spec/fixtures/double-shot-characters.json'))
      @me.save
      f = Marshal.load File.read @me.config['marshal_file']
      expect(f.name).to eq 'Avengers'
    end

    it 'should generate correct yaml', :vcr do
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters\/1009351\/comics/)
      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
      stub_request(:get, /gateway.marvel.com\/v1\/public\/comics\/19843\/characters/)
      .to_return(status: 200, body: File.read('spec/fixtures/double-shot-characters.json'))
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters\/1009165/)
      .to_return(status: 200, body: File.read('spec/fixtures/spider-man.json'))
      @me.save
      @me.yamlise
      start_yaml = YAML.load File.open '%s/_data/start.yml' % @me.config['jekyll_dir']
      expect(start_yaml['name']).to eq 'Hulk'
      expect(start_yaml['image']['extension']).to eq 'jpg'

      end_yaml = YAML.load File.open '%s/_data/end.yml' % @me.config['jekyll_dir']
      expect(end_yaml['url']).to match /marvel.com\/universe/

      comic_yaml = YAML.load File.open '%s/_data/comic.yml' % @me.config['jekyll_dir']
      expect(comic_yaml['date']).to match /2003-02-10/
      expect(comic_yaml['title']).to match /Double Shot/
      expect(comic_yaml['image']['path']).to match /4c3649b0f2abd/
      expect(comic_yaml['series']['period']).to eq '2003'
    end

    it 'should generate a tweet message' do
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters/)
      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
      stub_request(:get, /gateway.marvel.com\/v1\/public\/comics/)
      .to_return(status: 200, body: File.read('spec/fixtures/double-shot-characters.json'))
      expect(@me.tweet_message).to eq 'In 2003, Hulk appeared in issue #2 of the 2003 run of Marvel Double Shot with Avengers'
    end

    it 'should generate a commit message' do
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters/)
      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
      stub_request(:get, /gateway.marvel.com\/v1\/public\/comics/)
      .to_return(status: 200, body: File.read('spec/fixtures/double-shot-characters.json'))
      expect(@me.commit_message).to eq 'Hulk -> Marvel Double Shot -> Avengers'
    end

    it 'should extract the year correctly', :vcr do
      c = Ultron::Comics.find '50372'
      expect(MarvelExplorer.get_year c).to eq 2014
    end

    it 'should rank correctly', :vcr do
      repopath = 'tmp/marvelexplorer'
      FileUtils.rm_rf repopath
      g = Git.clone 'https://github.com/marvelexplorer/marvelexplorer.github.io', repopath
      g.checkout 'af8bdcbda93eabb4c1c3eb989e4c9ad4a3d78539'

      expect(@me.ranking repo: repopath).to eq [
        ["Spider-Man", 13],
        ["X-Men", 13],
        ["Wolverine", 6],
        ["Fantastic Four", 5],
        ["Beast", 4]
      ]

      expect(@me.ranking repo: repopath, commits: 96).to eq [
        ["X-Men", 6],
        ["Spider-Man", 5],
        ["Colossus", 3],
        ["Fantastic Four", 3],
        ["Wolverine", 3]
        ]    
    end
  end
end
