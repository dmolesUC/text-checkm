Gem::Specification.new do |spec|
  spec.name = 'rcheckm'
  spec.version = '0.0.1'
  spec.authors = ['David Moles']
  spec.email = ['dmoles@berkeley.edu']
  spec.summary = 'Ruby implementation of the Checkm manifest format'
  spec.description = 'A Ruby implementation of the Checkm checksum-based manifest format'
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/dmolesUC/rcheckm'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }

  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundle-audit'
  spec.add_development_dependency 'ci_reporter_rspec'
  spec.add_development_dependency 'colorize'
  spec.add_development_dependency 'irb' # workaroundfor https://github.com/bundler/bundler/issues/6929
  spec.add_development_dependency 'listen', '>= 3.0.5', '< 3.2'
  spec.add_development_dependency 'rake', '>= 13.0'
  spec.add_development_dependency 'rspec-support'
  spec.add_development_dependency 'rubocop', '0.86'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
  spec.add_development_dependency 'simplecov-rcov'
end
