require 'teststrap'

context "respond_to assertion:" do
  setup { Riot::Situation.new }

  asserts "specific result quacks kind of like a String" do
    Riot::Assertion.new("foo", topic) { "a" }.respond_to(:to_s)
  end

  should "raise a Failure if does not quack enough like a duck for you" do
    Riot::Assertion.new("foo", topic) { 0 }.respond_to(:split)
  end.kind_of(Riot::Failure)
end # respond_to assertion