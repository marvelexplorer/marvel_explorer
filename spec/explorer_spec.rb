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

    it 'should extract the year correctly', :vcr do
      c = Ultron::Comics.find '50372'
      expect(MarvelExplorer.get_year c).to eq 2014
    end
  end
end
