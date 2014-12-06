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
      @me.config['MARSHAL_FILE'] = 'not_a_path'
      expect(@me.start_character.name).to eq 'Hulk'
    end

    it 'should load the stored character', :vcr do
      expect(@me.start_character.name).to eq 'Avengers'
    end

    it 'should select a comic for the start character', :vcr do
      @me.config['MARSHAL_FILE'] = 'not_a_path'
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters\/1009351\/comics/)
      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
      expect(@me.comic.title).to eq 'Marvel Double Shot (2003) #2'
    end

    it 'should get the end character from the comic', :vcr do
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters\/1009165\/comics/)
      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
      stub_request(:get, /gateway.marvel.com\/v1\/public\/comics\/19843\/characters/)
      .to_return(status: 200, body: File.read('spec/fixtures/double-shot-characters.json'))
      expect(@me.end_character.name).to eq 'Avengers'
    end

    it 'should save the end character', :vcr do
    #  @me.config['MARSHAL_FILE'] = 'not_a_path'
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters\/1009351\/comics/)
      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
      stub_request(:get, /gateway.marvel.com\/v1\/public\/comics\/19843\/characters/)
      .to_return(status: 200, body: File.read('spec/fixtures/double-shot-characters.json'))
      @me.save
      f = Marshal.load File.read @me.config['MARSHAL_FILE']
      expect(f.name).to eq 'Avengers'
    end

#    it 'should generate correct yaml', :vcr do
#      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters/)
#      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
#      stub_request(:get, /gateway.marvel.com\/v1\/public\/comics/)
#      .to_return(status: 200, body: File.read('spec/fixtures/double-shot-characters.json'))
#      @me.yamlise
#      start_yaml = YAML.load File.open '%s/_data/start.yml' % @me.config['JEKYLL_DIR']
#      expect(start_yaml['name']).to eq 'Captain America'
#      expect(start_yaml['image']['extension']).to eq 'jpg'
#
#      end_yaml = YAML.load File.open '%s/_data/end.yml' % @me.config['JEKYLL_DIR']
#      expect(end_yaml['url']).to match /marvel.com\/universe/
#
#      comic_yaml = YAML.load File.open '%s/_data/comic.yml' % @me.config['JEKYLL_DIR']
#      expect(comic_yaml['date']).to match /2003-02-10/
#      expect(comic_yaml['title']).to match /Double Shot/
#      expect(comic_yaml['image']['path']).to match /4c3649b0f2abd/
#      expect(comic_yaml['series']['period']).to eq '2003'
#    end

#    it 'should generate a tweet message' do
#      require 'pry'
#      binding.pry
#      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters/)
#      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
#      stub_request(:get, /gateway.marvel.com\/v1\/public\/comics/)
#      .to_return(status: 200, body: File.read('spec/fixtures/double-shot-characters.json'))
#      expect(@me.tweet_message).to eq 'In 2003, Captain America appeared in issue #2 of the 2003 run of Marvel Double Shot with Avengers'
#    end

    it 'should generate a commit message' do
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters/)
      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
      stub_request(:get, /gateway.marvel.com\/v1\/public\/comics/)
      .to_return(status: 200, body: File.read('spec/fixtures/double-shot-characters.json'))
      expect(@me.commit_message).to eq 'Avengers -> Fantastic Four Annual -> Invisible Woman'
    end

    it 'should extract the year correctly', :vcr do
      c = Ultron::Comics.find '50372'
      expect(MarvelExplorer.get_year c).to eq 2014
    end
  end
end

def stubbify
  stub_request(:get, /gateway.marvel.com\/v1\/public\/characters\/1009220\/comics/)
  .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
  stub_request(:get, /gateway.marvel.com\/v1\/public\/comics\/19843\/characters/)
  .to_return(status: 200, body: File.read('spec/fixtures/double-shot-characters.json'))
end