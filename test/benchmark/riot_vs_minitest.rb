$:.unshift(File.dirname(__FILE__) + "/../../lib")
require 'benchmark'

#
# Model

class Room
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

#
# Riot

require 'riot'

context "a room" do
  setup { Room.new("bed") }

  asserts("name") { topic.name }.equals("bed")
end # a room

#
# MiniTest::Unit

require 'rubygems'
require 'minitest/unit'

class RoomTest < MiniTest::Unit::TestCase
  def setup
    @room = Room.new("bed")
  end

  def test_room_should_be_named_bed
    assert_equal "bed", @room.name
  end
end

#
# Benchmarking

n = 100 * 100

Benchmark.bmbm do |x|
  x.report("Riot") do
    Riot.silently!
    Riot.alone!
    n.times { Riot.run }
  end

  x.report("MiniTest") do
    n.times { RoomTest.new("Blah").run(MiniTest::Unit.new) }
  end
end

