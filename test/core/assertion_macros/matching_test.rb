require 'teststrap'

context "A matching assertion macro" do
  setup { Riot::Assertion.new("foo") { "abc" } }

  assertion_test_passes("when expression matches actual", %Q{matches /abc/}) { topic.matches(/abc/) }

  assertion_test_fails("when expression fails to match", "expected /abcd/ to match \"abc\"") do
    topic.matches(/abcd/)
  end

  context "with integer based topic" do
    setup { Riot::Assertion.new("foo") { 42 } }

    assertion_test_passes("actual value converted to string", %Q{matches /^42$/}) do
      topic.matches(/^42$/)
    end

    assertion_test_fails("actual value converted to string", %Q{expected /^52$/ to match 42}) do
      topic.matches(/^52$/)
    end
  end

end # A matching assertion macro
