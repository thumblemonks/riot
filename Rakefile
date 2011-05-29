require 'bundler'
Bundler::GemHelper.install_tasks

task :default   => ["test:all"]
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

