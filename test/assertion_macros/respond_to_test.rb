require 'teststrap'

context "A respond_to assertion macro" do
  setup { Riot::Assertion.new("foo") { "bar" } }

  assertion_test_passes("when method is defined", "responds to :each_byte") { topic.respond_to(:each_byte) }

  assertion_test_fails("when method not defined", "expected method :goofballs is not defined") do
    topic.respond_to(:goofballs)
  end

end # A respond_to assertion macro
