require 'teststrap'

context "equals assertion:" do
  setup { Riot::Situation.new }

  asserts "result equals expectation" do
    Riot::Assertion.new("i will pass", topic) { "foo bar" }.equals("foo bar")
  end

  should "raise a Failure if results don't equal each other" do
    Riot::Assertion.new("failure", topic) { "bar" }.equals("foo")
  end.kind_of(Riot::Failure)
end # equals assertion
