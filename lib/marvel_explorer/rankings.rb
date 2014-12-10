module MarvelExplorer
  class Explorer
    def calculate_rankings params
      params = { commits: 35040, repo: @config['jekyll_dir'], limit: 5 }.merge params
      g = Git.open params[:repo]

      counts = Hash.new(0)

      g.log(params[:commits])
      .select{ |c| c.message =~ /\->/ }
      .map { |c| /(.*) -> (.*) -> (.*)/.match(c.message)[1] }
      .each { |c| counts[c] += 1 }

      counts.sort_by { |k, v| v }.reverse
      .map { |k, v| { 'name' => k, 'score' => v } }[0...params[:limit]]
    end

    def rankings params = {}
      FileUtils.mkdir_p '%s/_data/' % @config['jekyll_dir']
      y = File.open '%s/_data/rankings_%d.yml' % [
        @config['jekyll_dir'],
        params[:commits],
      ], 'w'

      y.write calculate_rankings(params).to_yaml
      y.close
    end
  end
end
