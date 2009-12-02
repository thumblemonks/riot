require 'rubygems'
require 'benchmark'
require 'colorize'
require 'term/ansicolor'

class MyString < String
  include ::Term::ANSIColor
end

colorize = String.new
term_ansicolor = MyString.new

n = 50_000

Benchmark.bmbm do |x|
  x.report("colorize") do
    n.times do
      colorize.green
      colorize.yellow
      colorize.red
    end
  end
  x.report("term-ansicolor") do
    n.times do
      term_ansicolor.green
      term_ansicolor.yellow
      term_ansicolor.red
    end
  end
end

# Rehearsal --------------------------------------------------
# colorize         4.140000   0.160000   4.300000 (  4.375765)
# term-ansicolor   0.720000   0.000000   0.720000 (  0.730665)
# ----------------------------------------- total: 5.020000sec
# 
#                      user     system      total        real
# colorize         4.070000   0.170000   4.240000 (  4.459804)
# term-ansicolor   0.700000   0.000000   0.700000 (  0.728494)
