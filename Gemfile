source "https://rubygems.org"

# Bundler will rely on active-fedora.gemspec for dependency information.

gemspec path: File.expand_path('..', __FILE__)

gem 'byebug' unless ENV['TRAVIS']

group :test do
  gem 'simplecov', require: false
  gem 'coveralls', require: false
end

gem 'jruby-openssl', platform: :jruby
gem 'ldp', git: 'https://github.com/barmintor/ldp.git', branch: 'lyo-compat'
