require 'teststrap'

context "An exists assertion macro" do
  helper(:assert_exists) do |o|
    Riot::Assertion.new("test") { o }.exists.run(Riot::Situation.new)
  end

  asserts(":pass when result has a value") do
    assert_exists("foo")
  end.equals([:pass, "does exist"])

  asserts(":pass because empty string is considered a value") do
    assert_exists("")
  end.equals([:pass, "does exist"])

  asserts(":fail with message when value is nil") do
    assert_exists(nil)[0..1]
  end.equals([:fail, "expected a non-nil value"])
end # An exists assertion macro

context "A negative exists assertion macro" do
  helper(:assert_exists) do |o|
    Riot::Assertion.new("test", true) { o }.exists.run(Riot::Situation.new)
  end
  
  asserts(":fail when string") do
    assert_exists("foo")[0..1]
  end.equals([:fail, "expected a nil value"])

  asserts ":fail when string empty" do 
    assert_exists("")[0..1]
  end.equals([:fail, "expected a nil value"])

  asserts(":pass when nil") do 
    assert_exists(nil)
  end.equals([:pass, "does exist"])
  
end # A negative exists assertion macro
