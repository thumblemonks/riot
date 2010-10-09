require 'teststrap'

context "A size assertion macro" do
  helper(:assert_size) { |sizable, expected_size| Riot::Assertion.new("test") { sizable }.size(expected_size) }

  assertion_test_passes("when string's size is as expected", "is of size 10") do
    assert_size("washington", 10)
  end
  assertion_test_passes("when string's size is in given range", "is of size 9..12") do
    assert_size("washington", 9..12)
  end

  assertion_test_fails("when string's size is not as expected", "expected size of \"washington\" to be 11, not 10") do
    assert_size("washington", 11)
  end
  assertion_test_fails("when string's size is out of range", "expected size of \"washington\" to be 11..13, not 10") do
    assert_size("washington", 11..13)
  end

  assertion_test_passes("when an array's size is as expected", "is of size 3") { assert_size([1, 2, 3], 3) }
  assertion_test_passes("when an array's size is in given range", "is of size 3..4") do
    assert_size([1, 2, 3], 3..4)
  end
  assertion_test_fails("when an array's size is not as expected", "expected size of [1, 2, 3] to be 2, not 3") do
    assert_size([1, 2, 3], 2)
  end
  assertion_test_fails("when an array's size is out of range", "expected size of [1, 2, 3] to be 4..6, not 3") do
    assert_size([1, 2, 3], 4..6)
  end

  assertion_test_passes("when a hash size is as expected", "is of size 1") do
    assert_size({:name => 'washington'}, 1)
  end
  assertion_test_passes("when a hash size is in range", "is of size 1...3") do
    assert_size({:name => 'washington'}, 1...3)
  end
  assertion_test_fails("when a hash size is not as expected", "expected size of {} to be 2, not 0") do
    assert_size({}, 2)
  end
  assertion_test_fails("when a hash size is out of range", "expected size of {} to be 2...4, not 0") do
    assert_size({}, 2...4)
  end
end

context "A negative size assertion macro" do
  helper(:deny_size) { |sizable, expected_size| Riot::Assertion.new("test", true) { sizable }.size(expected_size) }

  assertion_test_fails("when string's size is as expected", 'expected size of "washington" to not be 10, not 10') do
    deny_size("washington", 10)
  end
  assertion_test_fails("when string's size is in given range", 'expected size of "washington" to not be 9..12, not 10') do
    deny_size("washington", 9..12)
  end

  assertion_test_passes("when string's size is not as expected", 'is not size 11') do
    deny_size("washington", 11)
  end
  assertion_test_passes("when string's size is out of range", 'is not size 11..13') do
    deny_size("washington", 11..13)
  end

  assertion_test_fails("when an array's size is as expected", 'expected size of [1, 2, 3] to not be 3, not 3') do
    deny_size([1, 2, 3], 3)
  end
  assertion_test_fails("when an array's size is in given range", 'expected size of [1, 2, 3] to not be 3..4, not 3') do
    deny_size([1, 2, 3], 3..4)
  end
  assertion_test_passes("when an array's size is not as expected", "is not size 2") do
    deny_size([1, 2, 3], 2)
  end
  assertion_test_passes("when an array's size is out of range", "is not size 4..6") do
    deny_size([1, 2, 3], 4..6)
  end

  assertion_test_fails("when a hash size is as expected", 'expected size of {:a=>"b"} to not be 1, not 1') do
    deny_size({:a => 'b'}, 1)
  end
  assertion_test_fails("when a hash size is in range", 'expected size of {:a=>"b"} to not be 1...3, not 1') do
    deny_size({:a => 'b'}, 1...3)
  end
  assertion_test_passes("when a hash size is not as expected", "is not size 2") do
    deny_size({}, 2)
  end
  assertion_test_passes("when a hash size is out of range", "is not size 2...4") do
    deny_size({}, 2...4)
  end
end
