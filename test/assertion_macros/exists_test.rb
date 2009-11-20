require 'teststrap'

context "An exists assertion macro" do
  setup { Riot::Situation.new }

  asserts(":pass when result has a value") do
    Riot::Assertion.new("foo") { "foo" }.exists.run(topic)
  end.equals([:pass])

  asserts(":pass because empty string is considered a value") do
    Riot::Assertion.new("foo") { "" }.exists.run(topic)
  end.equals([:pass])

  asserts(":fail with message when value is nil") do
    Riot::Assertion.new("foo") { nil }.exists.run(topic)
  end.equals([:fail, "expected a non-nil value"])
end # An exists assertion macro
