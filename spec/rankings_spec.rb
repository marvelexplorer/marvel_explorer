require 'spec_helper'

module MarvelExplorer
  describe Explorer do
    before :each do
      @me = Explorer.new 'config.yml'

      @repopath = 'tmp/marvelexplorer'
      unless File.exists? '%s/index.html' % @repopath
        FileUtils.rm_rf @repopath
        g = Git.clone 'https://github.com/marvelexplorer/marvelexplorer.github.io', @repopath
        g.checkout 'af8bdcbda93eabb4c1c3eb989e4c9ad4a3d78539'
      end
    end

    it 'should rank correctly', :vcr do
      expect(@me.ranking repo: @repopath).to eq [
        { 'name' => 'Spider-Man', 'score' => 13 },
        { 'name' => 'X-Men', 'score' => 13 },
        { 'name' => 'Wolverine', 'score' => 6 },
        { 'name' => 'Fantastic Four', 'score' => 5 },
        { 'name' => 'Beast', 'score' => 4 }
      ]

      expect(@me.ranking repo: @repopath, commits: 96).to eq [
        { 'name' => 'X-Men', 'score' => 6 },
        { 'name' => 'Spider-Man', 'score' => 5 },
        { 'name' => 'Colossus', 'score' => 3 },
        { 'name' => 'Fantastic Four', 'score' => 3 },
        { 'name' => 'Wolverine', 'score' => 3 }
      ]

      expect(@me.ranking repo: @repopath, commits: 1). to eq [
        { 'name' => 'Cable', 'score' => 1 }
      ]

      expect(@me.ranking repo: @repopath, commits: 672, limit: 10). to eq [
        { 'name' => 'Spider-Man', 'score' => 13 },
        { 'name' => 'X-Men', 'score' => 13 },
        { 'name' => 'Wolverine', 'score' => 6 },
        { 'name' => 'Fantastic Four', 'score' => 5 },
        { 'name' => 'Beast', 'score' => 4 },
        { 'name' => 'Colossus', 'score' => 4 },
        { 'name' => 'Havok', 'score' => 4 },
        { 'name' => 'Gambit', 'score' => 3 },
        { 'name' => 'Rogue', 'score' => 3 },
        { 'name' => 'Polaris', 'score' => 3 }
      ]
    end

    it 'should write ranking yaml', :vcr do
      @me.record_rankings repo: @repopath, commits: 96
      yaml = YAML.load File.read '%s/_data/rankings_96.yml' % @me.config['jekyll_dir']
      expect(yaml[0]['name']).to eq 'X-Men'
    end
  end
end
