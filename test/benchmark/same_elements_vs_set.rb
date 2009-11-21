require 'benchmark'

#
# Benchmarking

n = 100 * 100

Benchmark.bmbm do |x|
  x.report("Set theory") do
    require 'set'
    def set_theory(expected, actual)
      a = Set.new(expected)
      b = Set.new(actual)
      a == b
    end

    n.times do
      array = ["a", 1, {:foo => :bar}]
      set_theory(array, array.reverse)
    end
  end

  x.report("same_elements from shoulda (sorta)") do
    def same_elements(a1, a2)
      [:select, :inject, :size].each do |m|
        [a1, a2].each { |a| a.respond_to?(m) || return }
      end

      a1h = a1.inject({}) { |h,e| h[e] = a1.select { |i| i == e }.size; h }
      a2h = a2.inject({}) { |h,e| h[e] = a2.select { |i| i == e }.size; h }

      a1h == a2h
    end

    n.times do
      array = ["a", 1, {:foo => :bar}]
      same_elements(array, array.reverse)
    end
  end
end

