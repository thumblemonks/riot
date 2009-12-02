require 'rubygems'
require 'rake'

task :default => [:test]

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs    << 'test'
  test.pattern =  'test/**/*_test.rb'
  test.warning =  true
  test.verbose =  false
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

desc "Stats on lines of code and test"
task :stats do
  loc = %x[find ./lib -name *.rb | xargs cat | wc -l].strip.to_i
  lotc = %x[find ./test -name *.rb | xargs cat | wc -l].strip.to_i
  total, ratio = (loc + lotc), (lotc / loc.to_f)

  fmt = "  Code: %d\n  Test: %d\n       -----\n Total: %d  Ratio (test/code): %f"
  puts fmt % [loc, lotc, loc + lotc, ratio]
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
    gem.add_dependency 'term-ansicolor'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end
