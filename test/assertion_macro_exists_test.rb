require 'teststrap'

context "nil assertion:" do
  setup { Riot::Situation.new }

  asserts("result has a value") do
    Riot::Assertion.new("foo", topic) { "foo" }.exists
  end

  asserts("empty string is considered a value") do
    Riot::Assertion.new("foo", topic) { "" }.exists
  end

  should "raise a Failure if value is nil" do
    Riot::Assertion.new("foo", topic) { nil }.exists
  end.kind_of(Riot::Failure)
end # nil assertion
