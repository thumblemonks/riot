require 'teststrap'

context "A not! assertion macro" do
  helper(:assert_not!) { |o| Riot::Assertion.new("foo") { o }.not! }

  assertion_test_passes("when value is false", "does exist ... not!") { assert_not!(false) }
  assertion_test_passes("when value is nil", "does exist ... not!")   { assert_not!(nil)   }
  assertion_test_fails("when value is not nil or false", "expected to exist ... not!") do
    assert_not!("funny")
  end
end # A not! assertion macro

context "A negative not! assertion macro" do
  helper(:assert_not_not!) { |o| Riot::Assertion.new("foo", true) { o }.not! }
  
  assertion_test_fails("when value is false", "expected to not exist ... not!") { assert_not_not!(false)   }
  assertion_test_fails("when value is nil", "expected to not exist ... not!")   { assert_not_not!(nil)     }
  assertion_test_passes("when value is not nil or false", "does not exist ... not!") do 
    assert_not_not!('borat')
  end
end # A negative not! assertion macro