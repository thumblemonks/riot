require 'teststrap'

class Whoops < Exception; end

context "A raises assertion macro" do
  assertion_test_passes("when expected exception is raised", "raises Whoops") do
    Riot::Assertion.new("foo") { raise Whoops }.raises(Whoops)
  end

  assertion_test_fails("when unexpected exception is raised", "should have raised Exception, not Whoops") do
    Riot::Assertion.new("foo") { raise Whoops }.raises(Exception)
  end

  assertion_test_fails("when nothing was raised", "should have raised Whoops, but raised nothing") do
    assertion = Riot::Assertion.new("foo") { "barf" }.raises(Whoops)
  end
  
  assertion_test_passes("when provided message equals expected message", %Q{raises Whoops with message "Mom"}) do
    Riot::Assertion.new("foo") { raise Whoops, "Mom" }.raises(Whoops, "Mom")
  end

  assertion_test_fails("when messages aren't equal", %Q{expected "Mom" for message, not "Dad"}) do
    Riot::Assertion.new("foo") { raise Whoops, "Dad" }.raises(Whoops, "Mom")
  end

  assertion_test_passes("when provided message matches expected message", %Q{raises Whoops with message /Mom/}) do
    Riot::Assertion.new("foo") { raise Whoops, "Mom" }.raises(Whoops, /Mom/)
  end

  assertion_test_fails("when messages don't match", %Q{expected /Mom/ for message, not "Dad"}) do
    Riot::Assertion.new("foo") { raise Whoops, "Dad" }.raises(Whoops, /Mom/)
  end
end # A raises assertion macro