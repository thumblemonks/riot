require 'teststrap'

context "A nil assertion macro" do
  setup { Riot::Situation.new }

  asserts(":pass when result is nil") do
    Riot::Assertion.new("foo") { nil }.nil.run(topic)
  end.equals([:pass])

  asserts(":fail with message") do
    Riot::Assertion.new("foo") { "a" }.nil.run(topic)
  end.equals([:fail, %Q{expected nil, not "a"}])
end # A nil assertion macro
