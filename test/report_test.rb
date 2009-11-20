require 'teststrap'
require 'stringio'

context "IOReporter" do
  context "with writer" do
    setup do
      @writer = StringIO.new
      Riot::IOReporter.new(@writer)
    end

    asserts("prints to writer") do
      topic.update('description',[:pass])
      @writer.string
    end.equals(".")
  end
end
