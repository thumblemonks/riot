require 'teststrap'

context "A respond_to assertion macro" do
  setup { Riot::Assertion.new("foo") { "bar" } }

  assertion_test_passes("when method is defined", "responds to :each_byte") { topic.respond_to(:each_byte) }
  assertion_test_passes("using responds_to alias", "responds to :length")   { topic.responds_to(:length)   }

  assertion_test_fails("when method not defined", "expected method :goofballs is not defined") do
    topic.respond_to(:goofballs)
  end

end # A respond_to assertion macro

context "A negative respond_to assertion macro" do
  setup { Riot::Assertion.new("foo", true) { "bar" } }
  
  assertion_test_fails("when method is defined", "expected method :each_byte is defined") do
    topic.respond_to(:each_byte)
  end
  
  assertion_test_fails("using responds_to alias", "expected method :length is defined") do
    topic.responds_to(:length)
  end
  
  assertion_test_passes("when method is not defined", "responds to :goofballs") do
    topic.respond_to(:goofballs)
  end
  
end
