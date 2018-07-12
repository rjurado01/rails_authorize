lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rails_authorize/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails_authorize'
  spec.version       = RailsAuthorize::VERSION
  spec.authors       = ['rjurado01']
  spec.email         = ['rjurado01@gmail.com']

  spec.summary       = 'Simple and flexible authorization Rails system'
  spec.description   = 'Authorization system for Rails with only few helpers and regular Ruby classes.'
  spec.homepage      = 'https://github.com/rjurado01/rails_authorize'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
