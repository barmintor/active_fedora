require 'rake/clean'
require 'rubygems'
load 'tasks/rspec.rake'
load 'tasks/active_fedora.rake'

$: << 'lib'


begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "active-fedora"
    gem.summary = %Q{A convenience libary for manipulating MODS (Metadata Object Description Schema) documents.}
    gem.description = %Q{ActiveFedora provides for creating and managing objects in the Fedora Repository Architecture.}
    gem.email = "matt.zumwalt@yourmediashelf.com"
    gem.homepage = "http://yourmediashelf.com/activefedora"
    gem.authors = ["Matt Zumwalt", "McClain Looney"]
    gem.rubyforge_project = 'rubyfedora'
    gem.add_dependency('solr-ruby', '>= 0.0.6')
    gem.add_dependency('xml-simple', '>= 1.0.12')
    gem.add_dependency('mime-types', '>= 1.16')
    gem.add_dependency('multipart-post')
    gem.add_dependency('nokogiri')
    gem.add_dependency('om', '>= 1.0')
    gem.add_dependency('solrizer', '1.0.3')
    gem.add_dependency("activeresource")
    gem.add_dependency("mediashelf-loggable")
    gem.add_dependency("equivalent-xml")
    gem.add_dependency("facets")
    gem.add_development_dependency("yard")
    gem.add_development_dependency("RedCloth")
    gem.add_development_dependency("rcov")
    gem.add_development_dependency("solrizer")
    gem.add_development_dependency("solrizer-fedora")
    gem.add_development_dependency("jettywrapper")
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
  # Jeweler::RubyforgeTasks.new 
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

CLEAN.include %w[**/.DS_Store tmp *.log *.orig *.tmp **/*~]

task :default => [:spec]
