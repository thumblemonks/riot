require 'teststrap'

context "A size assertion macro" do
  setup do
    def assert_size(sizable, expected_size)
      Riot::Assertion.new("test") { sizable }.size(expected_size)
    end
  end

  assertion_test_passes("when string's size is as expected", "is of size 10") do
    assert_size("washington", 10)
  end
  assertion_test_passes("when string's size is in given range", "is of size 9..12") do
    assert_size("washington", 9..12)
  end

  assertion_test_fails("when string's size is not as expected", "size of \"washington\" expected to be 11 but is 10") do
    assert_size("washington", 11)
  end
  assertion_test_fails("when string's size is out of range", "size of \"washington\" expected to be 11..13 but is 10") do
    assert_size("washington", 11..13)
  end

  assertion_test_passes("when an array's size is as expected", "is of size 3") { assert_size([1, 2, 3], 3) }
  assertion_test_passes("when an array's size is in given range", "is of size 3..4") do
    assert_size([1, 2, 3], 3..4)
  end
  assertion_test_fails("when an array's size is not as expected", "size of [1, 2, 3] expected to be 2 but is 3") do
    assert_size([1, 2, 3], 2)
  end
  assertion_test_fails("when an array's size is out of range", "size of [1, 2, 3] expected to be 4..6 but is 3") do
    assert_size([1, 2, 3], 4..6)
  end

  assertion_test_passes("when a hash size is as expected", "is of size 1") do
    assert_size({:name => 'washington'}, 1)
  end
  assertion_test_passes("when a hash size is in range", "is of size 1...3") do
    assert_size({:name => 'washington'}, 1...3)
  end
  assertion_test_fails("when a hash size is not as expected", "size of {} expected to be 2 but is 0") do
    assert_size({}, 2)
  end
  assertion_test_fails("when a hash size is out of range", "size of {} expected to be 2...4 but is 0") do
    assert_size({}, 2...4)
  end
end
