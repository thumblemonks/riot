$:.concat ['./lib']
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
Riot.silently! # Do this before any contexts are defined

context "a room" do
  setup { @room = Room.new("bed") }

  asserts("name") { @room.name }.equals("bed")
end # a room
 
#
# Test::Unit

require 'test/unit'
Test::Unit.run = false

require 'test/unit/ui/console/testrunner'

class RoomTest < Test::Unit::TestCase
  def setup
    @room = Room.new("bed")
  end

  def test_room_should_be_named_bed
    assert_equal "bed", @room.name
  end
end

#
# Shoulda

require 'rubygems'
require 'shoulda'

class ShouldaRoomTest < Test::Unit::TestCase
  def setup
    @room = Room.new("bed")
  end

  should("be named 'bed'") { assert_equal "bed", @room.name }
end

#
# Benchmarking

n = 100 * 100

Benchmark.bmbm do |x|
  x.report("Riot") do
    n.times { Riot.report }
  end

  x.report("Test::Unit") do
    n.times { Test::Unit::UI::Console::TestRunner.new(RoomTest, Test::Unit::UI::SILENT) }
  end

  x.report("Shoulda") do
    n.times { Test::Unit::UI::Console::TestRunner.new(ShouldaRoomTest, Test::Unit::UI::SILENT) }
  end
end

