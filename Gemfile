source "http://rubygems.org"

# Specify your gem's dependencies in gsolr.gemspec
gemspec

group :benchmark do
  gem 'excon'
  gem 'rest-client'
  gem 'streamly' if RUBY_ENGINE == "ruby"
  gem 'curb' if RUBY_ENGINE == "ruby"
  gem 'excon'
end

group :test do
  gem 'rspec'
  gem 'rspec-core'
  gem 'sinatra'
end
