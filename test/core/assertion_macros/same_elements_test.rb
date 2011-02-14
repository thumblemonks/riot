require 'teststrap'

context "A same_elements assertion macro" do
  setup { Riot::Assertion.new("test") { ["foo", "bar", 69] } }

  assertion_test_passes(%Q{when [69, "foo", "bar"] are returned},%Q{has same elements as [69, "foo", "bar"]}) do
    topic.same_elements([69, "foo", "bar"])
  end

  assertion_test_passes(%Q{when [69, "foo", "bar"] are returned in any order},%Q{has same elements as ["foo", "bar", 69]}) do
    topic.same_elements(["foo", "bar", 69])
  end

  assertion_test_fails("when elements do not match", %Q{expected elements ["foo", "bar", 96] to match ["foo", "bar", 69]}) do
    topic.same_elements(["foo", "bar", 96])
  end
end # A same_elements assertion macro

context "A negative same_elements assertion macro" do
  setup { Riot::Assertion.new("test", true) { ["foo","bar", 69] } }
  
  assertion_test_fails("when elements match", %Q{expected elements [69, "foo", "bar"] not to match ["foo", "bar", 69]}) do
    topic.same_elements([69, "foo", "bar"])
  end

  assertion_test_fails("when any elements match", %Q{expected elements ["foo", "bar", 69] not to match ["foo", "bar", 69]}) do
    topic.same_elements(["foo", "bar", 69])
  end

  assertion_test_passes("when elements do not match",%Q{has same elements as ["foo", "bar", 96]}) do
    topic.same_elements(["foo", "bar", 96])
  end
  
end # A negative same_elements macro
