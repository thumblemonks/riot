require 'rubygems'
require 'rake'

task :default => ["test:all"]
task "test:all" => ["test:core", "test:extensions"]

require 'rake/testtask'
Rake::TestTask.new("test:core") do |test|
  test.libs    << 'test'
  test.pattern =  'test/core/**/*_test.rb'
  test.warning =  true
  test.verbose =  false
end

Rake::TestTask.new("test:extensions") do |test|
  test.libs    << 'test'
  test.pattern =  'test/extensions/*_test.rb'
  test.warning =  true
  test.verbose =  false
end

#
# Benchmarks

def run_benchmarks(bin)
  Dir["test/benchmark/*.rb"].each do |file|
    puts ">> Running #{file}"
    puts %x[#{bin} #{file}]
  end
end

desc "Run all of them fancy benchmarks, Howard!"
task("test:benchmarks") { run_benchmarks("ruby") }

#
# YARDie

begin
  require 'yard'
  require 'yard/rake/yardoc_task'
  YARD::Rake::YardocTask.new do |t|
    extra_files = %w(MIT-LICENSE)
    t.files = ['lib/**/*.rb']
    t.options = ["--files=#{extra_files.join(',')}"]
  end
rescue LoadError
  # YARD isn't installed
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
    gem.add_dependency 'rr'
    gem.add_dependency 'term-ansicolor'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end
