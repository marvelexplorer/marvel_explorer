require 'spec_helper'

module MarvelExplorer
  describe Explorer do
    before :each do
      Timecop.freeze '2014-12-03T19:01:00+00:00'
      FileUtils.rm_rf 'tmp/*'
      @me = Explorer.new 'config.yml'
    end

    after :each do
      Timecop.return
    end

    it 'should get the default start character', :vcr do
      @me.config['marshal_file'] = '/dev/null'
      expect(@me.start_character.name).to eq 'Hulk'
    end

    it 'should load the stored character', :vcr do
      expect(@me.start_character.name).to eq 'Avengers'
    end

    it 'should select a comic for the start character', :vcr do
      @me.config['marshal_file'] = '/dev/null'
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters\/1009351\/comics/)
      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
      expect(@me.comic.title).to eq 'Marvel Double Shot (2003) #2'
    end

    it 'should get the end character from the comic', :vcr do
      @me.config['marshal_file'] = '/dev/null'
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

      expect(File).to exist 'tmp/cached_characters/1009165'
    end
  end
end
