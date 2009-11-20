require 'teststrap'
require 'stringio'

context "TextReport" do
  context "with writer" do
    setup do
      @writer = StringIO.new
      Riot::IOReporter.new(@writer)
    end

    asserts("prints to writer") do
      topic.passed
      @writer.string
    end.equals(".")
  end
end
