lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'salesforce_streamer/version'

Gem::Specification.new do |spec|
  spec.name = 'salesforce_streamer'
  spec.version = SalesforceStreamer::VERSION
  spec.authors = ['Scott Serok', 'RenoFi Engineering Team']
  spec.email = ['scott@renofi.com', 'engineering@renofi.com']

  spec.summary = 'A wrapper around the Restforce Streaming API with a built-in PushTopic manager.'
  spec.homepage = 'https://github.com/renofi/salesforce_streamer'
  spec.license = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['documentation_uri'] = 'https://www.rubydoc.info/gems/salesforce_streamer'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(bin/|spec/|\.rub)}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'cookiejar', '~> 0.3.0'
  spec.add_dependency 'dry-initializer', '~> 3.0'
  spec.add_dependency 'faye', '~> 1.4'
  spec.add_dependency 'restforce', '~> 5.0'
  # # When you have issues installing eventmachine on osx and ruby 3, try:
  # gem install eventmachine -- --with-openssl-dir=/usr/local/opt/openssl@1.1
  spec.add_dependency 'eventmachine', '~> 1.2'

  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
end
