source 'https://rubygems.org'

# Specify your gem's dependencies in pact.gemspec
gemspec

group :test do
  gem 'faraday', '~> 2.0'
  gem 'faraday-retry', '~> 2.0'
  gem 'webrick', '~> 1.9.1'
  if ENV['RACK_VERSION'] == '2'
    gem 'rack', '>= 2.0', '< 3.0'
  else
    gem 'rack', '>= 3.0', '< 4.0'
    gem 'rackup', '~> 2.0'
  end
end
