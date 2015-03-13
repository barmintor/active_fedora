require 'rake/clean'
require 'bundler'

Bundler::GemHelper.install_tasks

# load rake tasks defined in lib/tasks that are not loaded in lib/active_fedora.rb
load "lib/tasks/active_fedora_dev.rake"

CLEAN.include %w[**/.DS_Store tmp *.log *.orig *.tmp **/*~]
ZIP_URL='https://github.com/dpla/marmotta-jetty/archive/3.3.0-solr-4.9.0.zip'
task :ci => ['jetty:clean', 'active_fedora:ci']
task :spec => ['active_fedora:rspec']
task :rcov => ['active_fedora:rcov']


task :default => [:ci]
