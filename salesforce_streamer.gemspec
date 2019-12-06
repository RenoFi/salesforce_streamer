lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'salesforce_streamer/version'

Gem::Specification.new do |spec|
  spec.name          = 'salesforce_streamer'
  spec.version       = SalesforceStreamer::VERSION
  spec.authors       = ['Scott Serok']
  spec.email         = ['scott@renofi.com']

  spec.summary       = 'A wrapper around the Restforce Streaming API with a built-in PushTopic manager.'
  spec.homepage      = 'https://github.com/renofi/salesforce_streamer'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faye'
  spec.add_dependency 'restforce', '~> 4.2'

  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
end
