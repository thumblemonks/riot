
require 'teststrap'

context "An empty assertion macro" do
    setup do
      def assert_empty(string)
        Riot::Assertion.new("test") { string }.empty
      end
    end
    assertion_test_passes("when string is empty") { assert_empty("") }
    assertion_test_fails("when string has content","expected   to be empty") { assert_empty(" ") }
    assertion_test_passes("when an array is empty") { assert_empty([]) }
    assertion_test_fails("when an array has items","expected [1] to be empty") { assert_empty([1]) }
    assertion_test_passes("when a hash is empty") { assert_empty({}) }
    assertion_test_fails("when a hash has items","expected {:name=>\"washington\"} to be empty") do
      assert_empty({:name => 'washington'})
    end
end
