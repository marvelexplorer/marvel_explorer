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

    it 'should generate a tweet message' do
      stub_request(:get, /gateway.marvel.com\/v1\/public\/characters/)
      .to_return(status: 200, body: File.read('spec/fixtures/hulk_comics.json'))
      stub_request(:get, /gateway.marvel.com\/v1\/public\/comics/)
      .to_return(status: 200, body: File.read('spec/fixtures/double-shot-characters.json'))
      expect(@me.tweet_message).to eq 'In 2003, Hulk appeared in Marvel Double Shot #2 with Avengers'
    end
  end
end
