require 'teststrap'

class Whoops < Exception; end

context "A raises assertion macro" do
  helper(:asserts_raises) { |o| Riot::Assertion.new("foo") { raise Whoops, o } }
  assertion_test_passes("when expected exception is raised", "raises Whoops") do
    asserts_raises(nil).raises(Whoops)
  end

  assertion_test_fails("when unexpected exception is raised", "expected to raise Exception, not Whoops") do
    asserts_raises(nil).raises(Exception)
  end

  assertion_test_fails("when nothing was raised", "expected to raise Whoops, but raised nothing") do
    assertion = Riot::Assertion.new("foo") { "barf" }.raises(Whoops)
  end
  
  assertion_test_passes("when provided message equals expected message", %Q{raises Whoops with message "Mom"}) do
    asserts_raises('Mom').raises(Whoops, 'Mom')
  end

  assertion_test_fails("when messages aren't equal", %Q{expected "Mom" for message, not "Dad"}) do
    asserts_raises('Dad').raises(Whoops, 'Mom')
  end

  assertion_test_passes("when provided message matches expected message", %Q{raises Whoops with message /Mom/}) do
    asserts_raises('Mom').raises(Whoops, /Mom/)
  end

  assertion_test_fails("when messages don't match", %Q{expected /Mom/ for message, not "Dad"}) do
    asserts_raises('Dad').raises(Whoops, /Mom/)
  end
end # A raises assertion macro

context "A negative raises assertion macro" do
  helper(:deny_raises) { |o| Riot::Assertion.new("foo", true) { raise Whoops, o } }

  assertion_test_fails("when expected exception is raised", "expected to not raise Whoops") do
    deny_raises(nil).raises(Whoops)
  end

  assertion_test_passes("when unexpected exception is raised", "raises Exception") do
    deny_raises(nil).raises(Exception)
  end

  assertion_test_passes("when nothing was raised", "raises Whoops") do
    Riot::Assertion.new("foo", true) { "barf" }.raises(Whoops)
  end
  
  assertion_test_fails("when provided message equals expected message", 'expected to not raise Whoops with message "Mom", but raised Whoops with message "Mom"') do
    deny_raises('Mom').raises(Whoops, 'Mom')
  end

  assertion_test_passes("when messages and exception aren't equal", 'raises Exception with message "Dad"') do
    deny_raises('Mom').raises(Exception, 'Dad')
  end

  assertion_test_fails("when provided message matches expected message", 'expected to not raise Whoops with message /Mom/, but raised Whoops with message "Mom"') do
    deny_raises('Mom').raises(Whoops, /Mom/)
  end

  assertion_test_fails("when messages don't match", "expected to not raise Whoops with message /Mom/, but raised Whoops with message \"Dad\"") do
    deny_raises('Dad').raises(Whoops,/Mom/)
  end
end # A raises assertion macro
