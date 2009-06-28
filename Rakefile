require 'rubygems'
require 'rake'

task :default => [:test]

desc "Run tests"
task :test do
  $:.concat ['./test', './lib']
  Dir.glob("./test/*_test.rb").each { |test| require test }
  Protest.run
end
