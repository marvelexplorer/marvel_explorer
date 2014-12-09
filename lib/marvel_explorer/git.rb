module MarvelExplorer
  class Explorer
    def commit_message
      '%s -> %s -> %s' % [
        yamls['start']['name'],
        yamls['comic']['series']['name'],
        yamls['end']['name']
      ]
    end

    def commit
      g = Git.open @config['jekyll_dir']

      g.add '.'
      g.commit commit_message
      g.push(g.remote('origin'))
    end
  end
end
