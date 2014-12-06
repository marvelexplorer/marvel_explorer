# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marvel_explorer/version'

Gem::Specification.new do |spec|
  spec.name          = 'marvel_explorer'
  spec.version       = MarvelExplorer::VERSION
  spec.authors       = ['pikesley']
  spec.email         = ['sam@pikesley.org']
  spec.summary       = %q{Wander around the Marvel Comics data}
  spec.description   = %q{}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = 'marvel_explorer'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'ultron', '~> 0.1'
  spec.add_dependency 'twitter', '~> 5.13'
  spec.add_dependency 'dotenv', '~> 0.11'
  spec.add_dependency 'git', '~> 1.2'
  spec.add_dependency 'thor', '~> 0.19m '

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'guard-rspec', '~> 4.4'
  spec.add_development_dependency 'terminal-notifier-guard'
  spec.add_development_dependency 'vcr', '~> 2.9'
  spec.add_development_dependency 'webmock', '~> 1.20'
  spec.add_development_dependency 'timecop', '~> 0.7'
end
