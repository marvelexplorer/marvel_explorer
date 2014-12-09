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
  end
end
