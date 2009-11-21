require 'teststrap'

context "A matching assertion macro" do
  setup { Riot::Assertion.new("foo") { "abc" } }

  assertion_test_passes("when expression matches actual") { topic.matches(/abc/) }
  assertion_test_fails("when expression fails to match", "expected /abcd/ to match \"abc\"") do
    topic.matches(/abcd/)
  end
end # A matching assertion macro
