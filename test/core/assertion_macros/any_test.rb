require 'teststrap'

context "An any assertion macro" do
  helper(:assert_any) do |o|
    Riot::Assertion.new("test") { o }.any
  end

  assertion_test_passes("when an array has items", "has items") { assert_any([1]) }
  assertion_test_fails("when an array is empty", "expected [] to have items") do
    assert_any([])
  end

  assertion_test_passes("when a hash has items", "has items") { assert_any({:name => 'washington'}) }
  assertion_test_fails("when a hash is empty", "expected {} to have items") do
    assert_any({})
  end
end

context "A negative, any assertion macro" do
  helper(:any) do |o|
    Riot::Assertion.new("test", true) { o }.any
  end

  asserts(":error when value is nil") do
    any(nil).run(Riot::Situation.new)[0] # No method any? on nil
  end.equals(:error)

  asserts(":pass when string is empty") do
    any("").run(Riot::Situation.new)
  end.equals([:pass, "has items"])

  asserts(":pass when array is empty") do
    any([]).run(Riot::Situation.new)
  end.equals([:pass, "has items"])

  asserts(":pass when hash is empty") do
    any({}).run(Riot::Situation.new)
  end.equals([:pass, "has items"])

  asserts(":fail when string is empty") do
    any("foo").run(Riot::Situation.new)[0..1]
  end.equals([:fail, %Q{expected "foo" not to have items}])

  asserts(":fail when array has items") do
    any([1,2]).run(Riot::Situation.new)[0..1]
  end.equals([:fail, %Q{expected [1, 2] not to have items}])

  asserts(":fail when hash has items") do
    any({"bar" => "baz"}).run(Riot::Situation.new)[0..1]
  end.equals([:fail, %Q{expected {"bar"=>"baz"} not to have items}])
end
