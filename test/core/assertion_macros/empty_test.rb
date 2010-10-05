require 'teststrap'

context "An empty assertion macro" do
  helper(:assert_empty) do |o|
    Riot::Assertion.new("test") { o }.empty
  end

  assertion_test_passes("when string is empty", "is empty") { assert_empty("") }
  assertion_test_fails("when string has content", "expected \" \" to be empty") do
    assert_empty(" ")
  end

  assertion_test_passes("when an array is empty", "is empty") { assert_empty([]) }
  assertion_test_fails("when an array has items", "expected [1] to be empty") do
    assert_empty([1])
  end

  assertion_test_passes("when a hash is empty", "is empty") { assert_empty({}) }
  assertion_test_fails("when a hash has items", "expected {:name=>\"washington\"} to be empty") do
    assert_empty({:name => 'washington'})
  end
end

context "A negative empty assertion macro" do
  helper(:assert_empty) do |o|
    Riot::Assertion.new("test", true) { o }.empty.run(Riot::Situation.new)
  end

  asserts("when string is not empty") do
    assert_empty("foo")
  end.equals([:pass, "is empty"])

  asserts("when string is empty") do
    assert_empty("")[0..1]
  end.equals([:fail, "expected to not be empty"])

  asserts("when array is not empty") do
    assert_empty([1])
  end.equals([:pass, "is empty"])

  asserts("when array is empty") do
    assert_empty([])[0..1]
  end.equals([:fail, "expected to not be empty"])

  asserts("when hash is not empty") do
    assert_empty({:boo => "blux"})
  end.equals([:pass, "is empty"])

  asserts("when hash is empty") do
    assert_empty({})[0..1]
  end.equals([:fail, "expected to not be empty"])
end # A negative empty assertion macro
