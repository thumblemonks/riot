require 'rubygems'
require 'rake'

task :default => [:test]

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false
end

desc "Run Flog against library (except tests)"
task :flog do
  puts %x[find ./lib -name *.rb | xargs flog]
end

desc "Run Flay against library (except tests)"
task :flay do
  puts %x[find ./lib -name *.rb | xargs flay]
end

desc "Run Roodi against library (except tests)"
task :roodi do
  puts %x[find ./lib -name *.rb | xargs roodi]
end

#
# Some monks like diamonds. I like gems.

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "riot"
    gem.summary = "An extremely fast, expressive, and context-driven unit-testing framework. Protest the slow test."
    gem.description = "An extremely fast, expressive, and context-driven unit-testing framework. A replacement for all other testing frameworks. Protest the slow test."
    gem.email = "gus@gusg.us"
    gem.homepage = "http://github.com/thumblemonks/riot"
    gem.authors = ["Justin 'Gus' Knowlden"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end
